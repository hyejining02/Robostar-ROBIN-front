import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/screens/app_shell.dart';
import 'package:robin_portal/screens/story_line_screens.dart';
import 'package:robin_portal/widgets/sidebar.dart';
import 'package:robin_portal/widgets/user_profile.dart';

void main() {
  test('권한 메뉴도 표시 순서를 따르되 기존 화면 번호를 유지한다', () {
    final business = portalTabPermissions
        .where((tab) => {1, 2, 3}.contains(tab.index))
        .toList();
    expect(business.map((tab) => tab.index), [1, 3, 2]);
    expect(business.map((tab) => tab.label), ['파이프라인', '프로젝트 관리', '수주 현황·재료비']);
  });

  testWidgets('변경한 메뉴 순서와 제목으로 기존 화면을 연다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1800, 1100));
    final originalProfile = robinUserProfile.value;
    addTearDown(() async {
      robinUserProfile.value = originalProfile;
      await tester.binding.setSurfaceSize(null);
    });
    activateRobinAccount('admin');
    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    await tester.pumpAndSettle();

    Finder menu(String title) => find.descendant(
        of: find.byType(RobinSidebar), matching: find.text(title));
    expect(tester.getTopLeft(menu('파이프라인')).dy,
        lessThan(tester.getTopLeft(menu('프로젝트 관리')).dy));
    expect(tester.getTopLeft(menu('프로젝트 관리')).dy,
        lessThan(tester.getTopLeft(menu('수주 현황·재료비')).dy));

    await tester.tap(menu('프로젝트 관리'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectManagementScreen), findsOneWidget);

    await tester.tap(menu('수주 현황·재료비'));
    await tester.pumpAndSettle();
    expect(find.byType(OrderManagementScreen), findsOneWidget);
    expect(find.text('수주 현황·재료비'), findsNWidgets(3));

    await tester.tap(menu('파이프라인'));
    await tester.pumpAndSettle();
    expect(find.text('파이프라인'), findsNWidgets(3));
    expect(find.text('파이프라인 등록'), findsNothing);
    expect(find.text('수주관리'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('대리점 전용 메뉴와 연결 번호는 유지한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1800, 1100));
    final originalProfile = robinUserProfile.value;
    addTearDown(() async {
      robinUserProfile.value = originalProfile;
      await tester.binding.setSurfaceSize(null);
    });
    final dealer = robinEmployees.value
        .firstWhere((employee) => employee.role == RobinAccountRole.dealer);
    activateRobinAccount(dealer.id);
    final selected = <int>[];
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body:
                RobinSidebar(selectedIndex: 1, onItemSelected: selected.add))));
    await tester.pumpAndSettle();
    for (final title in ['컨셉도면 송수신', '내 입찰', '진행단계 조회']) {
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
    }
    expect(selected, [1, 2, 3]);
    expect(find.text('수주 현황·재료비'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
