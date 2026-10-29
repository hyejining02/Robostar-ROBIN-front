import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/models/order_workflow_schema.dart';
import 'package:robin_portal/screens/order_workflow_screen.dart';
import 'package:robin_portal/screens/dashboard_screen.dart';
import 'package:robin_portal/services/business_division_scope.dart';
import 'package:robin_portal/services/desktop_file_service.dart';
import 'package:robin_portal/services/order_workflow_service.dart';
import 'package:robin_portal/services/project_todo_service.dart';
import 'package:robin_portal/widgets/user_profile.dart';
import 'package:robin_portal/widgets/notification_center.dart';
import 'package:robin_portal/services/platform_review_service.dart';
import 'platform_review_test.dart'
    show platformActor, platformFixture, layoutFile;

const robot = (RobinBusinessDivision.robot, 'SO-TEST');
const platform = (RobinBusinessDivision.platformModule, 'SO-TEST');
const otherOrder = (RobinBusinessDivision.robot, 'SO-OTHER');
const file = SelectedDesktopFile(path: 'test.pdf', name: 'test.pdf');

class _WorkflowFiles extends FileSelectorPlatform {
  @override
  Future<XFile?> openFile(
          {List<XTypeGroup>? acceptedTypeGroups,
          String? initialDirectory,
          String? confirmButtonText}) async =>
      XFile.fromData(Uint8List.fromList([1, 2, 3]),
          name: 'po.pdf', path: 'po.pdf');
}

void main() {
  final original = robinUserProfile.value;
  setUp(() {
    robinUserProfile.value = original;
    selectedBusinessDivision.value = null;
    orderWorkflows.value = {};
    projectTodoItems.value = [];
  });
  tearDown(() {
    robinUserProfile.value = original;
    selectedBusinessDivision.value = null;
  });
  WorkRecord save(String module, Map<String, String> values,
          {OrderWorkKey key = robot,
          WorkRecord? previous,
          SelectedDesktopFile? attached}) =>
      saveWorkRecord(
          key: key,
          module: module,
          values: values,
          id: previous?.id,
          expectedVersion: previous?.version,
          file: attached,
          reason: '검증용 사유');
  WorkRecord price({OrderWorkKey key = robot, String amount = '100'}) => save(
      'price',
      {
        'part': 'P1',
        'title': '부품',
        'maker': 'MAKER',
        'supplier': '구매처',
        'unit': 'EA',
        'currency': 'KRW',
        'unitAmount': amount,
        'effectiveDate': '2026-10-19',
        'source': '수동 기준'
      },
      key: key);
  WorkRecord basis() => save('costBasis', {
        'title': '유사실적',
        'reference': 'ERP-REFERENCE',
        'model': 'RS-100',
        'spec': 'ST-100',
        'basisDate': '2026-10-01'
      });
  WorkRecord line(WorkRecord b,
          {String op = '기준',
          String qty = '2',
          String amount = '100',
          String part = 'P1'}) =>
      save('costLine', {
        'basisId': b.id,
        'title': 'BOM',
        'part': part,
        'operation': op,
        'quantityQty': qty,
        'unitAmount': amount,
        'consigned': '일반 구매'
      });
  WorkRecord allocation({String qty = '2', String total = '3'}) =>
      save('allocation', {
        'title': '배포',
        'supplier': '협력사',
        'workCenter': 'WC01',
        'quantityQty': qty,
        'orderQty': total
      });
  WorkRecord defect() => save('defect', {
        'title': '품질 이슈',
        'customer': '고객',
        'part': 'DWG01',
        'quantityQty': '1',
        'category': '가공',
        'subcategory': '치수',
        'method': '재작업',
        'assignee': original.name,
        'confirmer': original.name,
        'state': '접수',
        'blocksShipment': '출하 제한'
      });
  Map<String, String> purchaseFields() => {
        'part': 'P1',
        'title': '부품',
        'requiredQty': '10',
        'orderedQty': '8',
        'receivedQty': '3',
        'supplier': '거래처',
        'maker': 'A',
        'appliedMaker': 'A',
        'applicationState': '미확인',
        'supplierDate': '2026-10-22',
        'changedDate': '2026-10-24',
        'deliveryDate': '2026-10-23'
      };

  test('7 문서를 수주에 귀속시키며 파일/Rev 필수와 변경 전후를 보존한다', () {
    expect(() => save('document', {'title': 'PO', 'revision': '1'}),
        throwsStateError);
    final d = save(
        'document', {'title': 'PO', 'type': '발주서 PO', 'revision': '1'},
        attached: file);
    final changed =
        save('document', {'title': 'PO 수정', 'revision': '2'}, previous: d);
    expect(changed.file!.name, 'test.pdf');
    expect(workflowFor(robot).history.last.before!['revision'], '1');
    expect(workflowFor(platform).records, isEmpty);
  });
  test('7 발주 대조는 금액과 날짜를 따로 보존하고 잘못된 금액을 거부한다', () {
    final values = {
      'title': '대조',
      'poAmount': '100',
      'registeredAmount': '90',
      'poDate': '2026-11-01',
      'registeredDate': '2026-11-02'
    };
    save('poCompare', values);
    expect(() => save('poCompare', {...values, 'poAmount': 'NaN'}),
        throwsStateError);
    expect(() => save('poCompare', {...values, 'poDate': '2026-02-30'}),
        throwsStateError);
  });
  test('8 미정 규칙을 자동 결재선으로 사용하지 않으며 승인 후 근거 변경은 효력을 잃는다', () {
    final values = {
      'title': '규칙',
      'minRate': '0',
      'maxRate': '100',
      'special': '전체',
      'approvers': original.name
    };
    expect(() => save('approvalRule', values), throwsStateError);
    final rule = save('approvalRule', {...values, 'demo': '시연 규칙 동의'});
    final b = basis();
    line(b);
    saveMaterialSnapshot(robot, b.id, '산출');
    save('quote', {'title': '견적', 'proposalAmount': '400', 'spec': '사양'});
    expect(
        () => requestOrderApproval(robot,
            ruleId: rule.id, ratio: 50, special: false, reason: '상신'),
        throwsStateError);
    save('document', {'title': 'PO', 'type': '발주서 PO', 'revision': '1'},
        attached: file);
    expect(
        () => requestOrderApproval(robot,
            ruleId: rule.id, ratio: 70, special: false, reason: '상신'),
        throwsStateError);
    final a = requestOrderApproval(robot,
        ruleId: rule.id, ratio: 50, special: false, reason: '상신');
    expect(mayTransferOrder(robot), isFalse);
    decideOrderApproval(robot, a.id, a.version, true, '승인');
    expect(mayTransferOrder(robot), isTrue);
    queueErpRequest(robot, '수주 이관', '이관 시연');
    expect(workflowFor(robot).rows('integration').single['state'], '미전송');
    save('quote', {'title': '견적 변경', 'proposalAmount': '500', 'spec': '변경 사양'});
    expect(mayTransferOrder(robot), isFalse);
  });
  test('8 결재 순서와 변경 충돌, 대리점/직원 권한을 검사한다', () {
    price();
    activateRobinAccount('kimdealer');
    expect(canReadWorkflow(robot), isFalse);
    expect(() => price(), throwsStateError);
    activateRobinAccount('engineer');
    expect(() => save('approvalRule', {'title': '우회'}), throwsStateError);
    expect(() => save('purchase', purchaseFields()), throwsStateError);
  });
  test('9 같은 사업부의 단가는 공유하지만 통화·단위·0단가를 구분한다', () {
    final p = price(key: otherOrder, amount: '0');
    expect(divisionPrices(robot.$1).single['unitAmount'], '0');
    expect(divisionPrices(platform.$1), isEmpty);
    save('price', {...p.values, 'unitAmount': '150'},
        key: otherOrder, previous: p);
    expect(orderWorkflows.value[otherOrder]!.history.last.before!['unitAmount'],
        '0');
  });
  test('10 기준+추가-제외+대체차액을 계산하고 누락 단가면 산출 저장을 막는다', () {
    final b = basis();
    line(b, qty: '10');
    line(b, op: '추가', amount: '40', qty: '2', part: 'P2');
    line(b, op: '제외', qty: '1');
    expect(calculateMaterial(robot, b.id).total, 980);
    final snapshot = saveMaterialSnapshot(robot, b.id, '첫 산출');
    expect(snapshot['totalAmount'], '980.0');
    line(b, amount: '0', part: 'P3');
    expect(calculateMaterial(robot, b.id).total, isNull);
    expect(() => saveMaterialSnapshot(robot, b.id, '누락 산출'), throwsStateError);
    expect(snapshot['totalAmount'], '980.0');
  });
  test('10 연결 구매단가의 당시 버전·기준일을 고정하고 다른 통화와 품번을 거부한다', () {
    final p = price(key: otherOrder), b = basis();
    final row = save('costLine', {
      'title': '항목',
      'part': 'P1',
      'basisId': b.id,
      'quantityQty': '2',
      'priceId': p.id
    });
    expect(row['unitAmount'], '100');
    save('price', {...p.values, 'unitAmount': '200'},
        key: otherOrder, previous: p);
    expect(calculateMaterial(robot, b.id).total, 200);
    expect(row['priceReference'], contains('@1'));
    expect(
        () => save('costLine', {
              'title': '항목',
              'part': '다른품번',
              'basisId': b.id,
              'quantityQty': '2',
              'priceId': p.id
            }),
        throwsStateError);
  });
  test('11 VRB 입력 계산과 견적 Rev를 보존하고 예산 3종 근거를 검증한다', () {
    final vrb = save(
        'vrb',
        {
          'title': 'VRB',
          'type': '반도체',
          'rateVersion': '시연01',
          'proposalAmount': '1000',
          'materialAmount': '300',
          'outsideAmount': '100',
          'internalQty': '2',
          'internalUnitAmount': '50',
          'externalQty': '1',
          'externalUnitAmount': '50',
          'installationAmount': '50',
          'overheadRate': '10',
          'overheadBase': '제안가'
        },
        key: platform);
    expect(vrbCost(vrb), 700);
    final po = save(
        'document', {'title': 'PO', 'type': '발주서 PO', 'revision': '1'},
        key: platform, attached: file);
    var dwg = save('document',
        {'title': '도면', 'type': '도면', 'revision': '1', 'verified': '검토중'},
        key: platform, attached: file);
    expect(
        () => save(
            'budget',
            {
              'title': '근거',
              'drawingId': dwg.id,
              'costId': vrb.id,
              'poId': po.id
            },
            key: platform),
        throwsStateError);
    dwg = save('document', {'verified': '검토완'}, key: platform, previous: dwg);
    final bundle = save('budget',
        {'title': '근거', 'drawingId': dwg.id, 'costId': vrb.id, 'poId': po.id},
        key: platform);
    expect(bundle['drawingSnapshot'], contains('@2'));
    expect(() => save('vrb', vrb.values, key: platform, previous: vrb),
        throwsStateError);
  });
  test('12 번호 계층 순환을 막고 작업상태·진척·납기위험을 분리한다', () {
    final a = save('hierarchy', {
      'title': '호기',
      'type': '호기',
      'reference': 'UNIT1',
      'state': '진행',
      'risk': '위험',
      'progressRate': '20'
    });
    final b = save('hierarchy', {
      'title': '모듈',
      'type': '모듈',
      'reference': 'MOD1',
      'parentId': a.id,
      'state': '완료',
      'risk': '정상'
    });
    expect(() => save('hierarchy', {'parentId': b.id}, previous: a),
        throwsStateError);
    expect(a['progressRate'], '20');
    expect(b['progressRate'], '');
  });
  test('13·14 구매 수량·Maker 변경·최종 예정일을 검증한다', () {
    final p = save('purchase', purchaseFields());
    expect(p['unreceivedQty'], '5.0');
    expect(p['latestDate'], '2026-10-24');
    expect(() => save('purchase', {...purchaseFields(), 'receivedQty': '9'}),
        throwsStateError);
    expect(() => save('purchase', {...purchaseFields(), 'appliedMaker': 'B'}),
        throwsStateError);
    final changed = save('purchase',
        {'appliedMaker': 'B', 'replacement': 'P2', 'changeReason': '대체 승인 참조'},
        previous: p);
    expect(changed['applicationState'], '미확인');
  });
  test('15 사급품 입고와 투입 수량을 독립 관리하고 원가 처리를 자동 확정하지 않는다', () {
    final values = {
      'part': 'P1',
      'title': '사급',
      'provider': '고객',
      'recipient': '로보스타',
      'plannedQty': '10',
      'receivedQty': '5',
      'usedQty': '3'
    };
    final r = save('consignment', values, key: platform);
    expect(r['costTreatment'], '확인 필요');
    expect(
        () => save('consignment', {...values, 'usedQty': '6'}, key: platform),
        throwsStateError);
  });
  test('16 다른 수주의 확정 투입도 차감하고 Forecast/현재고 반영분을 중복 차감하지 않는다', () {
    save('inventory', {
      'part': 'P1',
      'title': '현재고',
      'onHandQty': '100',
      'snapshotDate': '2026-10-01',
      'snapshotReference': 'ERP 확인용 참조'
    });
    Map<String, String> e(String type, String qty, String ref) => {
          'part': 'P1',
          'title': type,
          'type': type,
          'quantityQty': qty,
          'eventDate': '2026-11-01',
          'reference': ref
        };
    save('stockEvent', e('확정 투입', '30', 'DEMAND1'), key: otherOrder);
    save('stockEvent', e('입고 예정', '10', 'RECEIPT1'));
    save('stockEvent',
        {...e('Forecast', '30', 'FORECAST1'), 'confirmedReference': 'DEMAND1'});
    save(
        'stockEvent', {...e('확정 투입', '20', 'DEMAND2'), 'reflected': '현재고 반영됨'});
    expect(projectedStock(robot, 'P1', '2026-11-02'), 80);
    expect(projectedStock(robot, 'P1', '2026-11-02', forecast: true), 80);
    expect(() => save('stockEvent', e('확정 투입', '30', 'DEMAND1')),
        throwsStateError);
    expect(projectedStock(platform, 'P1', '2026-11-02'), isNull);
  });
  test('17 배포 초과·중복 Serial·생산 전이·회수와 이력을 검증한다', () {
    final a = allocation();
    expect(() => allocation(qty: '2'), throwsStateError);
    final other = allocation(qty: '1');
    recallAllocation(robot, other.id, other.version, '미착수 회수');
    allocation(qty: '1');
    var p = save('product', {
      'title': '모델',
      'serial': 'SN1',
      'allocationId': a.id,
      'assignee': original.name
    });
    expect(
        () => save(
            'product', {'title': '모델', 'serial': 'SN1', 'allocationId': a.id}),
        throwsStateError);
    expect(() => productAction(robot, p.id, p.version, '포장 스캔 시연', '오류'),
        throwsStateError);
    productAction(robot, p.id, p.version, '명판 스캔 시연', '착수');
    p = workflowFor(robot).find(p.id)!;
    productAction(robot, p.id, p.version, '불량대기', '불량');
    p = workflowFor(robot).find(p.id)!;
    productAction(robot, p.id, p.version, '생산재개', '불량 해소');
    p = workflowFor(robot).find(p.id)!;
    productAction(robot, p.id, p.version, '포장 스캔 시연', '포장');
    p = workflowFor(robot).find(p.id)!;
    expect(p['state'], '포장완료');
    expect(() => productAction(robot, p.id, p.version, '출하완료', '오류'),
        throwsStateError);
    expect(
        () => recallAllocation(robot, a.id, a.version, '회수'), throwsStateError);
  });
  test('18 플랫폼 일정은 원천·호기·모듈과 계획/실제를 구분한다', () {
    final values = {
      'title': '현업 공정',
      'unit': 'UNIT1',
      'module': 'LPM',
      'assignee': '생산',
      'origin': '기존 생산 장표',
      'planStartDate': '2026-11-01',
      'planEndDate': '2026-11-10'
    };
    save('schedule', values, key: platform);
    expect(
        () => save('schedule', {...values, 'planEndDate': '2026-10-01'},
            key: platform),
        throwsStateError);
    expect(() => save('schedule', values, key: robot), throwsStateError);
  });
  test('19 불량 완료는 품질 확인을 거치고 20 출하 제한을 해제한다', () {
    var d = defect();
    expect(projectTodoItems.value.single.workflowRecordId, d.id);
    expect(shipmentIssues(robot), contains('품질 출하 제한'));
    expect(
        () => save('defect', {'state': '완료', 'actionResult': '바로 완료'},
            previous: d),
        throwsStateError);
    for (final state in ['담당자 확인', '품질 확인', '완료']) {
      d = save('defect', {'state': state, 'actionResult': '확인 근거'},
          previous: d);
    }
    expect(shipmentIssues(robot), isNot(contains('품질 출하 제한')));
    expect(projectTodoItems.value, isEmpty);
  });
  test('20 국내/해외·필수/사후 문서와 OQC 제한을 분리한다', () {
    save('shipment', {
      'title': '포장',
      'destination': '해외',
      'assignee': original.name,
      'status': '완료',
      'completedDate': '2026-10-19',
      'required': '출하 전 필수'
    });
    save('shipment', {
      'title': 'BL',
      'destination': '해외',
      'assignee': original.name,
      'status': '대기',
      'required': '사후 문서'
    });
    expect(shipmentIssues(robot), isEmpty);
    queueErpRequest(robot, '출하 요청', '시연');
    expect(() => queueErpRequest(robot, '출하 요청', '중복'), throwsStateError);
    save(
        'certificate',
        {
          'title': 'OQC',
          'customer': '고객',
          'item': 'P1',
          'template': '원본01',
          'requiredFields': '담당자 입력값',
          'result': '출하불가'
        },
        attached: file);
    expect(shipmentIssues(robot), contains('품질 출하 제한'));
  });
  test('21 Setup 완료와 23 회계 마감은 서로 강제하지 않는다', () {
    final s = save(
        'setup',
        {
          'title': '현장',
          'assignee': original.name,
          'planStartDate': '2026-11-01',
          'planEndDate': '2026-11-10',
          'peopleQty': '2',
          'manDays': '5',
          'travelAmount': '100'
        },
        key: platform);
    expect(() => save('setup', {'state': '완료'}, key: platform, previous: s),
        throwsStateError);
    save(
        'setup',
        {
          'state': '완료',
          'confirmedBy': original.name,
          'completedDate': '2026-11-09'
        },
        key: platform,
        previous: s);
    expect(workflowFor(platform).rows('closing'), isEmpty);
  });
  test('22 변경 전후와 사유는 수정 후에도 이력에 남는다', () {
    final c = save('change', {
      'title': '부품변경',
      'target': 'P1',
      'before': 'A',
      'after': 'B',
      'assignee': original.name,
      'type': '구매품 변경'
    });
    save('change', {'after': 'C'}, previous: c);
    expect(workflowFor(robot).history.last.before!['after'], 'B');
    expect(
        () => saveWorkRecord(
            key: robot,
            module: 'change',
            values: c.values,
            id: c.id,
            expectedVersion: 1,
            reason: 'stale'),
        throwsStateError);
  });
  test('23 분할 입금의 계약액 중복을 방지하고 입금 증빙 중복을 차단한다', () {
    Map<String, String> p(String amount, String ref) => {
          'title': '계약금',
          'type': '계약금',
          'expectedAmount': '1000',
          'paidAmount': amount,
          'paidDate': '2026-10-19',
          'evidence': ref,
          'installmentReference': 'INSTALLMENT1'
        };
    save('payment', p('200', 'BANK1'));
    save('payment', p('300', 'BANK2'));
    expect(paymentTotals(robot), (expected: 1000.0, paid: 500.0));
    expect(() => save('payment', p('200', 'BANK1')), throwsStateError);
    expect(
        () => save('payment', {...p('100', 'BANK3'), 'expectedAmount': '2000'}),
        throwsStateError);
  });

  test('사업부별 시연 데이터가 생성되고 기존 입력은 덮어쓰지 않는다', () {
    seedWorkflowDemo(robot);
    seedWorkflowDemo(platform);
    expect(workflowFor(robot).rows('costSnapshot'), hasLength(1));
    expect(workflowFor(platform).rows('vrb'), hasLength(1));
    expect(workflowFor(platform).rows('setup'), hasLength(1));
    final count = workflowFor(robot).records.length;
    expect(() => seedWorkflowDemo(robot), throwsStateError);
    expect(workflowFor(robot).records.length, count);
    expect(projectTodoItems.value.any((t) => t.workflowSection == 'inventory'),
        isTrue);
  });
  test('견적 Rev 순번이 누적되고 숨김 상태 필드 입력은 차단한다', () {
    save('quote', {'title': '1차', 'proposalAmount': '100', 'spec': 'A'});
    final q =
        save('quote', {'title': '2차', 'proposalAmount': '200', 'spec': 'B'});
    expect(q['revision'], 'Rev.2');
    expect(
        () => save('allocation', {
              'title': '위조',
              'supplier': 'A',
              'workCenter': 'W',
              'orderQty': '1',
              'quantityQty': '1',
              'state': '회수'
            }),
        throwsStateError);
  });
  test('제외·대체를 기준 BOM보다 중복 차감할 수 없다', () {
    final b = basis();
    line(b, qty: '1');
    line(b, op: '제외', qty: '2');
    expect(
        calculateMaterial(robot, b.id).missing.join(), contains('기준 BOM을 초과'));
  });
  test('SL의 현재 검토완 레이아웃만 동일 수주 참조로 가져온다', () {
    platformReviews.value = [];
    addTearDown(() => platformReviews.value = []);
    var r = savePlatformRequest(
        actor: platformActor,
        fields: {...platformFixture('SL-REFERENCE'), 'order': platform.$2},
        kinds: {PlatformReviewKind.layout});
    expect(importPlatformReviewedDrawings(platform, '연결'), 0);
    r = savePlatformReply(
        actor: platformActor,
        id: r.id,
        expectedVersion: r.version,
        kind: PlatformReviewKind.layout,
        status: PlatformReplyStatus.done,
        result: layoutFile);
    expect(importPlatformReviewedDrawings(platform, '연결'), 1);
    expect(workflowFor(platform).rows('document').single['verified'], '검토완');
    expect(importPlatformReviewedDrawings(platform, '중복'), 0);
    expect(importPlatformReviewedDrawings((platform.$1, '다른 수주'), '연결'), 0);
  });

  Future<void> open(WidgetTester t,
      {OrderWorkKey key = robot,
      String section = 'documents',
      Size size = const Size(1500, 1000)}) async {
    await t.binding.setSurfaceSize(size);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(MaterialApp(
        home: OrderWorkflowScreen(
            key: ValueKey('$key:$section'),
            recordKey: key,
            projectName: '검증',
            initialSection: section)));
    await t.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, Finder f) async {
    await t.ensureVisible(f);
    await t.pumpAndSettle();
    await t.tap(f);
    await t.pumpAndSettle();
  }

  testWidgets('모든 7~23 작업공간을 로봇/플랫폼에서 열고 빈 화면·작은 화면을 검사한다', (t) async {
    for (final key in [robot, platform]) {
      for (final s in sectionsFor(key.$1)) {
        await open(t, key: key, section: s.id, size: const Size(800, 700));
        expect(find.text('자료 근거: ${s.source}'), findsOneWidget);
        expect(t.takeException(), isNull);
      }
    }
  });
  testWidgets('필수 입력 오류를 표시하고 실제 기타 업무 폼 저장·수정 이력이 동작한다', (t) async {
    await open(t, section: 'changes');
    await tap(t, find.byKey(const ValueKey('add-change')));
    await tap(t, find.byKey(const ValueKey('work-save')));
    expect(find.textContaining('등록·변경 사유를 입력'), findsOneWidget);
    for (final e in {
      'title': 'UI 변경',
      'target': 'P1',
      'before': 'A',
      'after': 'B',
      'assignee': original.name
    }.entries) {
      await t.enterText(find.byKey(ValueKey('work-${e.key}')), e.value);
    }
    await t.enterText(find.byKey(const ValueKey('work-reason')), '고객 요청');
    await tap(t, find.byKey(const ValueKey('work-save')));
    expect(workflowFor(robot).rows('change').single['after'], 'B');
    expect(t.takeException(), isNull);
  });
  testWidgets('24 내 불량 To-Do와 알림에서 동일 원본 상세로 이동한다', (t) async {
    final d = defect();
    await t.binding.setSurfaceSize(const Size(1800, 1100));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(MaterialApp(home: DashboardScreen(onNavigate: (_) {})));
    await t.pumpAndSettle();
    await tap(t, find.textContaining('품질 이슈').last);
    expect(find.byType(OrderWorkflowScreen), findsOneWidget);
    expect(find.textContaining('시안 ID: ${d.id}'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
    await t.pumpAndSettle();
    await t.pumpWidget(MaterialApp(
        home: Scaffold(
            body: RobinNotificationList(onSelected: (_) {}, maxItems: 3))));
    await t.pumpAndSettle();
    expect(find.text('접수 · 품질 이슈'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('시연 데이터가 채워진 모든 작업공간도 작은 화면에서 표시된다', (t) async {
    seedWorkflowDemo(robot);
    seedWorkflowDemo(platform);
    for (final key in [robot, platform]) {
      for (final s in sectionsFor(key.$1)) {
        await open(t, key: key, section: s.id, size: const Size(850, 750));
        expect(find.text('자료 근거: ${s.source}'), findsOneWidget);
        expect(t.takeException(), isNull);
      }
    }
  });
  testWidgets('문서 폼에서 공용 파일 선택으로 첨부한 원본과 Rev를 저장한다', (t) async {
    final old = FileSelectorPlatform.instance;
    FileSelectorPlatform.instance = _WorkflowFiles();
    addTearDown(() => FileSelectorPlatform.instance = old);
    await open(t);
    await tap(t, find.byKey(const ValueKey('add-document')));
    await t.enterText(find.byKey(const ValueKey('work-title')), '파일 선택 검증');
    await t.enterText(find.byKey(const ValueKey('work-revision')), 'Rev.1');
    await tap(t, find.byKey(const ValueKey('work-attach')));
    await t.enterText(find.byKey(const ValueKey('work-reason')), '첨부 등록');
    await tap(t, find.byKey(const ValueKey('work-save')));
    expect(workflowFor(robot).rows('document').single.file!.name, 'po.pdf');
    expect(t.takeException(), isNull);
  });
}
