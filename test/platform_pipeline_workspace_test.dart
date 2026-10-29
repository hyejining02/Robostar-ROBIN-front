import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/services/platform_pipeline_service.dart';
import 'package:robin_portal/widgets/platform_assess_form.dart';
import 'package:robin_portal/widgets/platform_proposal_form.dart';
import 'platform_pipeline_test.dart' show completePlatformVrb;

void main() {
  setUp(platformPipelineRecords.clear);
  Future<void> open(WidgetTester t, Widget child, {double width = 1000}) async {
    await t.binding.setSurfaceSize(Size(width, 900));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
        MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child))));
    await t.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, Finder f) async {
    await Scrollable.ensureVisible(t.element(f), alignment: .5);
    await t.pumpAndSettle();
    await t.tap(f);
    await t.pumpAndSettle();
  }

  testWidgets('견적 규격은 한 줄 높이로 시작하고 엔터 줄바꿈에 따라 늘어난다', (t) async {
    final d = completePlatformVrb('MULTILINE');
    await open(
        t,
        PlatformProposalForm(
            data: d,
            onAdvance: (_) async => true,
            onDesignReview: () {},
            onSaved: () {}),
        width: 1300);
    await tap(t, find.text('② 견적서'));
    final spec =
        find.byKey(ValueKey('platform-line-${d.quoteLines.first.id}-spec-0'));
    final unit =
        find.byKey(ValueKey('platform-line-${d.quoteLines.first.id}-unit-0'));
    await t.ensureVisible(spec);
    await t.pumpAndSettle();
    expect(t.getSize(spec).height, t.getSize(unit).height);
    final initialHeight = t.getSize(spec).height;
    await t.enterText(spec, '첫 번째 사양');
    final input = t.widget<TextField>(
        find.descendant(of: spec, matching: find.byType(TextField)));
    expect(input.keyboardType, TextInputType.multiline);
    expect(input.textInputAction, TextInputAction.newline);
    await t.testTextInput.receiveAction(TextInputAction.newline);
    t.testTextInput.updateEditingValue(const TextEditingValue(
        text: '첫 번째 사양\n', selection: TextSelection.collapsed(offset: 8)));
    await t.pumpAndSettle();
    expect(d.quoteLines.first.fields['spec'], '첫 번째 사양\n');
    expect(t.getSize(spec).height, greaterThan(initialHeight));
    await t.enterText(spec, '한 줄');
    await t.pumpAndSettle();
    expect(t.getSize(spec).height, initialHeight);
    expect(t.takeException(), isNull);
  });

  testWidgets('Assess 입력 저장과 Proposal 이동이 공유 데이터에 반영된다', (t) async {
    final d = completePlatformVrb('ASSESS');
    int? stage;
    var saved = 0;
    await open(
        t,
        PlatformAssessForm(
            data: d,
            onSaved: () => saved++,
            onAdvance: (s) async {
              stage = s;
              return true;
            },
            onDesignReview: () {}),
        width: 480);
    await tap(t, find.byKey(const ValueKey('platform-assess-save')));
    expect(saved, 1);
    expect(d.units.length, 2);
    await tap(t, find.byKey(const ValueKey('platform-assess-advance')));
    expect(stage, 1);
    expect(d.titleLocked, isTrue);
    expect(t.takeException(), isNull);
  });
  testWidgets('VRB 저장 다음 견적 편집·저장으로 진행 체크까지 이동한다', (t) async {
    final d = completePlatformVrb('FORM');
    await open(
        t,
        PlatformProposalForm(
            data: d,
            onAdvance: (s) async => true,
            onDesignReview: () {},
            onSaved: () {}),
        width: 480);
    await tap(t, find.byKey(const ValueKey('platform-proposal-save-0')));
    expect(d.vrbSaved, isTrue);
    final name =
        find.byKey(ValueKey('platform-line-${d.quoteLines.first.id}-name-0'));
    await Scrollable.ensureVisible(t.element(name), alignment: .5);
    await t.enterText(name, 'EFEM 수정 견적');
    await t.pumpAndSettle();
    expect(d.vrbSaved, isTrue);
    await tap(t, find.byKey(const ValueKey('platform-proposal-save-1')));
    expect(d.quoteSaved, isTrue);
    expect(d.revisions.length, 1);
    expect(find.text('진행 체크'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('표에서 편집한 그룹명·공수가 저장 데이터와 수익성에 반영된다', (t) async {
    final d = completePlatformVrb('TABLE');
    await open(
        t,
        PlatformProposalForm(
            data: d,
            onAdvance: (s) async => true,
            onDesignReview: () {},
            onSaved: () {}),
        width: 1100);
    final group = find.byKey(const ValueKey('platform-group-0-0-TABLE'));
    await Scrollable.ensureVisible(t.element(group), alignment: .5);
    await t.pumpAndSettle();
    await t.enterText(group, '장비 구성 재료비');
    await t.pumpAndSettle();
    expect(d.groups.first.name, '장비 구성 재료비');
    final qty = find.byKey(const ValueKey('platform-cost-outside-qty-TABLE-0'));
    await Scrollable.ensureVisible(t.element(qty), alignment: .5);
    await t.pumpAndSettle();
    await t.enterText(qty, '3');
    await t.pumpAndSettle();
    expect(d.costs['outside']!.fields['qty'], '3');
    expect(d.result['op'], 51800000);
    expect(t.takeException(), isNull);
  });
}
