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
  RobinDepartmentPermission.dealer: {0, 1, 2, 3, 5, 6, 7, 8},
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
  final bool isAdmin;
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
    required this.isAdmin,
    required this.departmentPermission,
    this.pythonGroupIds = const {},
    this.active = true,
  });

  RobinEmployee copyWith({
    String? name,
    String? rank,
    String? department,
    String? email,
    String? phone,
    bool? isAdmin,
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
        isAdmin: isAdmin ?? this.isAdmin,
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
    isAdmin: true,
    departmentPermission: RobinDepartmentPermission.hr,
  ),
  const RobinEmployee(
    id: 'staff',
    name: '박로빈',
    rank: '사원',
    department: '영업',
    email: 'robin.park@robostar.com',
    phone: '010-2345-6789',
    isAdmin: false,
    departmentPermission: RobinDepartmentPermission.sales,
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
  final String employeeId;
  final String requestType;
  final RobinDepartmentPermission? requestedDepartment;
  final String? requestedPythonGroupId;
  final String reason;
  final DateTime requestedAt;
  final PermissionRequestStatus status;

  const RobinPermissionRequest({
    required this.id,
    required this.employeeId,
    required this.requestType,
    this.requestedDepartment,
    this.requestedPythonGroupId,
    required this.reason,
    required this.requestedAt,
    this.status = PermissionRequestStatus.pending,
  });

  RobinPermissionRequest copyWith({PermissionRequestStatus? status}) =>
      RobinPermissionRequest(
        id: id,
        employeeId: employeeId,
        requestType: requestType,
        requestedDepartment: requestedDepartment,
        requestedPythonGroupId: requestedPythonGroupId,
        reason: reason,
        requestedAt: requestedAt,
        status: status ?? this.status,
      );
}

final robinPermissionRequests = ValueNotifier<List<RobinPermissionRequest>>([
  RobinPermissionRequest(
    id: 1,
    employeeId: 'staff',
    requestType: 'Python 그룹 권한',
    requestedPythonGroupId: 'sales_python',
    reason: '영업 방문차량 및 분석 업무',
    requestedAt: DateTime(2026, 7, 30, 9, 20),
  ),
  RobinPermissionRequest(
    id: 2,
    employeeId: 'new_employee',
    requestType: '최초 가입 권한',
    requestedDepartment: RobinDepartmentPermission.engineering,
    reason: '신규 입사자 기본 권한 신청',
    requestedAt: DateTime(2026, 7, 29, 16, 10),
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
