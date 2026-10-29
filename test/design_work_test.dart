import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/screens/design_work_management_screen.dart';
import 'package:robin_portal/screens/story_line_screens.dart';
import 'package:robin_portal/services/business_division_scope.dart';
import 'package:robin_portal/services/design_work_service.dart';
import 'package:robin_portal/services/platform_review_service.dart';
import 'package:robin_portal/services/product_identity_service.dart';
import 'package:robin_portal/services/project_todo_service.dart';
import 'package:robin_portal/services/robot_design_review_service.dart';
import 'package:robin_portal/widgets/user_profile.dart';

import 'platform_review_test.dart'
    show platformActor, platformFixture, materialFile;
import 'robot_design_review_test.dart' show reviewFixture;

const orders = [
  DesignOrderSource(
      division: RobinBusinessDivision.robot,
      number: 'SO-TEST',
      project: '수주 테스트',
      model: 'RS-100',
      due: '2026-11-01',
      stage: '마감')
];

class _DesignFiles extends FileSelectorPlatform {
  @override
  Future<XFile?> openFile(
          {List<XTypeGroup>? acceptedTypeGroups,
          String? initialDirectory,
          String? confirmButtonText}) async =>
      XFile.fromData(Uint8List.fromList([1, 2, 3]),
          name: 'design-result.pdf', path: 'design-result.pdf');
}

void main() {
  final profile = robinUserProfile.value;
  setUp(() {
    robinUserProfile.value = profile;
    selectedBusinessDivision.value = null;
    robotDesignReviews.value = {};
    platformReviews.value = [];
    otherDesignTasks.value = [];
    designWorkChanges.value = {};
    projectTodoItems.value = [];
    proposalSpecifications.value = {};
    productIdentities.value = {};
  });
  tearDown(() {
    robinUserProfile.value = profile;
    selectedBusinessDivision.value = null;
  });
  DesignWorkItem order() => collectDesignWork(orders: orders).single;
  void update(DesignWorkItem item,
          {String? token,
          DesignWorkStatus? status,
          String? assignee,
          String? due,
          bool? urgent,
          String reason = '업무 확인'}) =>
      updateDesignWork(
          id: item.id,
          expectedToken: token ?? item.token,
          orders: orders,
          status: status ?? item.displayStatus,
          assignee: assignee ?? item.displayAssignee,
          due: due ?? item.displayDue,
          urgent: urgent ?? item.displayUrgent,
          reason: reason);
  OtherDesignTask other(
          {String reference = 'SERVICE-001',
          String assignee = '이설계',
          String due = '2026-11-02'}) =>
      createOtherDesignTask(
          division: RobinBusinessDivision.robot,
          type: '서비스요청',
          reference: reference,
          title: '서비스 검토',
          assignee: assignee,
          due: due);
  RobotDesignReview robot() => applyRobotReview(
      key: (RobinBusinessDivision.robot, 'RB-TEST'),
      expectedVersion: 0,
      action: RobotReviewAction.submit,
      role: RobotReviewRole.sales,
      author: '김영업',
      projectName: '원본 로봇 프로젝트',
      customer: '원본 고객',
      content: reviewFixture());

  test('수주 업무는 프로젝트가 마감이어도 설계 완료로 추정하지 않는다', () {
    expect(order().displayStatus, DesignWorkStatus.unknown);
    expect(order().displayAssignee, '');
    update(order(), status: DesignWorkStatus.working, assignee: '이설계');
    expect(order().displayStatus, DesignWorkStatus.working);
    expect(orders.single.stage, '마감');
  });
  test('로봇 요청은 원본 프로젝트명/담당자/상태를 즉시 반영한다', () {
    final r = robot();
    final item = collectDesignWork().single;
    expect(item.title, contains('원본 로봇 프로젝트'));
    expect(item.displayAssignee, '이설계');
    expect(item.displayStatus, DesignWorkStatus.working);
    applyRobotReview(
        key: item.robotKey!,
        expectedVersion: r.version,
        action: RobotReviewAction.reject,
        role: RobotReviewRole.design,
        author: '이설계',
        projectName: r.projectName,
        content: r.content,
        reason: '보완 필요');
    expect(collectDesignWork().single.displayStatus, DesignWorkStatus.held);
  });
  test('플랫폼 재료비와 레이아웃은 별도 업무로 집계하고 현재 Rev 회신만 따른다', () {
    var r = savePlatformRequest(
        actor: platformActor,
        fields: platformFixture('SL-TEST'),
        kinds: PlatformReviewKind.values.toSet());
    expect(collectDesignWork().length, 2);
    r = savePlatformReply(
        actor: platformActor,
        id: r.id,
        expectedVersion: r.version,
        kind: PlatformReviewKind.material,
        status: PlatformReplyStatus.done,
        result: materialFile);
    expect(
        collectDesignWork()
            .where((w) => w.displayStatus == DesignWorkStatus.done)
            .length,
        1);
    savePlatformRequest(
        actor: platformActor,
        id: r.id,
        expectedVersion: r.version,
        fields: {...platformFixture('SL-TEST'), 'stroke': '700'},
        kinds: r.request.kinds,
        reason: '사양 변경');
    expect(
        collectDesignWork()
            .every((w) => w.displayStatus == DesignWorkStatus.unknown),
        isTrue);
  });
  test('사업부 선택과 대리점 조회 제한을 적용한다', () {
    robot();
    savePlatformRequest(
        actor: platformActor,
        fields: platformFixture('SL-TEST'),
        kinds: {PlatformReviewKind.layout});
    selectedBusinessDivision.value = RobinBusinessDivision.platformModule;
    expect(collectDesignWork().single.platformId, isNotNull);
    activateRobinAccount('kimdealer');
    expect(canReadDesignWork, isFalse);
    expect(collectDesignWork(), isEmpty);
    expect(() => other(), throwsStateError);
  });
  test('검토 상태는 현황판에서 덮어쓰지 못하며 원본 변경 시 관리 저장 충돌을 감지한다', () {
    final r = robot();
    final item = collectDesignWork().single;
    final token = item.token;
    expect(() => update(item, status: DesignWorkStatus.done), throwsStateError);
    applyRobotReview(
        key: item.robotKey!,
        expectedVersion: r.version,
        action: RobotReviewAction.start,
        role: RobotReviewRole.design,
        author: '이설계',
        projectName: r.projectName,
        content: r.content);
    expect(() => update(item, token: token, urgent: true), throwsStateError);
    expect(designWorkChanges.value, isEmpty);
  });
  test('긴급 변경은 사유/전후/담당자 이력과 To-Do를 남기고 중복 저장하지 않는다', () {
    robot();
    projectTodoItems.value = [];
    final item = collectDesignWork().single;
    expect(() => update(item, urgent: true, reason: ''), throwsStateError);
    update(item, urgent: true, reason: '고객 긴급 요청');
    expect(designWorkChanges.value[item.id]!.single.differences.single,
        contains('긴급'));
    expect(projectTodoItems.value.single.assignee, '이설계');
    expect(projectTodoItems.value.single.sourceLabel, '설계 업무관리');
    update(collectDesignWork().single, urgent: true);
    expect(designWorkChanges.value[item.id]!.length, 1);
    expect(projectTodoItems.value.length, 1);
  });
  test('기타 업무는 원본번호/유효 날짜/중복을 검사하고 관리 이력을 별도 유지한다', () {
    expect(() => other(reference: ''), throwsStateError);
    expect(() => other(due: '2026-02-30'), throwsStateError);
    final task = other();
    expect(() => other(reference: 'service-001'), throwsStateError);
    final item = collectDesignWork().single;
    update(item, status: DesignWorkStatus.held, due: '2026-11-03');
    expect(collectDesignWork().single.displayStatus, DesignWorkStatus.held);
    expect(collectDesignWork().single.displayDue, '2026-11-03');
    expect(task.due, '2026-11-02');
  });
  test('설계 직원은 타인 업무 수정/재배정과 타인 명의 등록을 하지 못한다', () {
    other(assignee: '다른 담당자');
    activateRobinAccount('engineer');
    expect(mayManageDesignItem(collectDesignWork().single), isFalse);
    expect(() => update(collectDesignWork().single, urgent: true),
        throwsStateError);
    expect(() => other(reference: 'SERVICE-002', assignee: '다른 담당자'),
        throwsStateError);
    final self =
        other(reference: 'SERVICE-002', assignee: robinUserProfile.value.name);
    final item = collectDesignWork().singleWhere((r) => r.otherId == self.id);
    expect(mayManageDesignItem(item), isTrue);
    expect(() => update(item, assignee: '다른 담당자'), throwsStateError);
  });

  Future<void> open(WidgetTester tester, {Widget? home}) async {
    await tester.binding.setSurfaceSize(const Size(1500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        home: home ?? const DesignWorkManagementScreen(orders: orders)));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('담당자·기간·긴급·유형 필터가 실제 목록을 바꾼다', (tester) async {
    robot();
    other();
    update(
        collectDesignWork().singleWhere((r) => r.kind == DesignWorkKind.other),
        urgent: true);
    await open(tester);
    expect(find.text('SO-TEST'), findsOneWidget);
    await tap(tester, find.widgetWithText(FilterChip, '긴급만'));
    expect(find.text('SO-TEST'), findsNothing);
    expect(find.text('SERVICE-001'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('기한 시작')), '2026-11-03');
    await tester.pumpAndSettle();
    expect(find.text('SERVICE-001'), findsNothing);
    await tester.enterText(find.byKey(const ValueKey('기한 시작')), '');
    await tap(tester, find.widgetWithText(FilterChip, '긴급만'));
    await tap(tester, find.byKey(const ValueKey('담당자:')));
    await tester.tap(find.text('미배정').last);
    await tester.pumpAndSettle();
    expect(find.text('SO-TEST'), findsOneWidget);
    expect(find.text('RB-TEST'), findsNothing);
    await tap(tester, find.widgetWithText(ChoiceChip, '검토 요청서'));
    expect(find.text('SO-TEST'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('기타 업무 등록 후 긴급/보류 저장과 이력이 보인다', (tester) async {
    await open(tester);
    await tap(tester, find.byKey(const ValueKey('design-add-other')));
    for (final e in {
      'reference': 'SVC-UI',
      'title': '서비스 UI',
      'assignee': '이설계',
      'due': '2026-11-02'
    }.entries) {
      await tester.enterText(find.byKey(ValueKey('other-${e.key}')), e.value);
    }
    await tap(tester, find.byKey(const ValueKey('other-create')));
    final task = collectDesignWork().single;
    await tap(tester, find.byKey(ValueKey('manage-${task.id}')));
    await tap(tester, find.byType(DropdownButtonFormField<DesignWorkStatus>));
    await tester.tap(find.text('보류').last);
    await tester.pumpAndSettle();
    await tap(tester, find.byType(CheckboxListTile));
    await tester.enterText(
        find.byKey(const ValueKey('design-reason')), '현장 보완');
    await tap(tester, find.byKey(const ValueKey('design-save')));
    expect(collectDesignWork().single.displayStatus, DesignWorkStatus.held);
    expect(collectDesignWork().single.displayUrgent, isTrue);
    expect(find.text('SVC-UI'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('열어둔 업무 팝업은 원본 변경 후 저장을 차단한다', (tester) async {
    robot();
    await open(tester);
    final item = collectDesignWork().single;
    await tap(tester, find.byKey(ValueKey('manage-${item.id}')));
    final r = robotReviewFor(item.robotKey!);
    applyRobotReview(
        key: item.robotKey!,
        expectedVersion: r.version,
        action: RobotReviewAction.start,
        role: RobotReviewRole.design,
        author: '이설계',
        projectName: r.projectName,
        content: r.content);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('design-reason')), '긴급');
    await tap(tester, find.byKey(const ValueKey('design-save')));
    expect(find.textContaining('원본/관리값이 변경'), findsOneWidget);
    expect(designWorkChanges.value, isEmpty);
  });
  testWidgets('프로젝트에서 설계 현황판을 열고 선택 수주의 설계 화면으로 복귀한다', (tester) async {
    await open(tester, home: const ProjectManagementScreen());
    await tap(tester, find.byKey(const ValueKey('open-design-work')));
    expect(find.byType(DesignWorkManagementScreen), findsOneWidget);
    await tap(tester, find.text('프로젝트 설계').first);
    expect(find.byType(DesignWorkManagementScreen), findsNothing);
    expect(find.textContaining('설계 현황 —'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('검토 원본을 바로 열고 기존 요청서 폼을 사용한다', (tester) async {
    robot();
    await open(tester);
    await tap(tester, find.text('원본'));
    expect(find.byKey(const ValueKey('review-state')), findsOneWidget);
    expect(find.textContaining('원본 고객 · 원본 로봇 프로젝트'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('현황판에서 설계 결과파일을 선택해 원본 완료 처리하면 목록도 완료로 바뀐다', (tester) async {
    final originalFiles = FileSelectorPlatform.instance;
    FileSelectorPlatform.instance = _DesignFiles();
    addTearDown(() => FileSelectorPlatform.instance = originalFiles);
    robot();
    await open(tester);
    await tap(tester, find.text('원본'));
    await tap(tester, find.byKey(const ValueKey('review-demo-role')));
    await tester.tap(find.text('설계 회신 시연').last);
    await tester.pumpAndSettle();
    await tap(tester, find.byKey(const ValueKey('review-attach-result')));
    await tester.enterText(
        find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.labelText == '도면번호'),
        'DWG-RESULT');
    await tester.enterText(
        find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.labelText == '도면 Rev'),
        'Rev.01');
    await tap(tester, find.text('첨부 추가'));
    await tester.ensureVisible(find.byKey(const ValueKey('review-reason')));
    await tester.enterText(
        find.byKey(const ValueKey('review-reason')), '설계 검토 완료');
    await tap(tester, find.byKey(const ValueKey('review-complete')));
    final r = robotReviewFor((RobinBusinessDivision.robot, 'RB-TEST'));
    expect(r.status, RobotReviewStatus.completed);
    expect(r.content.drawing!.file!.name, 'design-result.pdf');
    expect(r.history.last.snapshot.drawing!.number, 'DWG-RESULT');
    expect(collectDesignWork().single.displayStatus, DesignWorkStatus.done);
    expect(tester.takeException(), isNull);
  });

  testWidgets('플랫폼 원본 연결은 클릭한 SL을 선택한 상태로 연다', (tester) async {
    savePlatformRequest(
        actor: platformActor,
        fields: platformFixture('SL-FIRST'),
        kinds: {PlatformReviewKind.layout});
    savePlatformRequest(
        actor: platformActor,
        fields: platformFixture('SL-SECOND'),
        kinds: {PlatformReviewKind.layout});
    await open(tester);
    await tap(tester, find.text('원본').last);
    expect(find.textContaining('SL-SECOND'), findsWidgets);
    expect(find.text('SL-SECOND · 요청 Rev.1 · 전체 미확인'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
