import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/screens/pipeline_registration_screen.dart';
import 'package:robin_portal/services/business_division_scope.dart';
import 'package:robin_portal/widgets/user_profile.dart';
import 'helpers/pipeline_navigation.dart';

void main() {
  Future<void> openPipeline(WidgetTester tester) async {
    final profile = robinUserProfile.value;
    final division = selectedBusinessDivision.value;
    await tester.binding.setSurfaceSize(const Size(1800, 1100));
    addTearDown(() async {
      robinUserProfile.value = profile;
      selectedBusinessDivision.value = division;
      await tester.binding.setSurfaceSize(null);
    });
    activateRobinAccount('admin');
    selectedBusinessDivision.value = RobinBusinessDivision.robot;
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PipelineRegistrationView())));
    await tester.pumpAndSettle();
  }

  testWidgets('목록의 다른 수주를 선택하면 입력 화면과 선택 번호가 함께 바뀐다', (tester) async {
    await openPipeline(tester);
    await selectPipelineStatus(tester, 'Proposal', number: 'RB-2608-011');
    expect(find.text('수주 입력·상세 · RB-2608-011'), findsOneWidget);
    expect(find.byKey(const ValueKey('proposal-model-RB-2608-011')),
        findsOneWidget);

    await selectPipelineStatus(tester, '전체 상태');
    expect(find.text('수주 입력·상세 · RB-2608-021'), findsOneWidget);
    expect(find.byKey(const ValueKey('proposal-model-RB-2608-021')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('로봇 단계 선택에서 Assess와 성공 실패 단계를 제외한다', (tester) async {
    await openPipeline(tester);
    await tester.tap(find.byKey(const ValueKey('pipeline-search-stage')));
    await tester.pumpAndSettle();
    final filter = tester.widget<DropdownButton<String>>(find.descendant(
        of: find.byKey(const ValueKey('pipeline-search-stage')),
        matching: find.byType(DropdownButton<String>)));
    expect(filter.items!.map((item) => item.value),
        ['전체 상태', 'Proposal', 'Negotiation']);
    expect(find.text('Closed Won'), findsNothing);
    expect(find.text('Closed Lost'), findsNothing);
    await tester.tap(find.text('전체 상태').last);
    await tester.pumpAndSettle();
    for (final number in ['RB-2608-004', 'RB-2607-031']) {
      final search = find.byKey(const ValueKey('pipeline-search-query'));
      await tester.ensureVisible(search);
      await tester.enterText(search, number);
      await tester.pumpAndSettle();
      final row = find.byKey(ValueKey('pipeline-overview-$number'));
      await Scrollable.ensureVisible(tester.element(row), alignment: .5);
      await tester.pumpAndSettle();
      await tester.tap(row);
      await tester.pumpAndSettle();
      expect(find.text('수주 입력·상세 · $number'), findsOneWidget);
      final button = tester.widget<OutlinedButton>(
          find.byKey(const ValueKey('pipeline-change-stage')));
      expect(button.onPressed, isNull);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('로봇 Proposal과 Negotiation을 실제 변경하고 사유를 남긴다', (tester) async {
    await openPipeline(tester);
    await selectPipelineStatus(tester, 'Proposal', number: 'RB-2608-014');
    for (final stage in ['Negotiation', 'Proposal']) {
      final button = find.byKey(const ValueKey('pipeline-change-stage'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(
          find.descendant(
              of: find.byType(SimpleDialogOption),
              matching: find.text('Assess')),
          findsNothing);
      await tester.tap(find.text(stage).last);
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('pipeline-stage-change-note')),
          '$stage 검토 완료');
      await tester
          .tap(find.byKey(const ValueKey('confirm-pipeline-stage-change')));
      await tester.pumpAndSettle();
      expect(find.text('수주 입력·상세 · RB-2608-014'), findsOneWidget);
      expect(find.byKey(const ValueKey('pipeline-overview-RB-2608-014')),
          findsOneWidget);
      final filter = tester.widget<DropdownButtonFormField<String>>(
          find.byKey(const ValueKey('pipeline-search-stage')));
      expect(filter.initialValue, stage);
    }
    expect(tester.takeException(), isNull);
  });
}
