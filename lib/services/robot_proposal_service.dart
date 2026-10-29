import 'package:flutter/foundation.dart';
import 'product_identity_service.dart';
import 'robot_proposal_catalog.dart';

class RobotItemClassification {
  final int row;
  final List<String> values;
  RobotItemClassification(Map<String, dynamic> source)
      : row = source['row'] as int,
        values = List<String>.unmodifiable(source['values'] as List);
  String get major => values[0];
  String get majorName => values[1];
  String get middle => values[2];
  String get middleName => values[3];
  String get minor => values[4];
  String get minorName => values[5];
  String get path =>
      '$major · $majorName / $middle · $middleName / $minor · $minorName';
}

final robotItemClassifications = robotItemClassificationRows
    .map(RobotItemClassification.new)
    .toList(growable: false);

@immutable
class RobotCostOption {
  final String? choice;
  final int quantity;
  const RobotCostOption({this.choice, this.quantity = 1});
}

@immutable
class RobotCostResult {
  final Map<String, int> baseLines;
  final Map<String, int> optionLines;
  const RobotCostResult(this.baseLines, this.optionLines);
  int get base => baseLines.values.fold(0, (a, b) => a + b);
  int get options => optionLines.values.fold(0, (a, b) => a + b);
  int get total => base + options;
}

// Reproduces DEMO_v2 baseCalc / optionDelta exactly. Unknown input is unavailable,
// not a zero estimate. No official code generation or ERP writes are performed.
RobotCostResult? calculateRobotDemoCost(
    Map<String, String> inputs, Map<String, RobotCostOption> selected) {
  final base = <String, int>{};
  const labels = {
    'model': '모델 보정',
    'base': 'BASE 기준',
    'axis': '축',
    'type': '구동부',
    'stroke': 'STROKE',
    'drive': '구동방식',
    'lead': 'B/S Lead',
    'motorMaker': '모터 Maker',
    'motorCap': '모터 용량'
  };
  for (final field in robotDemoMaster.keys) {
    if (field == 'lead' && inputs['type'] == 'BELT') continue;
    final amount = robotDemoMaster[field]![inputs[field]];
    if (amount == null) return null;
    base['${labels[field]} · ${inputs[field]}'] = amount;
  }
  final options = <String, int>{};
  for (final entry in selected.entries) {
    final matches = robotDemoOptions.where((o) => o['name'] == entry.key);
    if (matches.isEmpty) return null;
    final option = matches.single;
    if (option['only'] != null && option['only'] != inputs['type']) continue;
    int amount;
    if (option['dynamic'] == 'motorSupply') {
      amount = -robotDemoMaster['motorCap']![inputs['motorCap']]!;
    } else if (option['control'] == 'qty') {
      if (entry.value.quantity < 1) return null;
      amount = (option['delta'] as num).toInt() * entry.value.quantity;
    } else if (option['control'] == 'select') {
      final choices = (option['choices'] as List).cast<List>();
      final match = choices.where((c) => c[0] == entry.value.choice);
      if (match.isEmpty) return null;
      amount = (match.single[1] as num).toInt();
    } else {
      amount = (option['delta'] as num? ?? 0).toInt();
    }
    options[entry.key] = amount;
  }
  return RobotCostResult(Map.unmodifiable(base), Map.unmodifiable(options));
}

int _proposalId = 0;
String newRobotProposalId() => 'rp${++_proposalId}';

class RobotProposalPart {
  final String id;
  final ProductIdentityKey specificationKey;
  String name;
  final String kind;
  int quantity;
  int? classificationRow;
  String note;
  final Map<String, String> costInputs;
  final Map<String, RobotCostOption> costOptions;
  RobotProposalPart(
      {required this.id,
      required this.specificationKey,
      required this.name,
      this.kind = '로봇',
      this.quantity = 1,
      this.classificationRow,
      this.note = '',
      Map<String, String>? costInputs,
      Map<String, RobotCostOption>? costOptions})
      : costInputs = {...?costInputs},
        costOptions = {...?costOptions};
  RobotItemClassification? get classification {
    for (final item in robotItemClassifications) {
      if (item.row == classificationRow) return item;
    }
    return null;
  }

  RobotCostResult? get cost => calculateRobotDemoCost(costInputs, costOptions);
  Map<String, String> get snapshot => {
        '구분': kind,
        '구성품명': name,
        '수량': '$quantity',
        '분류': classification?.path ?? '미선택',
        '분류 원본 행': '${classificationRow ?? ''}',
        ...?proposalSpecifications.value[specificationKey]?.fields,
        for (final entry in costInputs.entries)
          '계산 기준 ${entry.key}': entry.value,
        for (final entry in costOptions.entries)
          '재료비 옵션 ${entry.key}':
              '${entry.value.choice ?? '적용'} × ${entry.value.quantity}',
        '비고': note,
      };
}

@immutable
class RobotProposalRevision {
  final int number;
  final String requestName;
  final DateTime at;
  final String author;
  final String memo;
  final int? cost;
  final Map<String, Map<String, String>> parts;
  final List<String> changes;
  RobotProposalRevision(
      {required this.number,
      required this.requestName,
      required this.at,
      required this.author,
      required this.memo,
      required this.cost,
      required Map<String, Map<String, String>> parts,
      required List<String> changes})
      : parts = Map.unmodifiable(parts
            .map((k, v) => MapEntry(k, Map<String, String>.unmodifiable(v)))),
        changes = List.unmodifiable(changes);
  String get label => 'Rev.${number.toString().padLeft(2, '0')}';
}

class RobotProposalRequest {
  final String id;
  String name;
  final List<RobotProposalPart> parts;
  final List<RobotProposalRevision> revisions = [];
  RobotProposalRequest(
      {required this.id, this.name = '신규 사양검토 의뢰', required this.parts});
  int? get total {
    if (parts.isEmpty || parts.any((p) => p.cost == null)) return null;
    return parts.fold<int>(0, (a, p) => a + p.cost!.total * p.quantity);
  }

  Map<String, Map<String, String>> get snapshot => {
        for (final p in parts) p.id: p.snapshot,
      };
  bool get dirty =>
      revisions.isEmpty ||
      revisions.last.requestName != name ||
      !_sameParts(revisions.last.parts, snapshot);
}

bool _sameParts(Map<String, Map<String, String>> a,
        Map<String, Map<String, String>> b) =>
    setEquals(a.keys.toSet(), b.keys.toSet()) &&
    a.keys.every((key) => mapEquals(a[key], b[key]));

RobotProposalRevision saveRobotProposalRevision(RobotProposalRequest request,
    {required String author, String memo = ''}) {
  if (!request.dirty) throw StateError('직전 Rev와 변경된 내용이 없습니다.');
  final before = request.revisions.isEmpty ? null : request.revisions.last;
  final snapshot = request.snapshot;
  final changes = <String>[];
  if (before != null) {
    if (before.requestName != request.name) {
      changes.add('의뢰명: ${before.requestName} → ${request.name}');
    }
    for (final id in {...before.parts.keys, ...snapshot.keys}) {
      final a = before.parts[id], b = snapshot[id];
      if (a == null) {
        changes.add('${b!['구성품명']} 추가');
        continue;
      }
      if (b == null) {
        changes.add('${a['구성품명']} 삭제');
        continue;
      }
      for (final field in {...a.keys, ...b.keys}) {
        if (a[field] != b[field]) {
          changes.add(
              '${b['구성품명']} · $field: ${a[field] ?? '미입력'} → ${b[field] ?? '미입력'}');
        }
      }
    }
  }
  final revision = RobotProposalRevision(
      number: request.revisions.length + 1,
      requestName: request.name,
      at: DateTime.now(),
      author: author,
      memo: memo,
      cost: request.total,
      parts: snapshot,
      changes: changes);
  request.revisions.add(revision);
  return revision;
}

class RobotProposalDraft {
  final List<RobotProposalRequest> requests;
  RobotProposalDraft(this.requests);
}

/// Session-only. Keep original requests and revisions when changing selection.
final robotProposalDrafts = <ProductIdentityKey, RobotProposalDraft>{};
RobotProposalDraft robotProposalFor(ProductIdentityKey key) =>
    robotProposalDrafts.putIfAbsent(
        key,
        () => RobotProposalDraft([
              RobotProposalRequest(id: newRobotProposalId(), parts: [
                RobotProposalPart(
                    id: newRobotProposalId(),
                    specificationKey: key,
                    name: 'X축 로봇')
              ]),
            ]));
