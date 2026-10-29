import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/screens/dashboard_screen.dart';
import 'package:robin_portal/services/product_identity_service.dart';
import 'package:robin_portal/services/project_todo_service.dart';
import 'package:robin_portal/services/robot_design_review_service.dart';
import 'package:robin_portal/widgets/robot_design_review_panel.dart';
import 'package:robin_portal/widgets/user_profile.dart';

void main() {
  const recordKey = (RobinBusinessDivision.robot, 'RB-PANEL-001');
  final originalProfile = robinUserProfile.value;
  setUp(() {
    robotDesignReviews.value = {};
    proposalSpecifications.value = {};
    projectTodoItems.value = [];
    robinUserProfile.value = originalProfile;
  });
  tearDown(() {
    robinUserProfile.value = originalProfile;
    robotDesignReviews.value = {};
  });
  Future<void> open(WidgetTester tester,
      {Size size = const Size(1200, 1000)}) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: RobotDesignReviewPanel(
                      recordKey: recordKey,
                      projectName: '테스트 프로젝트',
                      customer: '테스트 고객',
                      owner: '김영업',
                      drawings: [
                        ReviewDrawing(
                            id: 'demo1',
                            fileName: 'layout.pdf',
                            number: 'DWG-01',
                            revision: 'Rev.01',
                            demo: true)
                      ],
                    ))))));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final finder = find.byKey(ValueKey(key));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String key, String value) async {
    final finder = find.byKey(ValueKey(key));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.enterText(finder, value);
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, String key, String label) async {
    await tap(tester, key);
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  testWidgets('관리자가 요청·반려·재요청·도면 연결 완료를 순서대로 시연한다', (tester) async {
    await open(tester);
    await tap(tester, 'review-submit');
    expect(find.textContaining('설계담당자을(를)'), findsOneWidget);
    await enter(tester, 'review-designer', '이설계');
    await enter(tester, 'review-due', '2026-11-01');
    await choose(tester, 'review-composition', '단축');
    await choose(tester, 'review-drive', 'B/Screw');
    await enter(tester, 'review-model', 'RS-100');
    await enter(tester, 'review-request', '컨셉 도면 검토');
    await tap(tester, 'review-submit');
    expect(robotReviewFor(recordKey).status, RobotReviewStatus.requested);
    await choose(tester, 'review-demo-role', '설계 회신 시연');
    expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('review-model')))
            .enabled,
        isFalse);
    await enter(tester, 'review-reason', '하중 보완 필요');
    await tap(tester, 'review-reject');
    expect(robotReviewFor(recordKey).status, RobotReviewStatus.rejected);
    await choose(tester, 'review-demo-role', '영업 요청 시연');
    await enter(tester, 'review-payload', '20');
    await enter(tester, 'review-reason', '고객과 하중 협의 완료');
    await tap(tester, 'review-submit');
    expect(robotReviewFor(recordKey).revision, 2);
    await choose(tester, 'review-demo-role', '설계 회신 시연');
    await tap(tester, 'review-start');
    final drawingPicker = find.byWidgetPredicate((w) =>
        w is DropdownButtonFormField<String> &&
        w.key.toString().contains('review-drawing-'));
    await tester.ensureVisible(drawingPicker);
    await tester.pumpAndSettle();
    await tester.tap(drawingPicker);
    await tester.pumpAndSettle();
    await tester.tap(find.text('layout.pdf · Rev.01 · 시연').last);
    await tester.pumpAndSettle();
    await enter(tester, 'review-reason', '도면 검토 완료');
    await tap(tester, 'review-complete');
    expect(robotReviewFor(recordKey).status, RobotReviewStatus.completed);
    expect(robotReviewFor(recordKey).history.last.snapshot.drawing!.revision,
        'Rev.01');
    expect(robotReviewFor(recordKey).history[1].reason, '하중 보완 필요');
    expect(tester.takeException(), isNull);
  });
  testWidgets('구조에 따라 입력이 바뀌며 Belt에는 OLDHAM 항목을 비활성화한다', (tester) async {
    await open(tester);
    expect(find.byKey(const ValueKey('review-combination')), findsNothing);
    await choose(tester, 'review-composition', '조합');
    expect(find.byKey(const ValueKey('review-combination')), findsOneWidget);
    await choose(tester, 'review-drive', 'Belt');
    final section = find.text('구조별 설계 특기사항 · 원본 항목');
    await tester.ensureVisible(section);
    await tester.tap(section);
    await tester.pumpAndSettle();
    final group = find.text('COUPLING');
    await tester.ensureVisible(group);
    await tester.tap(group);
    await tester.pumpAndSettle();
    final checkbox = tester.widget<CheckboxListTile>(
        find.byKey(const ValueKey('review-option-42')));
    expect(checkbox.onChanged, isNull);
    expect(find.textContaining('BELT ROBOT은 OLDHAM COUPLING 사용 불가'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('작은 화면에서도 전체 스크롤을 유지하고 임시저장을 복원한다', (tester) async {
    await open(tester, size: const Size(700, 900));
    await enter(tester, 'review-extra', '추가 사양 보존');
    await tap(tester, 'review-save');
    expect(robotReviewFor(recordKey).content.fields['extra'], '추가 사양 보존');
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpAndSettle();
    await open(tester, size: const Size(700, 900));
    expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('review-extra')))
            .controller!
            .text,
        '추가 사양 보존');
    expect(tester.takeException(), isNull);
  });
  testWidgets('검토 요청 To-Do는 원천을 구분하고 원본 요청서를 연다', (tester) async {
    applyRobotReview(
        key: recordKey,
        expectedVersion: 0,
        action: RobotReviewAction.submit,
        role: RobotReviewRole.sales,
        author: '김영업',
        projectName: '검토 투두 프로젝트',
        content: RobotReviewContent(fields: const {
          'requester': '김영업',
          'designer': '이설계',
          'due': '2026-11-01',
          'composition': '단축',
          'drive': 'B/Screw',
          'model': 'RS-100',
          'request': '구조 검토',
        }));
    await tester.binding.setSurfaceSize(const Size(1800, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    int? target;
    activateRobinAccount('engineer');
    await tester.pumpWidget(MaterialApp(
        home: DashboardScreen(onNavigate: (value) => target = value)));
    await tester.pumpAndSettle();
    final task = find.textContaining('[이설계] 설계 검토 요청');
    expect(task, findsOneWidget);
    expect(find.textContaining('설계 검토 요청서 · 김영업'), findsOneWidget);
    await tester.ensureVisible(task);
    await tester.tap(task);
    await tester.pumpAndSettle();
    expect(target, isNull);
    expect(find.byKey(const ValueKey('review-state')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
