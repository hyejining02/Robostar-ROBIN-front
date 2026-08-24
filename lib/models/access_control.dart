import 'package:flutter/foundation.dart';

enum RobinDepartmentPermission {
  hr('인사'),
  sales('영업'),
  engineering('기술'),
  manufacturing('제조'),
  dealer('대리점');

  final String label;
  const RobinDepartmentPermission(this.label);
}

enum RobinAccountRole {
  admin('관리자'),
  employee('직원'),
  dealer('대리점');

  final String label;
  const RobinAccountRole(this.label);

  static RobinAccountRole fromApi(String? value) {
    switch (value?.trim().toUpperCase()) {
      case 'ADMIN':
        return RobinAccountRole.admin;
      case 'DEALER':
        return RobinAccountRole.dealer;
      default:
        return RobinAccountRole.employee;
    }
  }
}

enum RobinBusinessDivision {
  robot('로봇사업부'),
  platformModule('플랫폼·모듈 사업담당'),
  common('공통조직');

  final String label;
  const RobinBusinessDivision(this.label);
}

class RobinTeam {
  final String id;
  final String name;
  final String department;
  final RobinBusinessDivision division;
  final String? leaderId;
  final Set<String> memberIds;

  const RobinTeam({
    required this.id,
    required this.name,
    required this.department,
    required this.division,
    this.leaderId,
    this.memberIds = const {},
  });

  RobinTeam copyWith({
    String? name,
    String? department,
    RobinBusinessDivision? division,
    String? leaderId,
    Set<String>? memberIds,
  }) =>
      RobinTeam(
        id: id,
        name: name ?? this.name,
        department: department ?? this.department,
        division: division ?? this.division,
        leaderId: leaderId ?? this.leaderId,
        memberIds: memberIds ?? this.memberIds,
      );
}

class PortalTabPermission {
  final int index;
  final String label;
  final String group;

  const PortalTabPermission(this.index, this.label, this.group);
}

const portalTabPermissions = [
  PortalTabPermission(0, 'Home', '홈'),
  PortalTabPermission(1, '파이프라인 등록', '수주/프로젝트 관리'),
  PortalTabPermission(2, '수주관리', '수주/프로젝트 관리'),
  PortalTabPermission(3, '프로젝트 관리', '수주/프로젝트 관리'),
  PortalTabPermission(4, 'AX Board', 'AX Board'),
  PortalTabPermission(5, 'AI Assistant', 'AX Board'),
  PortalTabPermission(6, '공지사항', 'AX Board'),
  PortalTabPermission(7, '로그 및 이슈 조회', 'AX Board'),
  PortalTabPermission(8, '자주 묻는 질문', 'AX Board'),
];

final departmentTabPermissions =
    ValueNotifier<Map<RobinDepartmentPermission, Set<int>>>({
  RobinDepartmentPermission.hr: {0, 4, 6, 7, 8},
  RobinDepartmentPermission.sales: {0, 1, 2, 3, 4, 5, 6, 7, 8},
  RobinDepartmentPermission.engineering: {0, 3, 4, 5, 6, 7, 8},
  RobinDepartmentPermission.manufacturing: {0, 3, 4, 6, 7, 8},
  RobinDepartmentPermission.dealer: {1, 2, 3},
});

class PythonActionPermission {
  final String id;
  final String name;
  final String description;

  const PythonActionPermission({
    required this.id,
    required this.name,
    required this.description,
  });
}

class PythonAppPermission {
  final String id;
  final String name;
  final String description;
  final List<PythonActionPermission> actions;

  const PythonAppPermission({
    required this.id,
    required this.name,
    required this.description,
    required this.actions,
  });

  PythonAppPermission copyWith({
    String? name,
    String? description,
    List<PythonActionPermission>? actions,
  }) =>
      PythonAppPermission(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        actions: actions ?? this.actions,
      );
}

final pythonAppPermissions = ValueNotifier<List<PythonAppPermission>>([
  const PythonAppPermission(
    id: 'parking',
    name: '주차등록관리앱',
    description: '방문차량과 주차 등록을 관리합니다.',
    actions: [
      PythonActionPermission(
          id: 'view', name: '조회', description: '주차 등록 목록 조회'),
      PythonActionPermission(
          id: 'create', name: '생성', description: '신규 방문차량 등록'),
      PythonActionPermission(
          id: 'update', name: '수정', description: '등록된 주차 정보 수정'),
      PythonActionPermission(
          id: 'delete', name: '삭제', description: '주차 등록 정보 삭제'),
      PythonActionPermission(
          id: 'approve', name: '승인', description: '주차 신청 승인 처리'),
    ],
  ),
  const PythonAppPermission(
    id: 'production_report',
    name: '생산실적 분석앱',
    description: '생산량과 공정별 실적을 조회합니다.',
    actions: [
      PythonActionPermission(
          id: 'view', name: '조회', description: '생산실적 대시보드 조회'),
      PythonActionPermission(
          id: 'export', name: '내보내기', description: '실적 자료 Excel 내보내기'),
      PythonActionPermission(
          id: 'update', name: '수정', description: '생산실적 정보 수정'),
    ],
  ),
]);

class PythonPermissionGroup {
  final String id;
  final String name;
  final String description;
  final Map<String, Set<String>> appActionIds;

  const PythonPermissionGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.appActionIds,
  });

  PythonPermissionGroup copyWith({
    String? name,
    String? description,
    Map<String, Set<String>>? appActionIds,
  }) =>
      PythonPermissionGroup(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        appActionIds: appActionIds ?? this.appActionIds,
      );
}

final pythonPermissionGroups = ValueNotifier<List<PythonPermissionGroup>>([
  const PythonPermissionGroup(
    id: 'sales_python',
    name: '영업 Python',
    description: '영업 직원의 방문차량과 업무 분석을 위한 그룹',
    appActionIds: {
      'parking': {'view', 'create', 'update'},
      'production_report': {'view'},
    },
  ),
  const PythonPermissionGroup(
    id: 'manufacturing_python',
    name: '제조 Python',
    description: '제조 현장의 생산실적 조회와 수정을 위한 그룹',
    appActionIds: {
      'production_report': {'view', 'export', 'update'},
    },
  ),
]);

class RobinEmployee {
  final String id;
  final String name;
  final String rank;
  final String department;
  final String email;
  final String phone;
  final RobinAccountRole role;
  final RobinDepartmentPermission departmentPermission;
  final Set<String> pythonGroupIds;
  final bool active;

  const RobinEmployee({
    required this.id,
    required this.name,
    required this.rank,
    required this.department,
    required this.email,
    required this.phone,
    required this.role,
    required this.departmentPermission,
    this.pythonGroupIds = const {},
    this.active = true,
  });

  bool get isAdmin => role == RobinAccountRole.admin;
  bool get isDealer => role == RobinAccountRole.dealer;

  RobinEmployee copyWith({
    String? name,
    String? rank,
    String? department,
    String? email,
    String? phone,
    RobinAccountRole? role,
    RobinDepartmentPermission? departmentPermission,
    Set<String>? pythonGroupIds,
    bool? active,
  }) =>
      RobinEmployee(
        id: id,
        name: name ?? this.name,
        rank: rank ?? this.rank,
        department: department ?? this.department,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        departmentPermission: departmentPermission ?? this.departmentPermission,
        pythonGroupIds: pythonGroupIds ?? this.pythonGroupIds,
        active: active ?? this.active,
      );
}

final robinEmployees = ValueNotifier<List<RobinEmployee>>([
  const RobinEmployee(
    id: 'admin',
    name: '김로빈',
    rank: '책임',
    department: '인사/지원실',
    email: 'robin.kim@robostar.com',
    phone: '010-1234-5678',
    role: RobinAccountRole.admin,
    departmentPermission: RobinDepartmentPermission.hr,
  ),
  const RobinEmployee(
    id: 'staff',
    name: '박로빈',
    rank: '사원',
    department: '영업',
    email: 'robin.park@robostar.com',
    phone: '010-2345-6789',
    role: RobinAccountRole.employee,
    departmentPermission: RobinDepartmentPermission.sales,
  ),
  const RobinEmployee(
    id: 'robot_sales_staff_2',
    name: '정영업',
    rank: '대리',
    department: '영업',
    email: 'sales.jeong@robostar.com',
    phone: '010-2356-7890',
    role: RobinAccountRole.employee,
    departmentPermission: RobinDepartmentPermission.sales,
  ),
  const RobinEmployee(
    id: 'robot_sales_staff_3',
    name: '한로봇',
    rank: '사원',
    department: '영업',
    email: 'robot.han@robostar.com',
    phone: '010-2367-8901',
    role: RobinAccountRole.employee,
    departmentPermission: RobinDepartmentPermission.sales,
  ),
  const RobinEmployee(
    id: 'dealer',
    name: '이대리점',
    rank: '담당자',
    department: '서울 대리점',
    email: 'dealer.seoul@example.com',
    phone: '010-3456-7890',
    role: RobinAccountRole.dealer,
    departmentPermission: RobinDepartmentPermission.dealer,
  ),
  const RobinEmployee(
    id: 'kimdealer',
    name: '김대리점',
    rank: '담당자',
    department: '서울 대리점',
    email: 'dealer.kim@example.com',
    phone: '010-3456-7891',
    role: RobinAccountRole.dealer,
    departmentPermission: RobinDepartmentPermission.dealer,
  ),
  const RobinEmployee(
    id: 'platform_staff',
    name: '최플랫폼',
    rank: '책임',
    department: '플랫폼·모듈 영업',
    email: 'platform.choi@robostar.com',
    phone: '010-4567-8901',
    role: RobinAccountRole.employee,
    departmentPermission: RobinDepartmentPermission.sales,
  ),
  const RobinEmployee(
    id: 'engineer',
    name: '이설계',
    rank: '책임',
    department: '설계',
    email: 'engineering.lee@robostar.com',
    phone: '010-5678-9012',
    role: RobinAccountRole.employee,
    departmentPermission: RobinDepartmentPermission.engineering,
  ),
]);

final robinTeams = ValueNotifier<List<RobinTeam>>([
  const RobinTeam(
    id: 'robot_sales_1',
    name: '로봇 영업1팀',
    department: '영업',
    division: RobinBusinessDivision.robot,
    leaderId: 'staff',
    memberIds: {'staff', 'robot_sales_staff_2', 'robot_sales_staff_3'},
  ),
  const RobinTeam(
    id: 'robot_engineering_1',
    name: '로봇 설계1팀',
    department: '설계',
    division: RobinBusinessDivision.robot,
    leaderId: 'engineer',
    memberIds: {'engineer'},
  ),
  const RobinTeam(
    id: 'platform_sales',
    name: '플랫폼·모듈 영업팀',
    department: '영업',
    division: RobinBusinessDivision.platformModule,
    leaderId: 'platform_staff',
    memberIds: {'platform_staff'},
  ),
  const RobinTeam(
    id: 'common_support',
    name: '경영지원팀',
    department: '인사/지원실',
    division: RobinBusinessDivision.common,
    leaderId: 'admin',
    memberIds: {'admin'},
  ),
]);

enum PermissionRequestStatus {
  pending('승인 대기'),
  approved('승인'),
  rejected('반려');

  final String label;
  const PermissionRequestStatus(this.label);
}

class RobinPermissionRequest {
  final int id;
  final String documentNo;
  final String title;
  final String employeeId;
  final String requesterId;
  final String requestType;
  final RobinAccountRole? requestedRole;
  final RobinDepartmentPermission? requestedDepartment;
  final Set<String> requestedPythonGroupIds;
  final String reason;
  final DateTime requestedAt;
  final PermissionRequestStatus status;
  final String? decidedBy;
  final DateTime? decidedAt;
  final String? decisionNote;

  const RobinPermissionRequest({
    required this.id,
    required this.documentNo,
    required this.title,
    required this.employeeId,
    required this.requesterId,
    required this.requestType,
    this.requestedRole,
    this.requestedDepartment,
    this.requestedPythonGroupIds = const {},
    required this.reason,
    required this.requestedAt,
    this.status = PermissionRequestStatus.pending,
    this.decidedBy,
    this.decidedAt,
    this.decisionNote,
  });

  RobinPermissionRequest copyWith({
    PermissionRequestStatus? status,
    String? decidedBy,
    DateTime? decidedAt,
    String? decisionNote,
  }) =>
      RobinPermissionRequest(
        id: id,
        documentNo: documentNo,
        title: title,
        employeeId: employeeId,
        requesterId: requesterId,
        requestType: requestType,
        requestedRole: requestedRole,
        requestedDepartment: requestedDepartment,
        requestedPythonGroupIds: requestedPythonGroupIds,
        reason: reason,
        requestedAt: requestedAt,
        status: status ?? this.status,
        decidedBy: decidedBy ?? this.decidedBy,
        decidedAt: decidedAt ?? this.decidedAt,
        decisionNote: decisionNote ?? this.decisionNote,
      );
}

final robinPermissionRequests = ValueNotifier<List<RobinPermissionRequest>>([
  RobinPermissionRequest(
    id: 1,
    documentNo: 'RBN-APR-20260730-001',
    title: '영업 분석 Python 그룹 권한 신청',
    employeeId: 'staff',
    requesterId: 'staff',
    requestType: 'Python 그룹 권한',
    requestedRole: RobinAccountRole.employee,
    requestedPythonGroupIds: {'sales_python'},
    reason: '영업 방문차량 및 분석 업무',
    requestedAt: DateTime(2026, 7, 30, 9, 20),
  ),
  RobinPermissionRequest(
    id: 2,
    documentNo: 'RBN-APR-20260729-002',
    title: '신규 입사자 ROBIN 기본 권한 신청',
    employeeId: 'new_employee',
    requesterId: 'admin',
    requestType: '최초 가입 권한',
    requestedRole: RobinAccountRole.employee,
    requestedDepartment: RobinDepartmentPermission.engineering,
    reason: '신규 입사자 기본 권한 신청',
    requestedAt: DateTime(2026, 7, 29, 16, 10),
    status: PermissionRequestStatus.approved,
    decidedBy: 'admin',
    decidedAt: DateTime(2026, 7, 29, 17, 5),
    decisionNote: '설계부서 기본 권한 확인 후 승인',
  ),
]);

String employeeDisplayName(String employeeId) {
  for (final employee in robinEmployees.value) {
    if (employee.id == employeeId) return '${employee.name} ${employee.rank}';
  }
  return '최신입 사원';
}

String pythonAppName(String? appId) {
  for (final app in pythonAppPermissions.value) {
    if (app.id == appId) return app.name;
  }
  return '-';
}

String pythonGroupName(String? groupId) {
  for (final group in pythonPermissionGroups.value) {
    if (group.id == groupId) return group.name;
  }
  return '-';
}

Set<String> effectivePythonActions(RobinEmployee employee, String appId) {
  final actions = <String>{};
  for (final group in pythonPermissionGroups.value) {
    if (employee.pythonGroupIds.contains(group.id)) {
      actions.addAll(group.appActionIds[appId] ?? const <String>{});
    }
  }
  return actions;
}
