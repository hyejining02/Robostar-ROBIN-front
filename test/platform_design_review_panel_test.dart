import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/screens/pipeline_registration_screen.dart';
import 'package:robin_portal/services/business_division_scope.dart';
import 'package:robin_portal/services/platform_pipeline_service.dart';
import 'package:robin_portal/services/platform_review_service.dart';
import 'package:robin_portal/services/project_todo_service.dart';
import 'package:robin_portal/widgets/platform_review_workspace.dart';
import 'platform_pipeline_test.dart' show completePlatformVrb;

void main() {
  setUp(() {
    selectedBusinessDivision.value = RobinBusinessDivision.platformModule;
    platformPipelineRecords.clear();
    platformReviews.value = [];
    projectTodoItems.value = [];
  });
  tearDown(() => selectedBusinessDivision.value = null);

  Future<void> tap(WidgetTester t, Finder finder) async {
    await t.ensureVisible(finder);
    await t.pumpAndSettle();
    await t.tap(finder);
    await t.pumpAndSettle();
  }

  testWidgets('파이프라인 상단 검토함을 제거하고 Assess 버튼으로 수주별 HTML 양식을 연다', (t) async {
    await t.binding.setSurfaceSize(const Size(1700, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
        const MaterialApp(home: Scaffold(body: PipelineRegistrationView())));
    await t.pumpAndSettle();
    expect(find.byType(PlatformReviewWorkspace), findsNothing);
    expect(find.text('플랫폼 수주 전 검토 · SL CODE'), findsNothing);
    await tap(t, find.byKey(const ValueKey('platform-open-design-review')));
    expect(find.byType(PlatformDesignReviewPanel), findsOneWidget);
    expect(find.text('요청 유형 *'), findsOneWidget);
    expect(find.text('재료비 + Layout'), findsOneWidget);
    expect(find.text('① 설계 요청'), findsOneWidget);
    expect(find.text('② 사양 Q&A'), findsOneWidget);
    expect(find.text('③ 자료실'), findsOneWidget);
    expect(find.text('④ 재료비 버전'), findsOneWidget);
    expect(find.textContaining('RB-2608-PL01'), findsWidgets);
    await t.tap(find.byTooltip('설계 검토 닫기'));
    await t.pumpAndSettle();
    expect(find.byType(PlatformDesignReviewPanel), findsNothing);
    expect(find.byKey(const ValueKey('platform-open-design-review')),
        findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('HTML 요청 양식에서 유형·대상·일자·내용을 저장하고 같은 수주에 추가 요청한다', (t) async {
    final data = PlatformPipelineData(
        (RobinBusinessDivision.platformModule, 'DESIGN'),
        customer: '검토 고객', project: 'EFEM 과제', owner: '김영업');
    data.revisions.add(PlatformProposalRevision(3, '김영업', '{}'));
    data.assessSaved = true;
    data.designer = '이설계 책임';
    await t.binding.setSurfaceSize(const Size(1100, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: PlatformDesignReviewPanel(data: data)))));
    await t.pumpAndSettle();
    await tap(t, find.byKey(const ValueKey('platform-design-target-0')));
    await t.tap(find.textContaining('Rev.3 (').last);
    await t.pumpAndSettle();
    final input = find.byKey(const ValueKey('platform-design-request-text'));
    await t.ensureVisible(input);
    await t.enterText(input, 'TR 2대 재료비와 Layout 검토 요청');
    await tap(t, find.byKey(const ValueKey('platform-design-send')));
    expect(platformReviews.value.length, 1);
    expect(
        platformReviews.value.single.request.fields['pipeline'], data.key.$2);
    expect(platformReviews.value.single.request.fields['project'],
        data.projectName);
    expect(platformReviews.value.single.request.kinds.length, 2);
    expect(platformReviews.value.single.request.fields['targetRevision'], '3');
    expect(projectTodoItems.value.last.assignee, data.designer);
    await tap(t, find.text('+ 설계 검토 요청'));
    await tap(t, find.widgetWithText(ChoiceChip, 'Layout'));
    await t.ensureVisible(input);
    await t.enterText(input, 'Layout 추가 검토');
    await tap(t, find.byKey(const ValueKey('platform-design-send')));
    expect(platformReviews.value.length, 2);
    expect(
        platformReviews.value.last.request.kinds, {PlatformReviewKind.layout});
    expect(platformReviews.value.first.request.fields['spec'],
        'TR 2대 재료비와 Layout 검토 요청');
    expect(t.takeException(), isNull);
  });

  testWidgets('미저장 Assess는 검토 요청을 막고 Q&A는 수주별로 보존한다', (t) async {
    final data = completePlatformVrb('DRAFT');
    data.designer = '이설계 책임';
    await t.binding.setSurfaceSize(const Size(700, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: PlatformDesignReviewPanel(data: data)))));
    await t.pumpAndSettle();
    await tap(t, find.byKey(const ValueKey('platform-design-send')));
    expect(platformReviews.value, isEmpty);
    expect(find.textContaining('Assess를 먼저 저장'), findsOneWidget);
    await tap(t, find.byKey(const ValueKey('platform-design-tab-1')));
    final input = find.byKey(const ValueKey('platform-design-question'));
    await t.ensureVisible(input);
    await t.enterText(input, 'Dual arm 여부 확인 부탁드립니다.');
    await tap(t, find.text('질문 등록'));
    expect(data.designQuestions.single.text, 'Dual arm 여부 확인 부탁드립니다.');
    await tap(t, find.byKey(const ValueKey('platform-design-tab-2')));
    expect(find.text('등록된 자료가 없습니다.'), findsOneWidget);
    await tap(t, find.byKey(const ValueKey('platform-design-tab-3')));
    expect(find.text('아직 재료비 회신이 없습니다.'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
