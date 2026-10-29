import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/screens/pipeline_registration_screen.dart';
import 'package:robin_portal/screens/story_line_screens.dart';
import 'package:robin_portal/services/business_division_scope.dart';
import 'package:robin_portal/widgets/user_profile.dart';

void main() {
  final initialProfile = robinUserProfile.value;
  final initialTeams = robinTeams.value;
  setUp(() {
    robinUserProfile.value = initialProfile;
    robinTeams.value = initialTeams;
    selectedBusinessDivision.value = null;
  });
  tearDown(() {
    robinUserProfile.value = initialProfile;
    robinTeams.value = initialTeams;
    selectedBusinessDivision.value = null;
  });

  Future<void> desktop(WidgetTester tester, Widget screen) async {
    await tester.binding.setSurfaceSize(const Size(1800, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: screen)));
    await tester.pumpAndSettle();
  }

  Future<void> platform(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('business-division-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('플랫폼·모듈 사업담당').last);
    await tester.pumpAndSettle();
  }

  test('직원은 소속만, 공통조직은 양쪽, 미배정 사용자는 접근하지 못한다', () {
    activateRobinAccount('platform_staff');
    selectedBusinessDivision.value = RobinBusinessDivision.robot;
    expect(BusinessDivisionScope.current().allowed,
        {RobinBusinessDivision.platformModule});
    expect(
        BusinessDivisionScope.current().includes(RobinBusinessDivision.robot),
        isFalse);
    activateRobinAccount('staff');
    expect(
        BusinessDivisionScope.current().allowed, {RobinBusinessDivision.robot});
    robinTeams.value = [
      const RobinTeam(
        id: 'test-common',
        name: '공통',
        department: '영업',
        division: RobinBusinessDivision.common,
        memberIds: {'staff'},
      )
    ];
    expect(BusinessDivisionScope.current().allowed.length, 2);
    robinTeams.value = [];
    expect(BusinessDivisionScope.current().allowed, isEmpty);
    activateRobinAccount('kimdealer');
    expect(
        BusinessDivisionScope.current().allowed, {RobinBusinessDivision.robot});
  });

  testWidgets('파이프라인 사업부 전환은 목록·상세·고객 필터 범위를 바꾼다', (tester) async {
    await desktop(tester, const PipelineRegistrationView());
    expect(
        find.byKey(const ValueKey('proposal-order-selector')), findsOneWidget);
    expect(find.byKey(const ValueKey('assess-detail-button-RB-2608-021')),
        findsNothing);
    await platform(tester);
    expect(find.byKey(const ValueKey('assess-detail-button-RB-2608-021')),
        findsNothing);
    expect(find.byKey(const ValueKey('assess-detail-button-RB-2608-PL01')),
        findsNothing);
    expect(find.byKey(const ValueKey('platform-assess-form-RB-2608-PL01')),
        findsOneWidget);
    expect(
        find.descendant(
          of: find.byKey(const ValueKey('pipeline-overview-RB-2608-PL01')),
          matching: find.text('Assess'),
        ),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('사업부 선택은 수주·프로젝트 사이에서 유지되고 이전 상세는 사라진다', (tester) async {
    await desktop(tester, const OrderManagementScreen());
    await platform(tester);
    expect(find.text('자동화라인 증설'), findsNothing);
    expect(find.text('플랫폼 EFEM 모듈 구축'), findsOneWidget);
    await tester.pumpWidget(const MaterialApp(home: ProjectManagementScreen()));
    await tester.pumpAndSettle();
    expect(find.text('프로젝트 현황 — 2건'), findsOneWidget);
    expect(find.text('PJ-2608-001'), findsNothing);
    expect(find.text('SO-2608-014'), findsNothing);
    expect(find.text('EFEM 1호기'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('플랫폼 직원은 전환 없이 자기 데이터만 보고 미배정 시 상세를 숨긴다', (tester) async {
    activateRobinAccount('platform_staff');
    await desktop(tester, const ProjectManagementScreen());
    expect(
        find.byKey(const ValueKey('business-division-selector')), findsNothing);
    expect(find.text('프로젝트 현황 — 2건'), findsOneWidget);
    robinTeams.value = [];
    await tester.pumpAndSettle();
    expect(find.text('조회 가능한 프로젝트가 없습니다.'), findsOneWidget);
    expect(find.text('EFEM 1호기'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('전체 조회의 신규 등록은 사업부 선택을 요구한다', (tester) async {
    await desktop(tester, const PipelineRegistrationView());
    await tester.tap(find.text('신규 수주 등록'));
    await tester.pumpAndSettle();
    expect(find.text('등록 사업부 선택'), findsOneWidget);
    await tester.tap(find.text('플랫폼·모듈 사업담당').last);
    await tester.pumpAndSettle();
    expect(find.text('Assess · 필수 입력'), findsOneWidget);
    expect(find.textContaining('신규 수주 등록 · Assess'), findsOneWidget);
    expect(find.text('등록 사업부 선택'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
