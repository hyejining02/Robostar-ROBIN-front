import 'dart:convert';
import 'product_identity_service.dart';
import 'desktop_file_service.dart';

// Platform HTML v13.1 (infoForm / renderProposal) and
// 플랫폼_(VRB)FAS-AGV-RPS 기본양식.xlsm, VRB통합(전체)!B3:J40.
const platformEquipment = {
  '반도체': ['EFEM', 'LPM', 'ALIGNER', 'TR', 'DOORLIFT'],
  'AGV/AMR': ['AGV', 'AMR', 'MOMA'],
  'FAS': ['FAS'],
  'STK': ['STK'],
  'RPS': ['RPS'],
};
const platformMaterials = {
  '150mm': '웨이퍼',
  '200mm': '웨이퍼',
  '300mm': '웨이퍼',
  '300×300': '패널',
  '415×510': '패널',
  '515×510': '패널',
  '600×600': '패널',
  '기타 (620×620 · 415×512 등)': '패널',
  'NA (이재물 없음)': '해당 없음'
};
const platformProjectTypes = ['사내/외주제작 (부분턴키)', '턴키(전체)', '바이패스', '사급/도급 전환품'];
const platformAssessLabels = {
  'customer': '업체',
  'contact': '고객 담당자',
  'rank': '고객 직급',
  'phone': '전화번호',
  'email': '메일',
  'inquiry': '문의 사항',
  'endUser': 'End User',
  'seller': '판매처',
  'endUser2': 'End User2',
  'site': 'SITE',
  'maker': '설비사',
  'orderMonth': '수주 예상월',
  'arrivalMonth': '입고 예상월',
  'note': '비고',
};
const platformQuoteLabels = {
  'equipment': '장비명',
  'title': '견적명',
  'to': '수신',
  'number': '견적 No.',
  'date': '견적일',
  'validDays': '유효기간(일)',
  'delivery': '인도조건',
  'due': '납기',
  'payment': '지불조건',
  'notes': '특기사항'
};
const platformVrbCostLabels = {
  'outside': '외주인건비 (지급수수료)',
  'mfgTravel': '제조 여비교통비',
  'export': '수출비 (포장비/운반비)',
  'salesTravel': '판매 여비교통비',
  'design': '설계비',
  'make': '제조내작비',
  'setup': '현장설치비 (셋업 지원)',
};
const platformVrbRateLabels = {
  'consumables': '소모품비 등 변동경비',
  'warranty': '판매보증비',
  'agent': 'Agent 판매료',
  'commonMfg': '공통제조인건비',
  'fixedMfg': '고정성 제조경비',
  'sga': '공통 판관비'
};
int _platformLineId = 0;
String platformLineId() => 'pf${++_platformLineId}';
double? platformNumber(String? value) {
  final n = double.tryParse((value ?? '').replaceAll(',', '').trim());
  return n != null && n.isFinite && n >= 0 ? n : null;
}

class PlatformAmountLine {
  final String id;
  final Map<String, String> fields;
  PlatformAmountLine({Map<String, String>? fields})
      : id = platformLineId(),
        fields = {
          'name': '',
          'spec': '',
          'unit': 'EA',
          'price': '',
          'qty': '1',
          'note': '',
          ...?fields
        };
  double? get amount {
    final price = platformNumber(fields['price']),
        qty = platformNumber(fields['qty']);
    return price == null || qty == null ? null : price * qty;
  }

  Map<String, dynamic> toJson() => {...fields};
}

class PlatformMaterialGroup {
  String name;
  final List<PlatformAmountLine> rows;
  PlatformMaterialGroup(this.name, this.rows);
  Map<String, dynamic> toJson() =>
      {'name': name, 'rows': rows.map((r) => r.toJson()).toList()};
}

class PlatformPlannedUnit {
  final String number;
  final String equipment;
  bool excluded = false;
  PlatformPlannedUnit(this.number, this.equipment);
}

class PlatformProposalRevision {
  final int revision;
  final String author;
  final DateTime at;
  final String payload;
  PlatformProposalRevision(this.revision, this.author, this.payload)
      : at = DateTime.now();
  Map<String, dynamic> get data => jsonDecode(payload) as Map<String, dynamic>;
}

class PlatformDesignQuestion {
  final String text;
  final String author;
  final DateTime at = DateTime.now();
  final List<Map<String, String>> answers = [];
  PlatformDesignQuestion(this.text, this.author);
}

class PlatformDesignDocument {
  final SelectedDesktopFile file;
  final String category;
  final int revision;
  final String author;
  final DateTime at = DateTime.now();
  PlatformDesignDocument(this.file, this.category, this.revision, this.author);
}

class PlatformPipelineData {
  final ProductIdentityKey key;
  final DateTime createdAt = DateTime.now();
  final String owner;
  final Map<String, String> assess;
  String registrationType = '신규';
  String? origin;
  String category = '';
  final Map<String, int> equipment = {};
  final Set<String> materials = {};
  bool equipmentTbd = false;
  bool autoTitle = false;
  bool titleLocked = false;
  bool assessSaved = false;
  String? savedAssessPayload;
  final List<PlatformPlannedUnit> units = [];
  final List<Map<String, String>> meetings = [];
  final Map<String, List<SelectedDesktopFile>> files = {
    'mail': [],
    'layout': [],
    'material': []
  };
  final List<String> history = [];
  final List<PlatformProposalRevision> revisions = [];
  String designer = '';
  final List<PlatformDesignQuestion> designQuestions = [];
  final List<PlatformDesignDocument> designDocuments = [];
  String projectType = platformProjectTypes.first;
  String domestic = '내수';
  String bid = '';
  final List<PlatformMaterialGroup> groups = [
    PlatformMaterialGroup('ROBOT', [
      PlatformAmountLine(fields: {'name': 'HAND'})
    ])
  ];
  final Map<String, PlatformAmountLine> costs = {
    for (final k in platformVrbCostLabels.keys)
      k: PlatformAmountLine(fields: {
        if (['design', 'make', 'setup'].contains(k)) 'price': '300000'
      })
  };
  final Map<String, String> rates = {'agent': '0'};
  bool reserve = true;
  String reserveRate = '3';
  String rateReference = '';
  final Map<String, String> quote = {
    'currency': 'KRW',
    'fx': '1',
    'date': '',
    'validDays': '14',
    'delivery': '국내지정장소',
    'payment': 'PO 30% / FOB·입고 60% / FAT 10%'
  };
  final List<PlatformAmountLine> quoteLines = [PlatformAmountLine()];
  bool vrbSaved = false;
  bool quoteSaved = false;
  String approval = '작성중';
  String floor = '';
  String submittedDate = '';
  String reply = '';
  String replyMemo = '';
  String importSource = '';

  PlatformPipelineData(this.key,
      {required String customer,
      required String project,
      required this.owner,
      String product = '',
      int quantity = 0})
      : assess = {'customer': customer, 'project': project} {
    for (final e in platformEquipment.entries) {
      if (e.value.contains(product)) {
        category = e.key;
        if (quantity > 0) equipment[product] = quantity;
      }
    }
    quote['title'] = project;
    quote['equipment'] = project;
    quote['date'] = createdAt.toIso8601String().substring(0, 10);
  }
  String get projectName {
    if (titleLocked || !autoTitle) return assess['project'] ?? '';
    final used = equipment.entries.where((e) => e.value > 0).toList();
    final eq = used.isEmpty
        ? '장비미정'
        : '${used.first.key}${used.length > 1 ? '외' : ''}';
    final mat = category == '반도체' && materials.isNotEmpty
        ? '_${materials.join('+')}'
        : '';
    return '${assess['customer'] ?? ''}_$eq${mat}_${createdAt.year}${createdAt.month.toString().padLeft(2, '0')}_${registrationType == '신규' ? 'NEW' : 'RE'}';
  }

  List<String> validateAssess() {
    final errors = <String>[];
    if ((assess['customer'] ?? '').trim().isEmpty) errors.add('업체를 입력해주세요.');
    if (registrationType == 'Repeat / 양산' && origin == null) {
      errors.add('원 프로젝트를 선택해주세요.');
    }
    if (!equipmentTbd) {
      if (category.isEmpty || !equipment.values.any((v) => v > 0)) {
        errors.add('장비와 대수를 입력해주세요.');
      }
      if (equipment.entries.any((e) =>
          e.value > 0 &&
          !(platformEquipment[category] ?? []).contains(e.key))) {
        errors.add('한 프로젝트에는 같은 대분류의 장비만 입력해주세요.');
      }
      if (category == '반도체' && materials.isEmpty) errors.add('이재물을 선택해주세요.');
    }
    if ((assess['email'] ?? '').isNotEmpty &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(assess['email']!)) {
      errors.add('메일 형식을 확인해주세요.');
    }
    return errors;
  }

  void saveAssess(String actor) {
    final errors = validateAssess();
    if (errors.isNotEmpty) throw StateError(errors.join('\n'));
    assess['project'] = projectName;
    final payload = jsonEncode({
      'type': registrationType,
      'origin': origin,
      'category': category,
      'equipment': equipment,
      'materials': materials.toList(),
      'tbd': equipmentTbd,
      'fields': assess,
      'meetings': meetings
    });
    if (assessSaved && payload == savedAssessPayload) return;
    if (savedAssessPayload != null) touchProposal();
    if (registrationType == '신규' && !equipmentTbd) {
      for (final e in equipment.entries) {
        final active =
            units.where((u) => u.equipment == e.key && !u.excluded).length;
        final count = units.where((u) => u.equipment == e.key).length;
        for (var i = active; i < e.value; i++) {
          units.add(PlatformPlannedUnit(
              'SL-${key.$2}-${e.key}${count + i - active + 1}', e.key));
        }
        if (active > e.value) {
          for (final u in units
              .where((u) => u.equipment == e.key && !u.excluded)
              .skip(e.value)) {
            u.excluded = true;
          }
        }
      }
    }
    assessSaved = true;
    savedAssessPayload = payload;
    history.insert(0, '${DateTime.now()} · $actor · Assess 저장');
  }

  void touchProposal() {
    vrbSaved = false;
    quoteSaved = false;
    approval = '작성중';
    submittedDate = '';
  }

  double? get materialTotal =>
      _sum(groups.expand((g) => g.rows).map((r) => r.amount));
  double? get quoteTotal => _sum(quoteLines.map((r) => r.amount));
  double? get quoteKrw {
    final total = quoteTotal,
        fx = quote['currency'] == 'KRW' ? 1.0 : platformNumber(quote['fx']);
    return total == null || fx == null || fx <= 0 ? null : total * fx;
  }

  double? get revenue => bid.trim().isEmpty ? quoteKrw : platformNumber(bid);
  Map<String, double?> get result {
    final q = revenue,
        mat = materialTotal,
        full = projectType == platformProjectTypes.first;
    double? rate(String k) => q == null || platformNumber(rates[k]) == null
        ? null
        : q * platformNumber(rates[k])! / 100;
    double? cost(String k) => costs[k]!.amount;
    final manufacturing = full
        ? _sum([cost('outside'), rate('consumables'), cost('mfgTravel')])
        : 0.0;
    final selling = _sum(
        [cost('export'), rate('warranty'), cost('salesTravel'), rate('agent')]);
    final spare = !reserve
        ? 0.0
        : q == null || platformNumber(reserveRate) == null
            ? null
            : q * platformNumber(reserveRate)! / 100;
    final variable = _sum([mat, manufacturing, selling, spare]);
    final margin = q == null || variable == null ? null : q - variable;
    final internal =
        full ? _sum([cost('design'), cost('make'), cost('setup')]) : 0.0;
    final fixed = _sum([
      internal,
      full ? rate('commonMfg') : 0.0,
      full ? rate('fixedMfg') : 0.0,
      rate('sga')
    ]);
    final op = margin == null || fixed == null ? null : margin - fixed;
    return {
      'revenue': q,
      'material': mat,
      'manufacturing': manufacturing,
      'selling': selling,
      'reserve': spare,
      'variable': variable,
      'margin': margin,
      'internal': internal,
      'fixed': fixed,
      'op': op,
      'materialRatio':
          q == null || q <= 0 || mat == null ? null : mat / q * 100,
      'marginRatio':
          q == null || q <= 0 || margin == null ? null : margin / q * 100,
      'opRatio': q == null || q <= 0 || op == null ? null : op / q * 100
    };
  }

  Map<String, dynamic> proposalJson() => {
        'type': projectType,
        'domestic': domestic,
        'bid': bid,
        'groups': groups.map((g) => g.toJson()).toList(),
        'costs': {for (final e in costs.entries) e.key: e.value.toJson()},
        'rates': rates,
        'reserve': reserve,
        'reserveRate': reserveRate,
        'rateReference': rateReference,
        'quote': quote,
        'lines': quoteLines.map((l) => l.toJson()).toList(),
        'result': result
      };
  void saveVrb(String actor) {
    if (revenue == null ||
        revenue! <= 0 ||
        materialTotal == null ||
        groups
            .expand((g) => g.rows)
            .any((r) => (r.fields['name'] ?? '').trim().isEmpty)) {
      throw StateError('견적금액과 재료비의 단가·수량을 입력해주세요.');
    }
    vrbSaved = true;
    history.insert(0, '${DateTime.now()} · $actor · VRB 저장');
  }

  void saveQuote(String actor) {
    if (!vrbSaved) throw StateError('먼저 VRB를 저장해주세요.');
    if ((quote['equipment'] ?? '').trim().isEmpty ||
        quoteLines.any((l) => (l.fields['name'] ?? '').trim().isEmpty) ||
        quoteKrw == null ||
        quoteKrw! <= 0) {
      throw StateError('장비명·품명·단가·수량과 유효한 환율을 입력해주세요.');
    }
    quoteSaved = true;
    if (revisions.isNotEmpty &&
        revisions.last.payload == jsonEncode(proposalJson())) {
      return;
    }
    revisions.add(PlatformProposalRevision(
        revisions.length + 1, actor, jsonEncode(proposalJson())));
    history.insert(
        0, '${DateTime.now()} · $actor · 견적서 저장 Rev.${revisions.length}');
  }

  bool get readyToNegotiate =>
      vrbSaved &&
      quoteSaved &&
      approval == '승인' &&
      platformValidDate(submittedDate) &&
      reply.isNotEmpty;
}

bool platformValidDate(String value) {
  final date = DateTime.tryParse(value);
  return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) &&
      date != null &&
      date.toIso8601String().substring(0, 10) == value;
}

double? _sum(Iterable<double?> values) {
  var sum = 0.0;
  for (final n in values) {
    if (n == null) return null;
    sum += n;
  }
  return sum;
}

final platformPipelineRecords = <ProductIdentityKey, PlatformPipelineData>{};
PlatformPipelineData platformPipelineFor(ProductIdentityKey key,
        {String customer = '',
        String project = '',
        String owner = '',
        String product = '',
        int quantity = 0}) =>
    platformPipelineRecords.putIfAbsent(
        key,
        () => PlatformPipelineData(key,
            customer: customer,
            project: project,
            owner: owner,
            product: product,
            quantity: quantity));
