import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/services/product_identity_service.dart';
import 'package:robin_portal/services/robot_proposal_service.dart';
import 'package:robin_portal/widgets/robot_proposal_workspace.dart';
import 'package:robin_portal/widgets/robot_design_review_panel.dart';
import 'package:robin_portal/widgets/user_profile.dart';
import 'robot_proposal_test.dart' show robotDemoTestBasis;

void main() {
  const key = (RobinBusinessDivision.robot, 'TEST-PROPOSAL');
  setUp(() {
    robotProposalDrafts.clear();
    proposalSpecifications.value = {};
  });
  Future<void> open(WidgetTester tester, {double width = 1000}) async {
    await tester.binding.setSurfaceSize(Size(width, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
      child: RobotProposalWorkspace(
          recordKey: key, project: '시연 프로젝트', customer: '시연 고객'),
    ))));
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await Scrollable.ensureVisible(tester.element(finder), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('축 구성·복제 의뢰 간 사양과 원본 분류를 보존한다', (tester) async {
    final part = robotProposalFor(key).requests.first.parts.first;
    part.classificationRow = 44;
    part.costInputs.addAll(robotDemoTestBasis);
    await open(tester);
    expect(find.text('필수 선택 항목'), findsOneWidget);
    expect(find.text('선택 옵션'), findsOneWidget);
    await tapVisible(tester, find.text('2축 조합'));
    expect(robotProposalFor(key).requests.first.parts.length, 2);
    expect(
        robotProposalFor(key).requests.first.parts.first.classificationRow, 44);
    await tapVisible(tester, find.text('사양 복제해 새 의뢰'));
    final requests = robotProposalFor(key).requests;
    expect(requests.length, 2);
    expect(requests.last.parts.first.classificationRow, 44);
    requests.last.parts.first.costInputs['base'] = '066N';
    expect(requests.first.parts.first.costInputs['base'], '045N');
    expect(tester.takeException(), isNull);
  });
  testWidgets('Rev 저장과 사양 계산 내역이 좁은 화면에서도 동작한다', (tester) async {
    final request = robotProposalFor(key).requests.first;
    request.parts.first.costInputs.addAll(robotDemoTestBasis);
    await open(tester, width: 480);
    final save = find.byKey(const ValueKey('robot-proposal-save-revision'));
    await tapVisible(tester, save);
    expect(request.revisions.length, 1);
    expect(request.revisions.first.cost, 3340000);
    expect(find.textContaining('Rev.01'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
  testWidgets('대분류와 검색한 중분류에 속한 소분류만 선택한다', (tester) async {
    final part = robotProposalFor(key).requests.first.parts.first;
    await open(tester);
    await tapVisible(
        tester, find.byKey(ValueKey('robot-class-major-${part.id}')));
    final major = find.text('RBC · 기구부').last;
    await tester.ensureVisible(major);
    await tester.tap(major);
    await tester.pumpAndSettle();
    final middle = find.descendant(
        of: find.byType(DropdownMenu<String>),
        matching: find.byType(TextField));
    await Scrollable.ensureVisible(tester.element(middle), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(middle);
    await tester.enterText(middle, 'RS 직각');
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('RS · RS 직각').last);
    await tester.pumpAndSettle();
    final minor = find.byKey(ValueKey('robot-class-minor-${part.id}-RS|RS 직각'));
    await tapVisible(tester, minor);
    expect(find.text('BS · B/S TYPE'), findsWidgets);
    expect(find.text('BT · BELT TYPE'), findsWidgets);
    expect(find.text('CLO · CLOID'), findsNothing);
    await tester.tap(find.text('BT · BELT TYPE').last);
    await tester.pumpAndSettle();
    expect(part.classification!.row, 56);
    expect(part.classification!.minor, 'BT');
    expect(tester.takeException(), isNull);
  });
  testWidgets('최신 저장 Rev를 설계 검토 의뢰서로 불러오며 기존 요청문을 보존한다', (tester) async {
    final profile = robinUserProfile.value;
    addTearDown(() => robinUserProfile.value = profile);
    activateRobinAccount('admin');
    final request = robotProposalFor(key).requests.first;
    request.parts.first.classificationRow = 44;
    saveRobotProposalRevision(request, author: '시험 영업');
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
      child: RobotDesignReviewPanel(
          recordKey: key,
          projectName: '시험 프로젝트',
          customer: '시험 고객',
          owner: '시험 영업',
          proposalSummary: () => robotProposalReviewSummary(key)),
    ))));
    await tester.pumpAndSettle();
    final requestField = find.byKey(const ValueKey('review-request'));
    await tester.ensureVisible(requestField);
    await tester.enterText(requestField, '고객 별도 요청');
    await tapVisible(
        tester, find.byKey(const ValueKey('review-import-proposal-revisions')));
    final text = tester.widget<TextFormField>(requestField).controller!.text;
    expect(text, contains('고객 별도 요청'));
    expect(text, contains('Rev.01'));
    expect(text, contains('RBC · 기구부 / RS · RS 직각 / BS · B/S TYPE'));
    expect(tester.takeException(), isNull);
  });
}
