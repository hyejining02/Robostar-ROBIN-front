import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/screens/access_management_screen.dart';
import 'package:robin_portal/services/auth_service.dart';
import 'package:robin_portal/widgets/user_profile.dart';

void main() {
  test('김대리점 데모 계정으로 로그인한다', () async {
    final employee = robinEmployees.value.firstWhere(
      (employee) => employee.id == 'kimdealer',
    );
    expect(employee.name, '김대리점');
    expect(employee.role, RobinAccountRole.dealer);
    expect(employee.departmentPermission, RobinDepartmentPermission.dealer);

    final result = await AuthService.login('kimdealer', '1234');
    expect(result['success'], isTrue);
    expect(result['name'], '김대리점');
    expect(result['role'], 'DEALER');
    expect(
      departmentTabPermissions.value[RobinDepartmentPermission.dealer],
      {1, 2, 3},
    );
  });

  testWidgets('Python 권한 그룹 추가 다이얼로그를 열고 저장한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: PermissionManagementScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Python 그룹 관리'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    expect(find.text('Python 권한 그룹 추가'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '테스트 Python');
    await tester.tap(find.widgetWithText(FilledButton, '저장'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('테스트 Python'), findsWidgets);
  });

  testWidgets('Python 앱과 기능 권한 추가 다이얼로그를 연다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: PermissionManagementScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Python 앱·기능 관리'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('Python 앱 추가'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '취소'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, '기능 권한 추가'));
    await tester.pumpAndSettle();

    expect(find.textContaining('기능 권한 추가'), findsWidgets);
    await tester.tap(find.widgetWithText(TextButton, '취소'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('직원 권한 수정 다이얼로그를 열고 닫는다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(2200, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: EmployeeManagementScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('직원 수정·권한 변경').first);
    await tester.pumpAndSettle();
    expect(find.text('직원 수정·권한 변경'), findsWidgets);
    expect(find.byKey(const ValueKey('permission-approval-title')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('permission-approval-reason')),
        findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '취소'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('등록된 모든 직원의 수정 다이얼로그를 오류 없이 연다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(2200, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: EmployeeManagementScreen()),
    );
    await tester.pumpAndSettle();

    final employeeCount = robinEmployees.value.length;
    for (var index = 0; index < employeeCount; index++) {
      await tester.tap(find.byTooltip('직원 수정·권한 변경').at(index));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: '${robinEmployees.value[index].name} 수정창에서 오류 발생');
      expect(find.text('직원 수정·권한 변경'), findsWidgets);
      await tester.tap(find.widgetWithText(TextButton, '취소'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('권한 품의 승인 시 결재자와 의견 이력을 남긴다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1800, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final previousRequests = [...robinPermissionRequests.value];
    final previousEmployees = [...robinEmployees.value];
    addTearDown(() {
      robinPermissionRequests.value = previousRequests;
      robinEmployees.value = previousEmployees;
    });

    await tester.pumpWidget(
      const MaterialApp(home: PermissionManagementScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('권한 품의·결재 이력'));
    await tester.pumpAndSettle();
    expect(find.textContaining('RBN-APR-20260730-001'), findsOneWidget);
    expect(find.textContaining('결재 의견: 설계부서 기본 권한 확인 후 승인'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '권한 설정·승인'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('permission-decision-note')),
      '업무 목적과 신청 권한을 확인했습니다.',
    );
    await tester.tap(find.widgetWithText(FilledButton, '권한 부여 및 승인'));
    await tester.pumpAndSettle();

    final approved =
        robinPermissionRequests.value.firstWhere((request) => request.id == 1);
    expect(approved.status, PermissionRequestStatus.approved);
    expect(approved.decidedBy, robinUserProfile.value.username);
    expect(approved.decidedAt, isNotNull);
    expect(approved.decisionNote, '업무 목적과 신청 권한을 확인했습니다.');
    expect(find.textContaining('업무 목적과 신청 권한을 확인했습니다.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('직원 권한 변경은 즉시 적용하지 않고 품의 대기로 생성한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(2200, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final previousRequests = [...robinPermissionRequests.value];
    final previousEmployees = [...robinEmployees.value];
    addTearDown(() {
      robinPermissionRequests.value = previousRequests;
      robinEmployees.value = previousEmployees;
    });
    final before =
        robinEmployees.value.firstWhere((item) => item.id == 'staff');

    await tester.pumpWidget(
      const MaterialApp(home: EmployeeManagementScreen()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('직원 수정·권한 변경').at(1));
    await tester.pumpAndSettle();

    final permissionDropdown =
        find.byKey(const ValueKey('department-permission-sales'));
    await tester.ensureVisible(permissionDropdown);
    await tester.tap(permissionDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('기술 권한').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('permission-approval-title')),
      '박로빈 기술 권한 변경 품의',
    );
    await tester.enterText(
      find.byKey(const ValueKey('permission-approval-reason')),
      '설계 협업 업무 수행을 위한 권한 요청',
    );
    await tester.tap(find.widgetWithText(FilledButton, '변경 저장'));
    await tester.pumpAndSettle();

    final saved = robinEmployees.value.firstWhere((item) => item.id == 'staff');
    expect(saved.departmentPermission, before.departmentPermission);
    final request = robinPermissionRequests.value.last;
    expect(request.employeeId, 'staff');
    expect(request.status, PermissionRequestStatus.pending);
    expect(request.requestedDepartment, RobinDepartmentPermission.engineering);
    expect(request.documentNo, startsWith('RBN-APR-'));
    expect(request.title, '박로빈 기술 권한 변경 품의');
    expect(tester.takeException(), isNull);
  });

  testWidgets('관리자 직원 대리점 역할을 구분해 표시한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(2200, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: EmployeeManagementScreen()),
    );
    await tester.pumpAndSettle();

    for (final role in RobinAccountRole.values) {
      expect(find.text(role.label), findsWidgets);
    }

    final dealer = robinEmployees.value.firstWhere(
      (employee) => employee.role == RobinAccountRole.dealer,
    );
    expect(dealer.isDealer, isTrue);
    expect(dealer.isAdmin, isFalse);
  });

  testWidgets('사업부별 팀과 팀장 팀원을 표시하고 편집창을 연다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: TeamManagementScreen()),
    );
    await tester.pumpAndSettle();

    for (final division in RobinBusinessDivision.values) {
      expect(find.text(division.label), findsWidgets);
    }
    expect(find.text('로봇 영업1팀'), findsOneWidget);
    expect(find.textContaining('팀장  박로빈'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('team-department-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('설계').last);
    await tester.pumpAndSettle();

    expect(find.text('로봇 설계1팀'), findsOneWidget);
    expect(find.text('로봇 영업1팀'), findsNothing);
    expect(find.textContaining('이설계'), findsWidgets);
    expect(find.textContaining('박로빈'), findsNothing);

    await tester.tap(find.text('팀 추가').first);
    await tester.pumpAndSettle();
    expect(find.text('팀 추가'), findsWidgets);
    expect(find.text('사업부'), findsOneWidget);
    expect(find.text('팀장'), findsOneWidget);
    expect(find.text('팀원'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '취소'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
