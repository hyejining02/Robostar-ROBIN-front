import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/screens/pipeline_registration_screen.dart';
import 'package:robin_portal/services/business_division_scope.dart';
import 'package:robin_portal/services/platform_pipeline_service.dart';
import 'package:robin_portal/widgets/platform_assess_form.dart';

void main() {
  testWidgets('플랫폼 신규 수주는 빈 Assess에서 입력·저장하고 같은 건으로 Proposal에 간다', (t) async {
    final previous = selectedBusinessDivision.value;
    addTearDown(() => selectedBusinessDivision.value = previous);
    platformPipelineRecords.clear();
    selectedBusinessDivision.value = RobinBusinessDivision.platformModule;
    await t.binding.setSurfaceSize(const Size(1800, 1100));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
        const MaterialApp(home: Scaffold(body: PipelineRegistrationView())));
    await t.pumpAndSettle();
    await t.tap(find.text('신규 수주 등록'));
    await t.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    final draft =
        t.widget<PlatformAssessForm>(find.byType(PlatformAssessForm)).data;
    expect(draft.assess['customer'], isEmpty);
    expect(draft.assess['project'], isEmpty);
    expect(platformPipelineRecords.containsKey(draft.key), isFalse);
    final customer =
        find.byKey(ValueKey('platform-assess-customer-${draft.key.$2}'));
    await t.ensureVisible(customer);
    await t.enterText(customer, '신규 고객');
    await t.ensureVisible(find.text('반도체'));
    await t.tap(find.text('반도체'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('platform-equipment-add-EFEM')));
    await t.pumpAndSettle();
    final material = find.text('300mm · 웨이퍼');
    await t.ensureVisible(material);
    await t.tap(material);
    final project = find.byKey(ValueKey('platform-project-${draft.key.$2}'));
    await t.ensureVisible(project);
    await t.enterText(project, '신규 EFEM 과제');
    final save = find.byKey(const ValueKey('platform-assess-save'));
    await t.ensureVisible(save);
    await t.tap(save);
    await t.pumpAndSettle();
    expect(platformPipelineRecords[draft.key], same(draft));
    expect(draft.assessSaved, isTrue);
    expect(find.text('등록 취소'), findsNothing);
    final advance = find.byKey(const ValueKey('platform-assess-advance'));
    await t.ensureVisible(advance);
    await t.tap(advance);
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('confirm-pipeline-stage-change')));
    await t.pumpAndSettle();
    expect(find.byKey(ValueKey('platform-proposal-form-${draft.key.$2}')),
        findsOneWidget);
    expect(draft.assess['customer'], '신규 고객');
    expect(draft.projectName, '신규 EFEM 과제');
    expect(t.takeException(), isNull);
  });

  testWidgets('플랫폼 Assess 신규 등록을 취소하면 빈 수주를 저장하지 않는다', (t) async {
    final previous = selectedBusinessDivision.value;
    addTearDown(() => selectedBusinessDivision.value = previous);
    selectedBusinessDivision.value = RobinBusinessDivision.platformModule;
    platformPipelineRecords.clear();
    await t.pumpWidget(
        const MaterialApp(home: Scaffold(body: PipelineRegistrationView())));
    await t.pumpAndSettle();
    await t.tap(find.text('신규 수주 등록'));
    await t.pumpAndSettle();
    final draft =
        t.widget<PlatformAssessForm>(find.byType(PlatformAssessForm)).data;
    await t.ensureVisible(find.text('등록 취소'));
    await t.tap(find.text('등록 취소'));
    await t.pumpAndSettle();
    expect(platformPipelineRecords.containsKey(draft.key), isFalse);
    expect(find.byKey(ValueKey('platform-assess-form-${draft.key.$2}')),
        findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('플랫폼 Assess 저장 후 같은 건의 Proposal VRB 화면으로 전환한다', (tester) async {
    final previous = selectedBusinessDivision.value;
    addTearDown(() => selectedBusinessDivision.value = previous);
    platformPipelineRecords.clear();
    selectedBusinessDivision.value = RobinBusinessDivision.platformModule;
    await tester.binding.setSurfaceSize(const Size(1800, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PipelineRegistrationView())));
    await tester.pumpAndSettle();
    final material = find.text('300mm · 웨이퍼');
    await Scrollable.ensureVisible(tester.element(material), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(material);
    await tester.pumpAndSettle();
    final advance = find.byKey(const ValueKey('platform-assess-advance'));
    await tester.ensureVisible(advance);
    await tester.pumpAndSettle();
    await tester.tap(advance);
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey('confirm-pipeline-stage-change')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('platform-proposal-form-RB-2608-PL01')),
        findsOneWidget);
    expect(find.text('① VRB'), findsOneWidget);
    expect(find.text('② 견적서'), findsOneWidget);
    expect(
        platformPipelineRecords[(
          RobinBusinessDivision.platformModule,
          'RB-2608-PL01'
        )]!
            .titleLocked,
        isTrue);
    expect(tester.takeException(), isNull);
  });
}
