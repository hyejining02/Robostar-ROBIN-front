import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart' show XFile;

import '../models/access_control.dart';
import '../models/order_workflow_schema.dart';
import '../widgets/user_profile.dart';
import 'business_division_scope.dart';
import 'desktop_file_service.dart';
import 'platform_review_service.dart';
import 'project_todo_service.dart';

typedef OrderWorkKey = (RobinBusinessDivision, String);

/// Session-only frontend repository. None of these writes acknowledge an ERP transaction.
class WorkRecord {
  final String id;
  final String module;
  final Map<String, String> values;
  final SelectedDesktopFile? file;
  final int version;
  final String author;
  final DateTime at;
  WorkRecord(
      {required this.id,
      required this.module,
      required Map<String, String> values,
      this.file,
      required this.version,
      required this.author,
      required this.at})
      : values = Map.unmodifiable(values);
  String operator [](String field) => values[field] ?? '';
}

class WorkEvent {
  final WorkRecord after;
  final WorkRecord? before;
  final String reason;
  WorkEvent(this.before, this.after, this.reason);
}

class OrderWorkflow {
  final List<WorkRecord> records;
  final List<WorkEvent> history;
  const OrderWorkflow({this.records = const [], this.history = const []});
  List<WorkRecord> rows(String module) =>
      records.where((r) => r.module == module).toList();
  WorkRecord? find(String id) => records.where((r) => r.id == id).firstOrNull;
}

final orderWorkflows = ValueNotifier<Map<OrderWorkKey, OrderWorkflow>>({});
int _workSequence = 0;
OrderWorkflow workflowFor(OrderWorkKey key) =>
    orderWorkflows.value[key] ?? const OrderWorkflow();
bool canReadWorkflow(OrderWorkKey key) =>
    !robinUserProfile.value.isDealer &&
    BusinessDivisionScope.current().includes(key.$1);
bool canEditWorkflow(OrderWorkKey key, String module) {
  if (!canReadWorkflow(key)) return false;
  final u = robinUserProfile.value;
  if (u.isAdmin) return true;
  if (module == 'approvalRule') return false;
  if (['defect', 'change'].contains(module)) return true;
  final permission = u.departmentPermission;
  return switch (module) {
    'document' => permission == RobinDepartmentPermission.sales ||
        permission == RobinDepartmentPermission.engineering,
    'quote' ||
    'vrb' ||
    'budget' ||
    'approval' ||
    'shipment' ||
    'closing' ||
    'payment' ||
    'poCompare' =>
      permission == RobinDepartmentPermission.sales,
    'costBasis' ||
    'costLine' ||
    'costSnapshot' =>
      permission == RobinDepartmentPermission.sales ||
          permission == RobinDepartmentPermission.engineering,
    'hierarchy' => permission == RobinDepartmentPermission.engineering ||
        permission == RobinDepartmentPermission.manufacturing,
    _ => permission == RobinDepartmentPermission.manufacturing,
  };
}

double workNumber(String value, String label, {bool blankAllowed = false}) {
  if (blankAllowed && value.trim().isEmpty) return 0;
  final v = double.tryParse(value.replaceAll(',', '').trim());
  if (v == null || !v.isFinite || v < 0) {
    throw StateError('$label: 0 이상의 숫자를 입력해주세요.');
  }
  return v;
}

void _required(Map<String, String> v, List<String> fields) {
  for (final f in fields) {
    if ((v[f] ?? '').isEmpty) throw StateError('$f: 필수값을 입력해주세요.');
  }
}

void _date(String value, String label) {
  if (value.isNotEmpty && !validPlatformDate(value)) {
    throw StateError('$label: YYYY-MM-DD 날짜를 확인해주세요.');
  }
}

WorkRecord saveWorkRecord(
    {required OrderWorkKey key,
    required String module,
    required Map<String, String> values,
    String? id,
    int? expectedVersion,
    SelectedDesktopFile? file,
    required String reason}) {
  if (!canEditWorkflow(key, module)) {
    throw StateError('해당 업무의 수정 권한 또는 사업부 범위를 확인해주세요.');
  }
  if (reason.trim().isEmpty) throw StateError('등록·변경 사유를 입력해주세요.');
  final editableFields = fieldsFor(module).map((f) => f.id).toSet();
  if (values.keys.any((f) => !editableFields.contains(f))) {
    throw StateError('입력할 수 없는 필드가 포함되어 있습니다.');
  }
  final data = workflowFor(key);
  final before = id == null ? null : data.find(id);
  if (id != null &&
      (before == null ||
          before.module != module ||
          before.version != expectedVersion)) {
    throw StateError('업무가 변경되었습니다. 다시 열어주세요.');
  }
  if (before != null &&
      ['quote', 'vrb', 'costSnapshot', 'budget', 'payment', 'integration']
          .contains(module)) {
    throw StateError('누적 버전은 수정할 수 없습니다. 새 버전을 등록해주세요.');
  }
  final v = {
    ...?before?.values,
    for (final e in values.entries) e.key: e.value.trim()
  };
  for (final f in fieldsFor(module)) {
    if (f.choices.isNotEmpty) {
      v.putIfAbsent(f.id, () => f.choices.first);
      if (!f.choices.contains(v[f.id])) {
        throw StateError('${f.label}: 선택값을 확인해주세요.');
      }
    }
  }
  if (!sectionsFor(key.$1).expand((s) => s.modules).contains(module)) {
    throw StateError('해당 사업부에서 사용하는 업무가 아닙니다.');
  }
  for (final e in v.entries) {
    if (e.key.endsWith('Date')) _date(e.value, e.key);
    if (e.key.endsWith('Qty') ||
        e.key.endsWith('Amount') ||
        e.key.endsWith('Rate') ||
        e.key.endsWith('Days')) {
      if (e.value.isNotEmpty) workNumber(e.value, e.key);
    }
  }
  final attached = file ?? before?.file;
  _validateModule(key, module, v, before, attached);
  if (before == null && ['quote', 'vrb', 'budget'].contains(module)) {
    v['revision'] = 'Rev.${data.rows(module).length + 1}';
  }
  final now = DateTime.now();
  final record = WorkRecord(
      id: id ?? 'work-${now.microsecondsSinceEpoch}-${++_workSequence}',
      module: module,
      values: v,
      file: attached,
      version: (before?.version ?? 0) + 1,
      author: '${robinUserProfile.value.name} ${robinUserProfile.value.rank}',
      at: now);
  orderWorkflows.value = {
    ...orderWorkflows.value,
    key: OrderWorkflow(
        records: List.unmodifiable([
          for (final r in data.records)
            if (r.id != record.id) r,
          record
        ]),
        history: List.unmodifiable(
            [...data.history, WorkEvent(before, record, reason.trim())]))
  };
  _syncWorkTodo(key, record, before);
  if (['inventory', 'stockEvent'].contains(module)) {
    _syncInventoryTodo(key.$1, v['part']!);
  }
  return record;
}

void seedWorkflowDemo(OrderWorkKey key) {
  if (!robinUserProfile.value.isAdmin || !canReadWorkflow(key)) {
    throw StateError('관리자 시연 기능입니다.');
  }
  if (workflowFor(key).records.isNotEmpty) {
    throw StateError('이미 입력한 업무가 있어 시연 데이터를 덮어쓰지 않습니다.');
  }
  final bytes = Uint8List.fromList(
      'ROBIN DEMO reference. Not a customer document or ERP record.'.codeUnits);
  final demoFile = SelectedDesktopFile(
      path: 'ROBIN_DEMO.txt',
      name: 'ROBIN_DEMO.txt',
      source: XFile.fromData(bytes, name: 'ROBIN_DEMO.txt'));
  final user = robinUserProfile.value.name;
  WorkRecord add(String m, Map<String, String> v, {bool attached = false}) =>
      saveWorkRecord(
          key: key,
          module: m,
          values: v,
          file: attached ? demoFile : null,
          reason: '사용자가 요청한 시연 데이터 · ERP 미연동');
  add('document', {'title': '시연 PO', 'type': '발주서 PO', 'revision': 'DEMO-1'},
      attached: true);
  final drawing = add(
      'document',
      {
        'title': '시연 도면 참조',
        'type': '도면',
        'revision': 'DEMO-1',
        'verified': '검토완'
      },
      attached: true);
  add('poCompare', {
    'title': '시연 발주 대조',
    'poAmount': '2000',
    'registeredAmount': '2000',
    'poDate': '2026-11-20',
    'registeredDate': '2026-11-20'
  });
  WorkRecord cost;
  if (key.$1 == RobinBusinessDivision.robot) {
    final p = add('price', {
      'part': 'DEMO-P1',
      'title': '시연 부품',
      'maker': 'DEMO-MAKER',
      'supplier': 'DEMO 공급처',
      'unit': 'EA',
      'currency': 'KRW',
      'effectiveDate': '2026-10-19',
      'unitAmount': '100',
      'source': '시연 수동 단가'
    });
    final b = add('costBasis', {
      'title': '시연 유사실적',
      'reference': 'DEMO-REFERENCE',
      'model': 'DEMO-MODEL',
      'spec': '시연 사양',
      'basisDate': '2026-10-19'
    });
    add('costLine', {
      'title': '시연 기준 BOM',
      'part': 'DEMO-P1',
      'basisId': b.id,
      'quantityQty': '10',
      'priceId': p.id
    });
    cost = saveMaterialSnapshot(key, b.id, '시연 산출 버전');
    add('approvalRule', {
      'title': '시연 전용 규칙',
      'minRate': '0',
      'maxRate': '100',
      'approvers': user,
      'special': '전체',
      'demo': '시연 규칙 동의'
    });
    final a = add('allocation', {
      'title': '시연 협력사 배포',
      'supplier': 'DEMO 협력사',
      'workCenter': 'DEMO-WC',
      'orderQty': '3',
      'quantityQty': '2'
    });
    add('product', {
      'title': 'DEMO-MODEL',
      'serial': 'DEMO-SERIAL-001',
      'allocationId': a.id,
      'assignee': user
    });
  } else {
    cost = add('vrb', {
      'title': '시연 VRB',
      'type': '반도체',
      'rateVersion': 'DEMO-1',
      'proposalAmount': '2000',
      'materialAmount': '1000',
      'outsideAmount': '100',
      'internalQty': '1',
      'internalUnitAmount': '100',
      'externalQty': '0',
      'externalUnitAmount': '0',
      'installationAmount': '100',
      'overheadRate': '10',
      'overheadBase': '제안가'
    });
    final po = workflowFor(key)
        .rows('document')
        .firstWhere((r) => r['type'] == '발주서 PO');
    add('budget', {
      'title': '시연 예산 근거',
      'drawingId': drawing.id,
      'costId': cost.id,
      'poId': po.id
    });
    add('consignment', {
      'title': '시연 사급품',
      'part': 'DEMO-P2',
      'provider': '시연 고객',
      'recipient': '시연 제작사',
      'plannedQty': '10',
      'receivedQty': '5',
      'usedQty': '2',
      'assignee': user
    });
    add('schedule', {
      'title': '현업 공정 입력 예시',
      'unit': 'DEMO-UNIT',
      'module': 'DEMO-MODULE',
      'assignee': user,
      'origin': '기존 생산 장표',
      'planStartDate': '2026-11-01',
      'planEndDate': '2026-11-10'
    });
    add('setup', {
      'title': '시연 Setup',
      'assignee': user,
      'planStartDate': '2026-11-21',
      'planEndDate': '2026-11-25',
      'peopleQty': '2',
      'manDays': '4',
      'travelAmount': '100'
    });
  }
  add(
      'quote',
      {
        'title': '시연 견적',
        'proposalAmount': '2000',
        'spec': '시연 사양',
        'costId': cost.id
      },
      attached: true);
  final unit = add('hierarchy', {
    'title': '시연 호기',
    'type': '호기',
    'reference': 'DEMO-UNIT',
    'state': '진행',
    'risk': '주의',
    'progressRate': '20'
  });
  add('hierarchy', {
    'title': '시연 모듈',
    'type': '모듈',
    'reference': 'DEMO-MODULE',
    'parentId': unit.id,
    'state': '대기',
    'risk': '미확인'
  });
  add('purchase', {
    'title': '시연 구매 부품',
    'part': 'DEMO-P1',
    'unit': 'DEMO-UNIT',
    'module': 'DEMO-MODULE',
    'requiredQty': '10',
    'orderedQty': '8',
    'receivedQty': '3',
    'supplier': '시연 공급처',
    'maker': 'DEMO-MAKER',
    'appliedMaker': 'DEMO-MAKER',
    'supplierDate': '2026-11-08',
    'changedDate': '2026-11-10',
    'deliveryDate': '2026-11-09'
  });
  add('leadTime', {
    'title': '시연 표준납기',
    'supplier': '시연 공급처',
    'classification': '시연 분류',
    'statistic': '수동',
    'sampleQty': '0',
    'manualDays': '10'
  });
  if (!divisionRows(key.$1, 'inventory').any((r) => r['part'] == 'DEMO-P1')) {
    add('inventory', {
      'title': '시연 현재고',
      'part': 'DEMO-P1',
      'onHandQty': '5',
      'snapshotDate': '2026-10-19',
      'snapshotReference': 'DEMO snapshot',
      'safetyQty': '2',
      'assignee': user
    });
  }
  add('stockEvent', {
    'title': '시연 확정 투입',
    'part': 'DEMO-P1',
    'type': '확정 투입',
    'quantityQty': '6',
    'eventDate': '2026-11-10',
    'reference': 'DEMO-${key.$2}-DEMAND'
  });
  add(
      'certificate',
      {
        'title': '시연 성적서',
        'customer': '시연 고객',
        'item': 'DEMO-P1',
        'template': 'DEMO',
        'requiredFields': '원본 양식 아님',
        'result': '미확인'
      },
      attached: true);
  add('defect', {
    'title': '시연 불량 접수',
    'customer': '시연 고객',
    'part': 'DEMO-P1',
    'quantityQty': '1',
    'category': '시연 분류',
    'subcategory': '시연 세부',
    'method': '시연 검토',
    'assignee': user,
    'confirmer': user,
    'blocksShipment': '출하 제한'
  });
  add('shipment', {
    'title': '시연 포장 확인',
    'destination': '국내',
    'required': '출하 전 필수',
    'assignee': user
  });
  add('change', {
    'title': '시연 부품 변경',
    'target': 'DEMO-P1',
    'before': '시연 기존값',
    'after': '시연 변경값',
    'assignee': user
  });
  add('closing', {'title': '시연 종료 기준'});
  add('payment', {
    'title': '시연 계약금',
    'type': '계약금',
    'expectedAmount': '2000',
    'paidAmount': '500',
    'paidDate': '2026-10-19',
    'evidence': 'DEMO-BANK-1',
    'installmentReference': 'DEMO-CONTRACT-1'
  });
}

void _validateModule(OrderWorkKey key, String module, Map<String, String> v,
    WorkRecord? before, SelectedDesktopFile? file) {
  final data = workflowFor(key);
  double n(String field) => workNumber(v[field] ?? '', field);
  void req(List<String> fields) => _required(v, fields);
  switch (module) {
    case 'document':
      req(['title', 'type', 'revision']);
      if (file == null) throw StateError('문서 파일을 선택해주세요.');
      if (v['verified'] == '검토완' &&
          !robinUserProfile.value.isAdmin &&
          robinUserProfile.value.departmentPermission !=
              RobinDepartmentPermission.engineering) {
        throw StateError('도면 검토완 표시는 설계 권한이 필요합니다.');
      }
    case 'poCompare':
      req(['poAmount', 'registeredAmount', 'poDate', 'registeredDate']);
      n('poAmount');
      n('registeredAmount');
    case 'approvalRule':
      req(['title', 'minRate', 'maxRate', 'approvers', 'special', 'demo']);
      if (v['demo'] != '시연 규칙 동의') {
        throw StateError('운영 기준 미확정입니다. 시연 규칙 동의를 선택해주세요.');
      }
      if (n('maxRate') < n('minRate') || n('maxRate') > 100) {
        throw StateError('재료비율 구간을 확인해주세요.');
      }
    case 'approval':
      throw StateError('결재 전용 동작을 사용해주세요.');
    case 'price':
      req([
        'part',
        'title',
        'maker',
        'supplier',
        'unit',
        'currency',
        'effectiveDate',
        'unitAmount',
        'source'
      ]);
      n('unitAmount');
      if (before != null &&
          (before['part'] != v['part'] || before['maker'] != v['maker'])) {
        throw StateError('품번·Maker 변경은 별도 이력 행으로 등록해주세요.');
      }
    case 'costBasis':
      req(['title', 'reference', 'model', 'spec', 'basisDate']);
    case 'costLine':
      req(['title', 'part', 'operation', 'quantityQty', 'basisId']);
      n('quantityQty');
      if (data.find(v['basisId'] ?? '')?.module != 'costBasis') {
        throw StateError('유사실적 기준을 먼저 선택해주세요.');
      }
      if ((v['priceId'] ?? '').isNotEmpty) {
        final p = priceById(key.$1, v['priceId']!);
        if (p == null || p['part'] != v['part']) {
          throw StateError('선택 단가와 품번이 일치하지 않습니다.');
        }
        if (p['currency'] != 'KRW') {
          throw StateError('다른 통화는 확정 환산 기준이 필요합니다. 원화 단가를 선택해주세요.');
        }
        v['unitAmount'] = p['unitAmount'];
        v['priceReference'] =
            '${p.id}@${p.version} · ${p['effectiveDate']} · ${p['maker']}';
      }
      if ((v['unitAmount'] ?? '').isNotEmpty) n('unitAmount');
      if (v['operation'] == '대체') {
        req(['previousAmount', 'previousPart']);
        n('previousAmount');
      }
      if (v['consigned'] == '원가 제외') {
        v['unitAmount'] = '0';
      }
    case 'costSnapshot':
      throw StateError('산출 버전 저장 동작을 사용해주세요.');
    case 'vrb':
      req([
        'title',
        'type',
        'rateVersion',
        'proposalAmount',
        'materialAmount',
        'outsideAmount',
        'internalQty',
        'internalUnitAmount',
        'externalQty',
        'externalUnitAmount',
        'installationAmount',
        'overheadRate',
        'overheadBase'
      ]);
      for (final f in [
        'proposalAmount',
        'materialAmount',
        'outsideAmount',
        'internalQty',
        'internalUnitAmount',
        'externalQty',
        'externalUnitAmount',
        'installationAmount',
        'overheadRate'
      ]) {
        n(f);
      }
      if (n('proposalAmount') <= 0 || n('overheadRate') > 100) {
        throw StateError('제안가와 판관비율을 확인해주세요.');
      }
    case 'quote':
      req(['title', 'proposalAmount', 'spec']);
      n('proposalAmount');
    case 'budget':
      req(['title', 'drawingId', 'costId', 'poId']);
      final drawing = data.find(v['drawingId']!);
      final cost = data.find(v['costId']!);
      final po = data.find(v['poId']!);
      if (drawing?.module != 'document' ||
          drawing!['type'] != '도면' ||
          drawing['verified'] != '검토완') {
        throw StateError('동일 수주의 검토완 도면을 연결해주세요.');
      }
      if (!['costSnapshot', 'vrb'].contains(cost?.module)) {
        throw StateError('산출 버전 또는 VRB를 연결해주세요.');
      }
      if (po?.module != 'document' || po!['type'] != '발주서 PO') {
        throw StateError('동일 수주의 발주서 PO를 연결해주세요.');
      }
      v['drawingSnapshot'] =
          '${drawing.id}@${drawing.version} ${drawing['revision']}';
      v['costSnapshot'] = '${cost!.id}@${cost.version}';
      v['poSnapshot'] = '${po.id}@${po.version} ${po['revision']}';
    case 'hierarchy':
      req(['title', 'type', 'reference', 'state', 'risk']);
      final parent = v['parentId'] ?? '';
      if (parent.isNotEmpty &&
          (parent == before?.id || data.find(parent)?.module != 'hierarchy')) {
        throw StateError('상위 항목을 확인해주세요.');
      }
      var cursor = parent;
      final seen = <String>{};
      while (cursor.isNotEmpty) {
        if (cursor == before?.id || !seen.add(cursor)) {
          throw StateError('계층이 순환할 수 없습니다.');
        }
        cursor = data.find(cursor)?['parentId'] ?? '';
      }
      if ((v['progressRate'] ?? '').isNotEmpty && n('progressRate') > 100) {
        throw StateError('진척률은 0~100입니다.');
      }
    case 'purchase':
      req([
        'part',
        'title',
        'requiredQty',
        'orderedQty',
        'receivedQty',
        'supplier',
        'maker',
        'appliedMaker',
        'applicationState'
      ]);
      final required = n('requiredQty');
      final ordered = n('orderedQty');
      final received = n('receivedQty');
      if (received > ordered || ordered > required) {
        throw StateError('필요량 ≥ 발주량 ≥ 입고량을 확인해주세요. 취소/반품/초과납은 별도 정의가 필요합니다.');
      }
      if ((v['replacement'] ?? '').isNotEmpty ||
          v['maker'] != v['appliedMaker']) {
        req(['changeReason']);
      }
      v['unreceivedQty'] = (ordered - received).toString();
      final dates = [
        v['supplierDate'] ?? '',
        v['changedDate'] ?? '',
        v['deliveryDate'] ?? ''
      ]..sort();
      v['latestDate'] = dates.last;
    case 'leadTime':
      req([
        'supplier',
        'title',
        'classification',
        'statistic',
        'sampleQty',
        'manualDays'
      ]);
      n('sampleQty');
      n('manualDays');
      if (v['statistic'] != '수동') {
        req(['sourceDays']);
        n('sourceDays');
      }
      v['finalDays'] =
          (v['manualDays'] != '0' ? v['manualDays'] : v['sourceDays']) ?? '0';
    case 'consignment':
      req([
        'part',
        'title',
        'type',
        'provider',
        'recipient',
        'plannedQty',
        'receivedQty',
        'usedQty',
        'costTreatment'
      ]);
      if (n('usedQty') > n('receivedQty') ||
          n('receivedQty') > n('plannedQty')) {
        throw StateError('예정량 ≥ 입고량 ≥ 투입량을 확인해주세요.');
      }
    case 'inventory':
      req(['part', 'title', 'onHandQty', 'snapshotDate', 'snapshotReference']);
      n('onHandQty');
      if (divisionRows(key.$1, module)
          .any((r) => r.id != before?.id && r['part'] == v['part'])) {
        throw StateError('동일 품목의 재고 기준이 있습니다. 기존 행을 수정해주세요.');
      }
    case 'stockEvent':
      req(['part', 'title', 'type', 'quantityQty', 'eventDate', 'reference']);
      n('quantityQty');
      if (divisionRows(key.$1, module).any((r) =>
          r.id != before?.id &&
          r['part'] == v['part'] &&
          r['type'] == v['type'] &&
          r['reference'] == v['reference'])) {
        throw StateError('동일 수요/입고 근거가 중복됩니다.');
      }
    case 'allocation':
      if (before?['state'] == '회수') throw StateError('회수한 배포는 새 배포로 등록해주세요.');
      req(['title', 'supplier', 'workCenter', 'quantityQty', 'orderQty']);
      final qty = n('quantityQty');
      final total = n('orderQty');
      if (qty <= 0 || qty % 1 != 0 || total <= 0 || total % 1 != 0) {
        throw StateError('배포 수량은 양의 정수입니다.');
      }
      final rows = data
          .rows(module)
          .where((r) => r.id != before?.id && r['state'] != '회수');
      if (rows.any((r) => workNumber(r['orderQty'], '수주량') != total)) {
        throw StateError('기존 배포의 수주량과 일치해야 합니다.');
      }
      if (rows.fold<double>(
                  0, (sum, r) => sum + workNumber(r['quantityQty'], '배포량')) +
              qty >
          total) {
        throw StateError('수주수량을 초과 배포할 수 없습니다.');
      }
      if (before != null &&
          data.rows('product').any((p) => p['allocationId'] == before.id)) {
        throw StateError('제품이 등록된 배포는 수정·회수하지 않습니다. 재배포 기준 확인이 필요합니다.');
      }
    case 'product':
      req(['serial', 'title', 'allocationId']);
      if (data
          .rows(module)
          .any((r) => r.id != before?.id && r['serial'] == v['serial'])) {
        throw StateError('중복 Serial입니다.');
      }
      final a = data.find(v['allocationId']!);
      if (a?.module != 'allocation' || a!['state'] == '회수') {
        throw StateError('활성 배포 건을 선택해주세요.');
      }
      if (before == null &&
          data.rows(module).where((p) => p['allocationId'] == a.id).length >=
              workNumber(a['quantityQty'], '배포량')) {
        throw StateError('배포 수량보다 제품이 많습니다.');
      }
      if (before != null && v['state'] != before['state']) {
        throw StateError('생산 상태 동작 버튼을 사용해주세요.');
      }
      v['state'] = before?['state'] ?? '생산대기';
    case 'schedule':
      req([
        'title',
        'unit',
        'module',
        'assignee',
        'origin',
        'planStartDate',
        'planEndDate'
      ]);
      if (v['planStartDate']!.compareTo(v['planEndDate']!) > 0 ||
          ((v['actualStartDate'] ?? '').isNotEmpty &&
              (v['actualEndDate'] ?? '').isNotEmpty &&
              v['actualStartDate']!.compareTo(v['actualEndDate']!) > 0)) {
        throw StateError('착수일은 완료일보다 늦을 수 없습니다.');
      }
    case 'certificate':
      req([
        'title',
        'customer',
        'item',
        'template',
        'requiredFields',
        'result'
      ]);
      if (file == null) {
        throw StateError('성적서 파일을 선택해주세요. 자동 생성은 실제 양식 확보 후 지원합니다.');
      }
    case 'defect':
      req([
        'title',
        'customer',
        'part',
        'quantityQty',
        'category',
        'subcategory',
        'method',
        'assignee',
        'confirmer',
        'state'
      ]);
      if (n('quantityQty') <= 0) throw StateError('불량수량은 0보다 커야 합니다.');
      if (before == null && v['state'] != '접수') {
        throw StateError('접수 상태로 등록해주세요.');
      }
      const transitions = {
        '접수': ['담당자 확인', '재검토'],
        '담당자 확인': ['자재 확인', '품질 확인', '재검토'],
        '자재 확인': ['품질 확인', '재검토'],
        '품질 확인': ['완료', '재검토'],
        '재검토': ['담당자 확인', '품질 확인'],
        '완료': <String>[]
      };
      if (before != null &&
          before['state'] != v['state'] &&
          !(transitions[before['state']] ?? []).contains(v['state'])) {
        throw StateError('불량 처리 순서를 확인해주세요.');
      }
      if (v['state'] == '완료') {
        req(['actionResult']);
        final u = robinUserProfile.value;
        if (!u.isAdmin &&
            ![u.name, '${u.name} ${u.rank}'].contains(v['confirmer'])) {
          throw StateError('조치 확인 담당자가 완료 처리해야 합니다.');
        }
      }
    case 'shipment':
      req(['title', 'destination', 'assignee', 'status']);
      if (v['status'] == '완료') req(['completedDate']);
    case 'setup':
      req([
        'title',
        'assignee',
        'planStartDate',
        'planEndDate',
        'peopleQty',
        'manDays',
        'travelAmount',
        'state'
      ]);
      n('peopleQty');
      n('manDays');
      n('travelAmount');
      if (v['planStartDate']!.compareTo(v['planEndDate']!) > 0) {
        throw StateError('Setup 기간을 확인해주세요.');
      }
      if (v['state'] == '완료') req(['confirmedBy', 'completedDate']);
    case 'change':
      req([
        'title',
        'type',
        'target',
        'before',
        'after',
        'assignee',
        'approvalState'
      ]);
    case 'closing':
      req([
        'title',
        'businessState',
        'shippingState',
        'acceptanceState',
        'salesState',
        'accountingState',
        'setupState'
      ]);
    case 'payment':
      req([
        'title',
        'type',
        'expectedAmount',
        'paidAmount',
        'evidence',
        'installmentReference'
      ]);
      n('expectedAmount');
      n('paidAmount');
      if (data.rows('payment').any((r) => r['evidence'] == v['evidence'])) {
        throw StateError('이미 등록한 입금 근거입니다.');
      }
      if (data.rows('payment').any((r) =>
          r['installmentReference'] == v['installmentReference'] &&
          workNumber(r['expectedAmount'], '계약액') != n('expectedAmount'))) {
        throw StateError('같은 약정의 계약금액이 다릅니다.');
      }
      if (n('paidAmount') > 0) req(['paidDate']);
    default:
      throw StateError('정의되지 않은 업무입니다.');
  }
}

List<WorkRecord> divisionPrices(RobinBusinessDivision division) => [
      for (final e in orderWorkflows.value.entries)
        if (e.key.$1 == division) ...e.value.rows('price')
    ];
WorkRecord? priceById(RobinBusinessDivision d, String id) =>
    divisionPrices(d).where((r) => r.id == id).firstOrNull;
List<WorkRecord> divisionRows(RobinBusinessDivision division, String module) =>
    [
      for (final e in orderWorkflows.value.entries)
        if (e.key.$1 == division) ...e.value.rows(module)
    ];

class MaterialCalculation {
  final double base, added, removed, replaced;
  final List<String> missing;
  const MaterialCalculation(
      this.base, this.added, this.removed, this.replaced, this.missing);
  double? get total =>
      missing.isEmpty ? base + added - removed + replaced : null;
}

MaterialCalculation calculateMaterial(OrderWorkKey key, String basisId) {
  final rows =
      workflowFor(key).rows('costLine').where((r) => r['basisId'] == basisId);
  double base = 0, add = 0, remove = 0, replace = 0;
  final missing = <String>[];
  final baseParts = <String, double>{}, consumed = <String, double>{};
  if (rows.isEmpty) missing.add('기준 BOM 미입력');
  if (!rows.any((r) => r['operation'] == '기준')) missing.add('기준 BOM 항목 없음');
  for (final r in rows) {
    final p = double.tryParse(r['unitAmount'].replaceAll(',', ''));
    if (p == null || (p == 0 && r['consigned'] != '원가 제외')) {
      missing.add('${r['part']}: 단가 미확정/0단가');
      continue;
    }
    final amount = workNumber(r['quantityQty'], '수량') * p;
    switch (r['operation']) {
      case '기준':
        base += amount;
        baseParts[r['part']] = (baseParts[r['part']] ?? 0) + amount;
      case '추가':
        add += amount;
      case '제외':
        remove += amount;
        consumed[r['part']] = (consumed[r['part']] ?? 0) + amount;
      case '대체':
        replace += amount - workNumber(r['previousAmount'], '기존금액');
        consumed[r['previousPart']] = (consumed[r['previousPart']] ?? 0) +
            workNumber(r['previousAmount'], '기존금액');
    }
  }
  for (final e in consumed.entries) {
    if (!baseParts.containsKey(e.key) || e.value > baseParts[e.key]!) {
      missing.add('${e.key}: 제외/대체가 기준 BOM을 초과합니다.');
    }
  }
  if (base + add - remove + replace < 0) {
    missing.add('제외/대체 금액이 기준을 초과합니다. 중복 계산을 확인해주세요.');
  }
  return MaterialCalculation(
      base, add, remove, replace, List.unmodifiable(missing));
}

WorkRecord saveMaterialSnapshot(
    OrderWorkKey key, String basisId, String reason) {
  if (!canEditWorkflow(key, 'costSnapshot')) throw StateError('산출 권한이 없습니다.');
  final c = calculateMaterial(key, basisId);
  if (c.total == null) throw StateError(c.missing.join('\n'));
  final data = workflowFor(key);
  final basis = data.find(basisId);
  if (basis?.module != 'costBasis') throw StateError('기준실적을 확인해주세요.');
  return _appendDerived(
      key,
      'costSnapshot',
      {
        'title': '재료비 Rev.${data.rows('costSnapshot').length + 1}',
        'basisId': basisId,
        'reference': basis!['reference'],
        'baseAmount': '${c.base}',
        'addedAmount': '${c.added}',
        'removedAmount': '${c.removed}',
        'replacedAmount': '${c.replaced}',
        'totalAmount': '${c.total}',
        'lines': data
            .rows('costLine')
            .where((r) => r['basisId'] == basisId)
            .map((r) =>
                '${r['part']} qty=${r['quantityQty']} price=${r['unitAmount']} ${r['priceReference']}')
            .join('\n')
      },
      reason);
}

double vrbCost(WorkRecord r) {
  double n(String f) => workNumber(r[f], f);
  final direct = n('materialAmount') +
      n('outsideAmount') +
      n('internalQty') * n('internalUnitAmount') +
      n('externalQty') * n('externalUnitAmount') +
      n('installationAmount');
  final overheadBase =
      r['overheadBase'] == '제안가' ? n('proposalAmount') : direct;
  return direct + overheadBase * n('overheadRate') / 100;
}

WorkRecord _appendDerived(
    OrderWorkKey key, String module, Map<String, String> values, String reason,
    {WorkRecord? before, SelectedDesktopFile? file}) {
  if (reason.trim().isEmpty) throw StateError('사유를 입력해주세요.');
  final now = DateTime.now();
  final data = workflowFor(key);
  final r = WorkRecord(
      id: before?.id ??
          'derived-${now.microsecondsSinceEpoch}-${++_workSequence}',
      module: module,
      values: values,
      version: (before?.version ?? 0) + 1,
      author: '${robinUserProfile.value.name} ${robinUserProfile.value.rank}',
      at: now,
      file: file ?? before?.file);
  orderWorkflows.value = {
    ...orderWorkflows.value,
    key: OrderWorkflow(
        records: List.unmodifiable([
          for (final row in data.records)
            if (row.id != r.id) row,
          r
        ]),
        history:
            List.unmodifiable([...data.history, WorkEvent(before, r, reason)]))
  };
  return r;
}

int importPlatformReviewedDrawings(OrderWorkKey key, String reason) {
  if (key.$1 != RobinBusinessDivision.platformModule ||
      !canEditWorkflow(key, 'document')) {
    throw StateError('플랫폼 도면 연결 권한을 확인해주세요.');
  }
  final matched =
      platformReviews.value.where((r) => r.request.fields['order'] == key.$2);
  int count = 0;
  for (final r in matched) {
    final reply = r.replyFor(PlatformReviewKind.layout);
    if (reply?.status != PlatformReplyStatus.done || reply?.result == null) {
      continue;
    }
    final reference = '${r.id}@${r.version}:${reply!.result!.id}';
    if (workflowFor(key)
        .rows('document')
        .any((d) => d['sourceReference'] == reference)) {
      continue;
    }
    _appendDerived(
        key,
        'document',
        {
          'title': 'SL ${r.request.fields['sl']} 검토완 도면',
          'type': '도면',
          'revision': reply.result!.revision,
          'verified': '검토완',
          'sourceReference': reference
        },
        reason,
        file: reply.result!.file);
    count++;
  }
  return count;
}

String approvalFingerprint(OrderWorkKey key) => workflowFor(key)
    .records
    .where((r) => ['costSnapshot', 'vrb', 'quote', 'document', 'approvalRule']
        .contains(r.module))
    .map((r) => '${r.id}@${r.version}')
    .join('|');
WorkRecord requestOrderApproval(OrderWorkKey key,
    {required String ruleId,
    required double ratio,
    required bool special,
    required String reason}) {
  if (!canEditWorkflow(key, 'approval')) throw StateError('영업 결재 권한이 없습니다.');
  final data = workflowFor(key);
  final rule = data.find(ruleId);
  if (rule?.module != 'approvalRule' ||
      ratio < workNumber(rule!['minRate'], '최소') ||
      ratio > workNumber(rule['maxRate'], '최대') ||
      (rule['special'] != '전체' && rule['special'] != (special ? '특주' : '일반'))) {
    throw StateError('해당 조건의 시연 결재선이 없습니다. 실제 결재선은 확정 필요합니다.');
  }
  if (!data.rows('document').any((r) => r['type'] == '발주서 PO') ||
      data.rows('quote').isEmpty ||
      (data.rows('costSnapshot').isEmpty && data.rows('vrb').isEmpty)) {
    throw StateError('발주서·견적 Rev·원가 산출 버전을 먼저 연결해주세요.');
  }
  final approvers = rule['approvers']
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  if (approvers.isEmpty) throw StateError('결재자를 입력해주세요.');
  final latest = data.rows('quote').last;
  final cost = key.$1 == RobinBusinessDivision.platformModule
      ? data.rows('vrb').lastOrNull
      : data.rows('costSnapshot').lastOrNull;
  if (cost == null) throw StateError('사업부에 맞는 산출 버전이 필요합니다.');
  final price = workNumber(latest['proposalAmount'], '견적가');
  final total = cost.module == 'vrb'
      ? vrbCost(cost)
      : workNumber(cost['totalAmount'], '재료비');
  final material =
      cost.module == 'vrb' ? workNumber(cost['materialAmount'], '재료비') : total;
  if (price <= 0 || (ratio - material / price * 100).abs() > .01) {
    throw StateError(
        '재료비율이 최신 견적·산출 버전과 다릅니다. 현재 비율: ${price > 0 ? (material / price * 100).toStringAsFixed(2) : '미확인'}%');
  }
  return _appendDerived(
      key,
      'approval',
      {
        'title': '시연 결재',
        'state': '진행',
        'approvers': approvers.join(','),
        'step': '0',
        'fingerprint': approvalFingerprint(key),
        'ratio': '$ratio',
        'special': '$special',
        'costId': cost.id,
        'quoteId': latest.id
      },
      reason);
}

void decideOrderApproval(OrderWorkKey key, String id, int expectedVersion,
    bool approve, String reason) {
  final data = workflowFor(key);
  final r = data.find(id);
  final u = robinUserProfile.value;
  if (!canReadWorkflow(key) ||
      r?.module != 'approval' ||
      r!.version != expectedVersion ||
      r['state'] != '진행') {
    throw StateError('처리 가능한 결재가 아닙니다.');
  }
  if (r['fingerprint'] != approvalFingerprint(key)) {
    throw StateError('근거가 변경되었습니다. 새 결재를 요청해주세요.');
  }
  final steps = r['approvers'].split(',');
  final index = int.parse(r['step']);
  if (!u.isAdmin && ![u.name, '${u.name} ${u.rank}'].contains(steps[index])) {
    throw StateError('현재 순서의 결재자가 아닙니다.');
  }
  _appendDerived(
      key,
      'approval',
      {
        ...r.values,
        'step': '${approve ? index + 1 : index}',
        'state': !approve
            ? '반려'
            : index + 1 == steps.length
                ? '승인'
                : '진행'
      },
      reason,
      before: r);
}

bool mayTransferOrder(OrderWorkKey key) {
  final r = workflowFor(key).rows('approval').lastOrNull;
  return r != null &&
      r['state'] == '승인' &&
      r['fingerprint'] == approvalFingerprint(key);
}

({double expected, double paid}) paymentTotals(OrderWorkKey key) {
  final rows = workflowFor(key).rows('payment');
  final contracts = <String, double>{};
  double paid = 0;
  for (final r in rows) {
    contracts[r['installmentReference']] =
        workNumber(r['expectedAmount'], '계약액');
    paid += workNumber(r['paidAmount'], '입금액');
  }
  return (
    expected: contracts.values.fold<double>(0, (s, v) => s + v),
    paid: paid
  );
}

void recallAllocation(OrderWorkKey key, String id, int version, String reason) {
  if (!canEditWorkflow(key, 'allocation')) throw StateError('생산 배포 권한이 없습니다.');
  final data = workflowFor(key);
  final r = data.find(id);
  if (r?.module != 'allocation' ||
      r!.version != version ||
      r['state'] == '회수') {
    throw StateError('회수할 배포를 확인해주세요.');
  }
  if (data.rows('product').any((p) => p['allocationId'] == id)) {
    throw StateError('Serial이 등록된 배포 회수는 운영 규칙 확인이 필요합니다.');
  }
  _appendDerived(key, 'allocation', {...r.values, 'state': '회수'}, reason,
      before: r);
}

double? projectedStock(OrderWorkKey key, String part, String horizon,
    {bool forecast = false}) {
  _date(horizon, '기준일');
  final stock = divisionRows(key.$1, 'inventory')
      .where((r) => r['part'] == part)
      .firstOrNull;
  if (stock == null || horizon.compareTo(stock['snapshotDate']) < 0) {
    return null;
  }
  final events = divisionRows(key.$1, 'stockEvent')
      .where((r) =>
          r['part'] == part &&
          r['eventDate'].compareTo(horizon) <= 0 &&
          r['eventDate'].compareTo(stock['snapshotDate']) >= 0 &&
          r['reflected'] != '현재고 반영됨')
      .toList();
  double qty = workNumber(stock['onHandQty'], '현재고');
  for (final r in events) {
    if (r['type'] == 'Forecast' &&
        (!forecast ||
            events.any((c) =>
                c['type'] == '확정 투입' &&
                c['reference'] == r['confirmedReference']))) {
      continue;
    }
    qty += (r['type'] == '입고 예정' ? 1 : -1) * workNumber(r['quantityQty'], '수량');
  }
  return qty;
}

void productAction(
    OrderWorkKey key, String id, int version, String action, String reason) {
  if (!canEditWorkflow(key, 'product')) {
    throw StateError('생산 관리 권한이 없습니다. 협력사/포장 역할의 운영 권한은 확정 전입니다.');
  }
  final r = workflowFor(key).find(id);
  if (r?.module != 'product' || r!.version != version) {
    throw StateError('제품 상태를 다시 확인해주세요.');
  }
  final state = r['state'];
  String next;
  if (action == '명판 스캔 시연' && state == '생산대기') {
    next = '작업 중';
  } else if (action == '포장 스캔 시연' && state == '작업 중') {
    next = '포장완료';
  } else if (action == '생산재개' && state.endsWith('대기') && state != '생산대기') {
    next = '작업 중';
  } else if (['불량대기', '도급자재대기', '사급자재대기', '사급모터대기', '기타대기'].contains(action) &&
      state == '작업 중') {
    next = action;
  } else {
    throw StateError('현재 상태에서는 해당 동작을 할 수 없습니다. 출하완료는 ERP 실적 연동이 필요합니다.');
  }
  final updated = _appendDerived(
      key, 'product', {...r.values, 'state': next}, reason,
      before: r);
  _syncWorkTodo(key, updated, r);
}

List<String> shipmentIssues(OrderWorkKey key) {
  final data = workflowFor(key);
  final result = <String>[];
  if (data.rows('certificate').any((r) => r['result'] == '출하불가') ||
      data
          .rows('defect')
          .any((r) => r['blocksShipment'] == '출하 제한' && r['state'] != '완료')) {
    result.add('품질 출하 제한');
  }
  final checks =
      data.rows('shipment').where((r) => r['required'] == '출하 전 필수').toList();
  if (checks.isEmpty) result.add('체크리스트 필수 기준 미설정');
  if (checks.any((r) => r['status'] != '완료')) result.add('필수 준비 항목 미완료');
  return result;
}

void queueErpRequest(OrderWorkKey key, String operation, String reason) {
  if (!['수주 이관', '출하 요청', '마감 조회'].contains(operation)) {
    throw StateError('지원하지 않는 연계 요청입니다.');
  }
  if (!canReadWorkflow(key) || !robinUserProfile.value.isAdmin) {
    throw StateError('연계 시안 요청은 관리자만 가능합니다.');
  }
  if (operation == '수주 이관' && !mayTransferOrder(key)) {
    throw StateError('시연 결재 미완료 또는 근거 변경으로 이관 시안을 진행할 수 없습니다.');
  }
  if (operation == '출하 요청' && shipmentIssues(key).isNotEmpty) {
    throw StateError(shipmentIssues(key).join(' / '));
  }
  if (workflowFor(key)
      .rows('integration')
      .any((r) => r['operation'] == operation && r['state'] == '미전송')) {
    throw StateError('동일한 미전송 요청이 이미 있습니다.');
  }
  _appendDerived(
      key,
      'integration',
      {
        'title': operation,
        'operation': operation,
        'state': '미전송',
        'result': '백엔드·ERP 미연동. ROBIN 요청 시안만 기록'
      },
      reason);
}

void _syncWorkTodo(OrderWorkKey key, WorkRecord r, WorkRecord? before) {
  if (![
    'defect',
    'product',
    'setup',
    'change',
    'shipment',
    'schedule',
    'consignment'
  ].contains(r.module)) {
    return;
  }
  final prefix = 'order-work:${key.$1.name}:${key.$2}:${r.id}';
  projectTodoItems.value =
      projectTodoItems.value.where((t) => t.id != prefix).toList();
  final closed = ['완료', '포장완료', '출하완료']
      .contains(r['state'].isEmpty ? r['status'] : r['state']);
  if (closed ||
      r['assignee'].isEmpty ||
      (r.module == 'schedule' && r['actualEndDate'].isNotEmpty)) {
    return;
  }
  addProjectTodo(ProjectTodoItem(
      id: prefix,
      orderNo: key.$2,
      projectName: r['title'],
      stage: r.module,
      assignee: r['assignee'],
      task: '${r['state'].isEmpty ? r['status'] : r['state']} · ${r['title']}',
      createdBy: r.author,
      createdAt: r.at.toIso8601String(),
      division: key.$1,
      sourceLabel: '업무 상세',
      navigationIndex: 3,
      workflowSection: r.module,
      workflowRecordId: r.id));
}

void _syncInventoryTodo(RobinBusinessDivision division, String part) {
  final entry = orderWorkflows.value.entries
      .where((e) =>
          e.key.$1 == division &&
          e.value.rows('inventory').any((r) => r['part'] == part))
      .firstOrNull;
  if (entry == null) return;
  final stock =
      entry.value.rows('inventory').firstWhere((r) => r['part'] == part);
  final id = 'stock-alert:${division.name}:$part';
  projectTodoItems.value =
      projectTodoItems.value.where((t) => t.id != id).toList();
  final dates = [
    DateTime.now().toIso8601String().substring(0, 10),
    stock['snapshotDate'],
    ...divisionRows(division, 'stockEvent')
        .where((r) => r['part'] == part)
        .map((r) => r['eventDate'])
  ]..sort();
  final qty = projectedStock(entry.key, part, dates.last);
  if (qty == null ||
      qty >= (double.tryParse(stock['safetyQty']) ?? 0) ||
      stock['assignee'].isEmpty) {
    return;
  }
  addProjectTodo(ProjectTodoItem(
      id: id,
      orderNo: entry.key.$2,
      projectName: stock['title'],
      stage: '구매',
      assignee: stock['assignee'],
      task: '자재부족 · $part · ${dates.last} 예상 $qty',
      createdBy: stock.author,
      createdAt: DateTime.now().toIso8601String(),
      division: division,
      sourceLabel: '가용재고 예측 시안',
      workflowSection: 'inventory',
      workflowRecordId: stock.id));
}
