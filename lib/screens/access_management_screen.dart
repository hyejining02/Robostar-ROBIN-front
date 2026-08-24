import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show setEquals;
import 'package:intl/intl.dart';

import '../models/access_control.dart';
import '../theme/robin_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/user_profile.dart';

class EmployeeManagementScreen extends StatelessWidget {
  const EmployeeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: RobinTheme.background,
        appBar: const RobinAppBar(title: '직원 관리'),
        body: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('직원 관리', style: RobinTheme.headingLg),
                        const SizedBox(height: 5),
                        Text('포털에 등록된 직원 정보와 현재 부여된 권한을 확인합니다.',
                            style: RobinTheme.bodySm),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showEmployeeEditor(context),
                    icon: const Icon(Icons.person_add_alt_1, size: 18),
                    label: const Text('직원 등록'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ValueListenableBuilder<List<RobinEmployee>>(
                  valueListenable: robinEmployees,
                  builder: (context, employees, _) => Container(
                    decoration: _cardDecoration(),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8),
                      child: DataTable(
                        dataRowMinHeight: 64,
                        dataRowMaxHeight: 80,
                        columns: const [
                          DataColumn(label: Text('상태')),
                          DataColumn(label: Text('이름')),
                          DataColumn(label: Text('부서')),
                          DataColumn(label: Text('연락처')),
                          DataColumn(label: Text('이메일')),
                          DataColumn(label: Text('부서 권한')),
                          DataColumn(label: Text('Python 권한 그룹')),
                          DataColumn(label: Text('관리')),
                        ],
                        rows: employees.map((employee) {
                          final groups = pythonPermissionGroups.value
                              .where((group) =>
                                  employee.pythonGroupIds.contains(group.id))
                              .toList();
                          return DataRow(cells: [
                            DataCell(_statusBadge(employee.active)),
                            DataCell(Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${employee.name} ${employee.rank}',
                                    style: RobinTheme.headingSm),
                                Text(employee.role.label,
                                    style: RobinTheme.labelXs),
                              ],
                            )),
                            DataCell(Text(employee.department)),
                            DataCell(Text(employee.phone)),
                            DataCell(Text(employee.email)),
                            DataCell(_permissionChip(
                                employee.departmentPermission.label,
                                RobinTheme.primary)),
                            DataCell(groups.isEmpty
                                ? Text('미부여', style: RobinTheme.bodySm)
                                : Wrap(
                                    spacing: 5,
                                    runSpacing: 5,
                                    children: groups
                                        .map((group) => _permissionChip(
                                            group.name, RobinTheme.signalGreen))
                                        .toList(),
                                  )),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: '직원 수정·권한 변경',
                                  onPressed: () => _showEmployeeEditor(context,
                                      employee: employee),
                                  icon:
                                      const Icon(Icons.edit_outlined, size: 19),
                                ),
                                IconButton(
                                  tooltip: '직원 삭제',
                                  onPressed: () =>
                                      _confirmDelete(context, employee),
                                  icon: const Icon(Icons.delete_outline,
                                      size: 19, color: RobinTheme.error),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  static Widget _statusBadge(bool active) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? RobinTheme.successLight : RobinTheme.errorLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(active ? '정상' : '비활성',
            style: RobinTheme.labelXs.copyWith(
              color: active ? RobinTheme.signalGreen : RobinTheme.error,
              fontWeight: FontWeight.w700,
            )),
      );

  static Widget _permissionChip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: RobinTheme.labelXs
                .copyWith(color: color, fontWeight: FontWeight.w700)),
      );

  static Future<void> _showEmployeeEditor(BuildContext context,
      {RobinEmployee? employee}) async {
    final editing = employee != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: employee?.name ?? '');
    final emailController = TextEditingController(text: employee?.email ?? '');
    final phoneController = TextEditingController(text: employee?.phone ?? '');
    final approvalTitleController = TextEditingController();
    final approvalReasonController = TextEditingController();
    var rank = employee?.rank ?? '사원';
    var department = employee?.department ?? '영업';
    var departmentPermission =
        employee?.departmentPermission ?? RobinDepartmentPermission.sales;
    var role = employee?.role ?? RobinAccountRole.employee;
    var active = employee?.active ?? true;
    final currentAccount = employee?.id == robinUserProfile.value.username;
    final selectedPythonGroupIds = <String>{
      ...?employee?.pythonGroupIds,
    };
    final ranks = <String>{
      '사원',
      '대리',
      '선임',
      '책임',
      '수석',
      '팀장',
      '담당자',
      if (employee != null) employee.rank,
    }.toList();
    final departments = <String>{
      '인사/지원실',
      '영업',
      '기술',
      '제조',
      '대리점',
      if (employee != null) employee.department,
    }.toList();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(editing ? '직원 수정·권한 변경' : '직원 등록'),
          content: SizedBox(
            width: 560,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      Expanded(child: _employeeField(nameController, '이름')),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: rank,
                          decoration: const InputDecoration(
                              labelText: '직급', border: OutlineInputBorder()),
                          items: ranks
                              .map((item) => DropdownMenuItem(
                                  value: item, child: Text(item)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => rank = value);
                            }
                          },
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<RobinAccountRole>(
                      initialValue: role,
                      decoration: const InputDecoration(
                          labelText: '계정 역할', border: OutlineInputBorder()),
                      items: RobinAccountRole.values
                          .map((item) => DropdownMenuItem(
                              value: item, child: Text(item.label)))
                          .toList(),
                      onChanged: currentAccount
                          ? null
                          : (value) {
                              if (value == null) return;
                              setDialogState(() {
                                role = value;
                                if (value == RobinAccountRole.dealer) {
                                  department = '대리점';
                                  departmentPermission =
                                      RobinDepartmentPermission.dealer;
                                }
                              });
                            },
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('department-$department'),
                          initialValue: department,
                          decoration: const InputDecoration(
                              labelText: '부서', border: OutlineInputBorder()),
                          items: departments
                              .map((item) => DropdownMenuItem(
                                  value: item, child: Text(item)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => department = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child:
                            DropdownButtonFormField<RobinDepartmentPermission>(
                          key: ValueKey(
                              'department-permission-${departmentPermission.name}'),
                          initialValue: departmentPermission,
                          decoration: const InputDecoration(
                              labelText: '부서 권한', border: OutlineInputBorder()),
                          items: RobinDepartmentPermission.values
                              .map((item) => DropdownMenuItem(
                                  value: item, child: Text('${item.label} 권한')))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(
                                  () => departmentPermission = value);
                            }
                          },
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _employeeField(emailController, '이메일', email: true),
                    const SizedBox(height: 12),
                    _employeeField(phoneController, '연락처'),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Python 권한 그룹', style: RobinTheme.headingSm),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '부서 권한과 별개입니다. 직원에게 그룹을 연결하면 그룹에 설정된 앱·기능 권한이 적용됩니다.',
                      style: RobinTheme.bodySm,
                    ),
                    const SizedBox(height: 6),
                    ...pythonPermissionGroups.value.map((group) {
                      final actionCount = group.appActionIds.values
                          .fold<int>(0, (sum, ids) => sum + ids.length);
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: selectedPythonGroupIds.contains(group.id),
                        title: Text(group.name),
                        subtitle: Text(
                            '${group.description}\n앱 ${group.appActionIds.length}개 · 기능 $actionCount개'),
                        onChanged: (checked) => setDialogState(() {
                          if (checked ?? false) {
                            selectedPythonGroupIds.add(group.id);
                          } else {
                            selectedPythonGroupIds.remove(group.id);
                          }
                        }),
                      );
                    }),
                    if (editing) ...[
                      const Divider(height: 28),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('권한 변경 품의', style: RobinTheme.headingSm),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '계정 역할·부서 권한·Python 그룹이 변경되면 즉시 반영하지 않고 결재 대기 건을 생성합니다.',
                        style: RobinTheme.bodySm,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        key: const ValueKey('permission-approval-title'),
                        controller: approvalTitleController,
                        decoration: const InputDecoration(
                          labelText: '품의 제목 (권한 변경 시 필수)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final permissionChanged = role != employee.role ||
                              departmentPermission !=
                                  employee.departmentPermission ||
                              !setEquals(selectedPythonGroupIds,
                                  employee.pythonGroupIds);
                          if (permissionChanged &&
                              (value?.trim().isEmpty ?? true)) {
                            return '권한 변경 품의 제목을 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        key: const ValueKey('permission-approval-reason'),
                        controller: approvalReasonController,
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: '품의 사유 (권한 변경 시 필수)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final permissionChanged = role != employee.role ||
                              departmentPermission !=
                                  employee.departmentPermission ||
                              !setEquals(selectedPythonGroupIds,
                                  employee.pythonGroupIds);
                          if (permissionChanged &&
                              (value?.trim().isEmpty ?? true)) {
                            return '권한 변경 사유를 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                    ],
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: active,
                      title: const Text('계정 활성화'),
                      subtitle: Text(currentAccount
                          ? '현재 로그인한 계정은 비활성화할 수 없습니다.'
                          : '비활성화하면 포털에 로그인할 수 없습니다.'),
                      onChanged: currentAccount
                          ? null
                          : (value) => setDialogState(() => active = value),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('취소')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final id = employee?.id ??
                    'employee_${DateTime.now().millisecondsSinceEpoch}';
                final updated = RobinEmployee(
                  id: id,
                  name: nameController.text.trim(),
                  rank: rank,
                  department: department,
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                  role: role,
                  departmentPermission: departmentPermission,
                  pythonGroupIds: {...selectedPythonGroupIds},
                  active: active,
                );
                if (editing) {
                  final permissionChanged = role != employee.role ||
                      departmentPermission != employee.departmentPermission ||
                      !setEquals(
                          selectedPythonGroupIds, employee.pythonGroupIds);
                  final savedEmployee = permissionChanged
                      ? RobinEmployee(
                          id: updated.id,
                          name: updated.name,
                          rank: updated.rank,
                          department: updated.department,
                          email: updated.email,
                          phone: updated.phone,
                          role: employee.role,
                          departmentPermission: employee.departmentPermission,
                          pythonGroupIds: employee.pythonGroupIds,
                          active: updated.active,
                        )
                      : updated;
                  robinEmployees.value = [
                    for (final item in robinEmployees.value)
                      if (item.id == savedEmployee.id) savedEmployee else item,
                  ];
                  if (permissionChanged) {
                    final now = DateTime.now();
                    final nextId = robinPermissionRequests.value.isEmpty
                        ? 1
                        : robinPermissionRequests.value
                                .map((request) => request.id)
                                .reduce((a, b) => a > b ? a : b) +
                            1;
                    robinPermissionRequests.value = [
                      ...robinPermissionRequests.value,
                      RobinPermissionRequest(
                        id: nextId,
                        documentNo:
                            'RBN-APR-${DateFormat('yyyyMMdd').format(now)}-${nextId.toString().padLeft(3, '0')}',
                        title: approvalTitleController.text.trim(),
                        employeeId: updated.id,
                        requesterId: robinUserProfile.value.username,
                        requestType: 'ROBIN 권한 변경',
                        requestedRole: role,
                        requestedDepartment: departmentPermission,
                        requestedPythonGroupIds: {...selectedPythonGroupIds},
                        reason: approvalReasonController.text.trim(),
                        requestedAt: now,
                      ),
                    ];
                  }
                } else {
                  robinEmployees.value = [...robinEmployees.value, updated];
                }
                final appliedEmployee = robinEmployees.value
                    .firstWhere((item) => item.id == updated.id);
                if (robinUserProfile.value.username == appliedEmployee.id) {
                  robinUserProfile.value = RobinUserProfile(
                    name: appliedEmployee.name,
                    department: appliedEmployee.department,
                    rank: appliedEmployee.rank,
                    email: appliedEmployee.email,
                    phone: appliedEmployee.phone,
                    username: appliedEmployee.id,
                    role: appliedEmployee.role,
                    departmentPermission: appliedEmployee.departmentPermission,
                  );
                }
                Navigator.pop(dialogContext);
              },
              child: Text(editing ? '변경 저장' : '등록'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _employeeField(TextEditingController controller, String label,
      {bool email = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return '$label 항목을 입력해주세요.';
        if (email && !text.contains('@')) return '올바른 이메일을 입력해주세요.';
        return null;
      },
    );
  }

  static Future<void> _confirmDelete(
      BuildContext context, RobinEmployee employee) async {
    if (employee.id == robinUserProfile.value.username) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 로그인한 관리자 계정은 삭제할 수 없습니다.')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('직원 삭제'),
        content: Text('${employee.name} ${employee.rank} 계정을 삭제할까요?\n'
            '부서 권한과 Python 권한 그룹 연결도 함께 제거됩니다.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: RobinTheme.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    robinEmployees.value =
        robinEmployees.value.where((item) => item.id != employee.id).toList();
    robinPermissionRequests.value = robinPermissionRequests.value
        .where((request) => request.employeeId != employee.id)
        .toList();
    robinTeams.value = [
      for (final team in robinTeams.value)
        RobinTeam(
          id: team.id,
          name: team.name,
          department: team.department,
          division: team.division,
          leaderId: team.leaderId == employee.id ? null : team.leaderId,
          memberIds: {...team.memberIds}..remove(employee.id),
        ),
    ];
  }
}

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  static const _allDepartments = '전체 부서';
  String _department = _allDepartments;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: RobinTheme.background,
        appBar: const RobinAppBar(title: '팀 관리'),
        body: Padding(
          padding: const EdgeInsets.all(22),
          child: ValueListenableBuilder<List<RobinEmployee>>(
            valueListenable: robinEmployees,
            builder: (context, employees, _) =>
                ValueListenableBuilder<List<RobinTeam>>(
              valueListenable: robinTeams,
              builder: (context, teams, _) {
                final departments = teams
                    .map((team) => team.department)
                    .where((department) => department.trim().isNotEmpty)
                    .toSet()
                    .toList()
                  ..sort();
                final selectedDepartment = _department == _allDepartments ||
                        departments.contains(_department)
                    ? _department
                    : _allDepartments;
                final filteredTeams = selectedDepartment == _allDepartments
                    ? teams
                    : teams
                        .where((team) => team.department == selectedDepartment)
                        .toList();
                final filteredMemberIds =
                    filteredTeams.expand((team) => team.memberIds).toSet();
                final filteredEmployees = employees
                    .where(
                        (employee) => filteredMemberIds.contains(employee.id))
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('팀·사업부 관리', style: RobinTheme.headingLg),
                              const SizedBox(height: 5),
                              Text(
                                '임시 조직 데이터로 사업부, 팀장, 팀원 구성을 관리합니다.',
                                style: RobinTheme.bodySm,
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () => _showTeamEditor(context, employees),
                          icon: const Icon(Icons.group_add_outlined, size: 18),
                          label: const Text('팀 추가'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 260,
                          child: DropdownButtonFormField<String>(
                            key: const ValueKey('team-department-filter'),
                            initialValue: selectedDepartment,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: '부서',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: [_allDepartments, ...departments]
                                .map((department) => DropdownMenuItem(
                                      value: department,
                                      child: Text(department),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _department = value);
                              }
                            },
                          ),
                        ),
                        Text(
                          selectedDepartment == _allDepartments
                              ? '전체 부서의 팀과 배정 직원 ${filteredEmployees.length}명을 표시합니다.'
                              : '$selectedDepartment 부서의 팀과 배정 직원 ${filteredEmployees.length}명을 표시합니다.',
                          style: RobinTheme.bodySm,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final division in RobinBusinessDivision.values)
                          _divisionSummary(
                              division, filteredTeams, filteredEmployees),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredTeams.isEmpty
                          ? Center(
                              child: Text(
                                selectedDepartment == _allDepartments
                                    ? '등록된 팀이 없습니다.'
                                    : '$selectedDepartment 부서에 등록된 팀이 없습니다.',
                                style: RobinTheme.bodySm,
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredTeams.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) => _teamCard(
                                context,
                                filteredTeams[index],
                                employees,
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

  static Widget _divisionSummary(RobinBusinessDivision division,
      List<RobinTeam> teams, List<RobinEmployee> employees) {
    final divisionTeams =
        teams.where((team) => team.division == division).toList();
    final memberIds = divisionTeams.expand((team) => team.memberIds).toSet();
    return Container(
      width: 245,
      padding: const EdgeInsets.all(13),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _divisionColor(division).withValues(alpha: .12),
            child: Icon(Icons.account_tree_outlined,
                size: 19, color: _divisionColor(division)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(division.label, style: RobinTheme.headingSm),
                Text(
                  '팀 ${divisionTeams.length}개 · 인원 ${employees.where((employee) => memberIds.contains(employee.id)).length}명',
                  style: RobinTheme.labelXs,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _teamCard(
      BuildContext context, RobinTeam team, List<RobinEmployee> employees) {
    RobinEmployee? leader;
    for (final employee in employees) {
      if (employee.id == team.leaderId) leader = employee;
    }
    final members = employees
        .where((employee) => team.memberIds.contains(employee.id))
        .toList();
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 72,
            decoration: BoxDecoration(
              color: _divisionColor(team.division),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(team.name, style: RobinTheme.headingSm),
                    _teamBadge(
                        team.division.label, _divisionColor(team.division)),
                    _teamBadge(team.department, RobinTheme.textSecondary),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  '팀장  ${leader == null ? '미지정' : '${leader.name} ${leader.rank}'}',
                  style: RobinTheme.bodySm,
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: members.isEmpty
                      ? [Text('배정된 팀원이 없습니다.', style: RobinTheme.labelXs)]
                      : members
                          .map((member) => _teamBadge(
                              '${member.name} ${member.rank}',
                              member.id == team.leaderId
                                  ? RobinTheme.primary
                                  : RobinTheme.signalGreen))
                          .toList(),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '팀 수정',
            onPressed: () => _showTeamEditor(context, employees, team: team),
            icon: const Icon(Icons.edit_outlined, size: 19),
          ),
          IconButton(
            tooltip: '팀 삭제',
            onPressed: () => _confirmTeamDelete(context, team),
            icon: const Icon(Icons.delete_outline,
                size: 19, color: RobinTheme.error),
          ),
        ],
      ),
    );
  }

  static Widget _teamBadge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: RobinTheme.labelXs
                .copyWith(color: color, fontWeight: FontWeight.w700)),
      );

  static Color _divisionColor(RobinBusinessDivision division) =>
      switch (division) {
        RobinBusinessDivision.robot => RobinTheme.primary,
        RobinBusinessDivision.platformModule => RobinTheme.warning,
        RobinBusinessDivision.common => RobinTheme.signalGreen,
      };

  static Future<void> _showTeamEditor(
      BuildContext context, List<RobinEmployee> employees,
      {RobinTeam? team}) async {
    final eligibleEmployees = employees
        .where((employee) => !employee.isDealer && employee.active)
        .toList();
    if (eligibleEmployees.isEmpty) return;

    final editing = team != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: team?.name ?? '');
    final departmentController =
        TextEditingController(text: team?.department ?? '');
    var division = team?.division ?? RobinBusinessDivision.robot;
    var leaderId = team?.leaderId ?? eligibleEmployees.first.id;
    final memberIds = <String>{...?team?.memberIds, leaderId};

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(editing ? '팀 수정' : '팀 추가'),
          content: SizedBox(
            width: 620,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: '팀명', border: OutlineInputBorder()),
                      validator: (value) =>
                          value?.trim().isEmpty ?? true ? '팀명을 입력해주세요.' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<RobinBusinessDivision>(
                            initialValue: division,
                            decoration: const InputDecoration(
                                labelText: '사업부', border: OutlineInputBorder()),
                            items: RobinBusinessDivision.values
                                .map((item) => DropdownMenuItem(
                                    value: item, child: Text(item.label)))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() => division = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: departmentController,
                            decoration: const InputDecoration(
                                labelText: '부서', border: OutlineInputBorder()),
                            validator: (value) => value?.trim().isEmpty ?? true
                                ? '부서를 입력해주세요.'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: leaderId,
                      decoration: const InputDecoration(
                          labelText: '팀장', border: OutlineInputBorder()),
                      items: eligibleEmployees
                          .map((employee) => DropdownMenuItem(
                              value: employee.id,
                              child: Text('${employee.name} ${employee.rank}')))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          leaderId = value;
                          memberIds.add(value);
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('팀원', style: RobinTheme.headingSm),
                    ),
                    const SizedBox(height: 5),
                    ...eligibleEmployees.map((employee) => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: memberIds.contains(employee.id),
                          title: Text('${employee.name} ${employee.rank}'),
                          subtitle: Text(employee.department),
                          onChanged: employee.id == leaderId
                              ? null
                              : (checked) => setDialogState(() {
                                    if (checked ?? false) {
                                      memberIds.add(employee.id);
                                    } else {
                                      memberIds.remove(employee.id);
                                    }
                                  }),
                        )),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('취소')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final updated = RobinTeam(
                  id: team?.id ??
                      'team_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text.trim(),
                  department: departmentController.text.trim(),
                  division: division,
                  leaderId: leaderId,
                  memberIds: {...memberIds, leaderId},
                );
                robinTeams.value = editing
                    ? [
                        for (final item in robinTeams.value)
                          if (item.id == updated.id) updated else item,
                      ]
                    : [...robinTeams.value, updated];
                Navigator.pop(dialogContext);
              },
              child: Text(editing ? '변경 저장' : '추가'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
    departmentController.dispose();
  }

  static Future<void> _confirmTeamDelete(
      BuildContext context, RobinTeam team) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('팀 삭제'),
        content: Text('${team.name}을 삭제할까요? 직원 계정은 삭제되지 않습니다.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: RobinTheme.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    robinTeams.value =
        robinTeams.value.where((item) => item.id != team.id).toList();
  }
}

class PermissionManagementScreen extends StatelessWidget {
  const PermissionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: RobinTheme.background,
          appBar: const RobinAppBar(title: '권한 관리'),
          body: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('권한 관리', style: RobinTheme.headingLg),
                const SizedBox(height: 5),
                Text('포털 부서 권한과 Python 그룹·앱·기능 권한을 독립적으로 관리합니다.',
                    style: RobinTheme.bodySm),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: RobinTheme.surface,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: RobinTheme.border),
                  ),
                  child: const TabBar(
                    tabs: [
                      Tab(text: '부서 권한 관리'),
                      Tab(text: 'Python 그룹 관리'),
                      Tab(text: 'Python 앱·기능 관리'),
                      Tab(text: '권한 품의·결재 이력'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Expanded(
                  child: TabBarView(
                    children: [
                      _DepartmentPermissionPanel(),
                      _PythonGroupPanel(),
                      _PythonAppActionPanel(),
                      _PermissionRequestPanel(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _DepartmentPermissionPanel extends StatefulWidget {
  const _DepartmentPermissionPanel();

  @override
  State<_DepartmentPermissionPanel> createState() =>
      _DepartmentPermissionPanelState();
}

class _DepartmentPermissionPanelState
    extends State<_DepartmentPermissionPanel> {
  RobinDepartmentPermission _selected = RobinDepartmentPermission.sales;

  @override
  Widget build(BuildContext context) => Container(
        decoration: _cardDecoration(),
        child: Row(
          children: [
            SizedBox(
              width: 220,
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: RobinDepartmentPermission.values
                    .map((department) => ListTile(
                          selected: _selected == department,
                          selectedTileColor: RobinTheme.accentLight,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          leading: const Icon(Icons.business_outlined),
                          title: Text('${department.label} 권한'),
                          trailing: const Icon(Icons.chevron_right, size: 18),
                          onTap: () => setState(() => _selected = department),
                        ))
                    .toList(),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: ValueListenableBuilder<
                  Map<RobinDepartmentPermission, Set<int>>>(
                valueListenable: departmentTabPermissions,
                builder: (context, permissions, _) {
                  final selectedTabs = permissions[_selected] ?? {};
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text('${_selected.label} 권한 접근 탭',
                          style: RobinTheme.headingLg),
                      const SizedBox(height: 5),
                      Text('해당 권한을 가진 직원의 사이드바에 표시할 탭을 선택하세요.',
                          style: RobinTheme.bodySm),
                      const SizedBox(height: 16),
                      ...portalTabPermissions.map((tab) => CheckboxListTile(
                            value: selectedTabs.contains(tab.index),
                            contentPadding: EdgeInsets.zero,
                            title: Text(tab.label, style: RobinTheme.bodyMd),
                            subtitle:
                                Text(tab.group, style: RobinTheme.labelXs),
                            onChanged: (checked) =>
                                _toggleTab(tab.index, checked ?? false),
                          )),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );

  void _toggleTab(int index, bool enabled) {
    final next = <RobinDepartmentPermission, Set<int>>{
      for (final entry in departmentTabPermissions.value.entries)
        entry.key: {...entry.value},
    };
    final tabs = next.putIfAbsent(_selected, () => <int>{});
    enabled ? tabs.add(index) : tabs.remove(index);
    departmentTabPermissions.value = next;
  }
}

class _PythonGroupPanel extends StatefulWidget {
  const _PythonGroupPanel();

  @override
  State<_PythonGroupPanel> createState() => _PythonGroupPanelState();
}

class _PythonGroupPanelState extends State<_PythonGroupPanel> {
  String? _selectedGroupId = 'sales_python';
  String _query = '';

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<List<PythonPermissionGroup>>(
        valueListenable: pythonPermissionGroups,
        builder: (context, groups, _) {
          final filtered = groups
              .where((group) =>
                  group.name.toLowerCase().contains(_query.toLowerCase()))
              .toList();
          PythonPermissionGroup? selected;
          for (final group in groups) {
            if (group.id == _selectedGroupId) selected = group;
          }
          selected ??= groups.isEmpty ? null : groups.first;
          if (selected != null && selected.id != _selectedGroupId) {
            _selectedGroupId = selected.id;
          }

          return Container(
            decoration: _cardDecoration(),
            child: Row(
              children: [
                SizedBox(
                  width: 290,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text('Python 권한 그룹',
                                    style: RobinTheme.headingSm)),
                            FilledButton.icon(
                              onPressed: () => _showGroupEditor(context),
                              icon: const Icon(Icons.add, size: 17),
                              label: const Text('추가'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: '그룹 검색',
                            prefixIcon: Icon(Icons.search, size: 19),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) => setState(() => _query = value),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text('등록된 그룹이 없습니다.',
                                    style: RobinTheme.bodySm))
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final group = filtered[index];
                                  final actionCount = group.appActionIds.values
                                      .fold<int>(
                                          0, (sum, ids) => sum + ids.length);
                                  return ListTile(
                                    selected: group.id == selected?.id,
                                    selectedTileColor: RobinTheme.accentLight,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    leading:
                                        const Icon(Icons.group_work_outlined),
                                    title: Text(group.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    subtitle: Text(
                                        '앱 ${group.appActionIds.length}개 · 기능 $actionCount개',
                                        style: RobinTheme.labelXs),
                                    trailing: const Icon(Icons.chevron_right,
                                        size: 18),
                                    onTap: () => setState(
                                        () => _selectedGroupId = group.id),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: selected == null
                      ? const Center(child: Text('Python 권한 그룹을 추가하세요.'))
                      : _groupDetail(context, selected),
                ),
              ],
            ),
          );
        },
      );

  Widget _groupDetail(BuildContext context, PythonPermissionGroup group) =>
      ValueListenableBuilder<List<PythonAppPermission>>(
        valueListenable: pythonAppPermissions,
        builder: (context, apps, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: RobinTheme.accentLight,
                  child: Icon(Icons.group_work_outlined,
                      color: RobinTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name, style: RobinTheme.headingLg),
                      const SizedBox(height: 3),
                      Text(group.description, style: RobinTheme.bodySm),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: '그룹 정보 수정',
                  onPressed: () => _showGroupEditor(context, group: group),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: '그룹 삭제',
                  onPressed: () => _deleteGroup(context, group),
                  icon:
                      const Icon(Icons.delete_outline, color: RobinTheme.error),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RobinTheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '이 그룹을 직원에게 한 번 연결하면 아래에서 선택한 여러 앱과 기능 권한이 함께 부여됩니다. 부서 권한과는 독립적으로 적용됩니다.',
                style: RobinTheme.bodySm,
              ),
            ),
            const SizedBox(height: 16),
            Text('앱별 기능 권한', style: RobinTheme.headingSm),
            const SizedBox(height: 8),
            if (apps.isEmpty)
              Text('먼저 Python 앱·기능 관리에서 앱을 등록하세요.', style: RobinTheme.bodySm),
            ...apps.map((app) {
              final selectedActions =
                  group.appActionIds[app.id] ?? const <String>{};
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: selectedActions.isEmpty
                        ? RobinTheme.border
                        : RobinTheme.primary.withValues(alpha: .45),
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: ExpansionTile(
                  initiallyExpanded: selectedActions.isNotEmpty,
                  leading: Icon(Icons.apps_outlined,
                      color: selectedActions.isEmpty
                          ? RobinTheme.textMuted
                          : RobinTheme.primary),
                  title: Text(app.name, style: RobinTheme.headingSm),
                  subtitle: Text(
                      selectedActions.isEmpty
                          ? '미포함'
                          : '기능 ${selectedActions.length}개 허용',
                      style: RobinTheme.labelXs),
                  children: app.actions
                      .map((action) => CheckboxListTile(
                            value: selectedActions.contains(action.id),
                            title: Text(action.name),
                            subtitle: Text(
                                '${app.id}.${action.id} · ${action.description}',
                                style: RobinTheme.labelXs),
                            onChanged: (checked) => _toggleGroupAction(
                                group, app.id, action.id, checked ?? false),
                          ))
                      .toList(),
                ),
              );
            }),
          ],
        ),
      );

  void _toggleGroupAction(PythonPermissionGroup group, String appId,
      String actionId, bool enabled) {
    final mapping = <String, Set<String>>{
      for (final entry in group.appActionIds.entries)
        entry.key: {...entry.value},
    };
    final actions = mapping.putIfAbsent(appId, () => <String>{});
    enabled ? actions.add(actionId) : actions.remove(actionId);
    if (actions.isEmpty) mapping.remove(appId);
    pythonPermissionGroups.value = [
      for (final item in pythonPermissionGroups.value)
        if (item.id == group.id) item.copyWith(appActionIds: mapping) else item,
    ];
  }

  Future<void> _showGroupEditor(BuildContext context,
      {PythonPermissionGroup? group}) async {
    final name = TextEditingController(text: group?.name ?? '');
    final description = TextEditingController(text: group?.description ?? '');
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(group == null ? 'Python 권한 그룹 추가' : '그룹 정보 수정'),
        content: SizedBox(
          width: 430,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                      labelText: '그룹 이름', border: OutlineInputBorder()),
                  validator: (value) =>
                      (value?.trim().isEmpty ?? true) ? '그룹 이름을 입력해주세요.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: description,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: '설명', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (saved == true) {
      final updated = PythonPermissionGroup(
        id: group?.id ??
            'python_group_${DateTime.now().millisecondsSinceEpoch}',
        name: name.text.trim(),
        description: description.text.trim(),
        appActionIds: group?.appActionIds ?? const {},
      );
      pythonPermissionGroups.value = group == null
          ? [...pythonPermissionGroups.value, updated]
          : [
              for (final item in pythonPermissionGroups.value)
                if (item.id == group.id) updated else item,
            ];
      setState(() => _selectedGroupId = updated.id);
    }
  }

  Future<void> _deleteGroup(
      BuildContext context, PythonPermissionGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Python 권한 그룹 삭제'),
        content: Text('${group.name} 그룹을 삭제할까요?\n직원에게 연결된 해당 그룹도 해제됩니다.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: RobinTheme.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    pythonPermissionGroups.value = pythonPermissionGroups.value
        .where((item) => item.id != group.id)
        .toList();
    robinEmployees.value = [
      for (final employee in robinEmployees.value)
        employee.pythonGroupIds.contains(group.id)
            ? employee.copyWith(
                pythonGroupIds: {...employee.pythonGroupIds}..remove(group.id))
            : employee,
    ];
    setState(() => _selectedGroupId = null);
  }
}

class _PythonAppActionPanel extends StatefulWidget {
  const _PythonAppActionPanel();

  @override
  State<_PythonAppActionPanel> createState() => _PythonAppActionPanelState();
}

class _PythonAppActionPanelState extends State<_PythonAppActionPanel> {
  String? _selectedAppId = 'parking';
  String _query = '';

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<List<PythonAppPermission>>(
        valueListenable: pythonAppPermissions,
        builder: (context, apps, _) {
          final filtered = apps
              .where((app) =>
                  app.name.toLowerCase().contains(_query.toLowerCase()))
              .toList();
          PythonAppPermission? selected;
          for (final app in apps) {
            if (app.id == _selectedAppId) selected = app;
          }
          selected ??= apps.isEmpty ? null : apps.first;
          if (selected != null && selected.id != _selectedAppId) {
            _selectedAppId = selected.id;
          }
          return Container(
            decoration: _cardDecoration(),
            child: Row(
              children: [
                SizedBox(
                  width: 290,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text('Python 앱',
                                    style: RobinTheme.headingSm)),
                            FilledButton.icon(
                              onPressed: () => _showAppEditor(context),
                              icon: const Icon(Icons.add, size: 17),
                              label: const Text('추가'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: '앱 검색',
                            prefixIcon: Icon(Icons.search, size: 19),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) => setState(() => _query = value),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final app = filtered[index];
                            return ListTile(
                              selected: app.id == selected?.id,
                              selectedTileColor: RobinTheme.accentLight,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              leading: const Icon(Icons.apps_outlined),
                              title: Text(app.name,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text('기능 권한 ${app.actions.length}개',
                                  style: RobinTheme.labelXs),
                              trailing:
                                  const Icon(Icons.chevron_right, size: 18),
                              onTap: () =>
                                  setState(() => _selectedAppId = app.id),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: selected == null
                      ? const Center(child: Text('Python 앱을 추가하세요.'))
                      : _appDetail(context, selected),
                ),
              ],
            ),
          );
        },
      );

  Widget _appDetail(BuildContext context, PythonAppPermission app) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: RobinTheme.accentLight,
                child: Icon(Icons.apps_outlined, color: RobinTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.name, style: RobinTheme.headingLg),
                    const SizedBox(height: 3),
                    Text('${app.description} · 앱 코드: ${app.id}',
                        style: RobinTheme.bodySm),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showActionEditor(context, app),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('기능 권한 추가'),
              ),
              const SizedBox(width: 7),
              IconButton(
                tooltip: '앱 정보 수정',
                onPressed: () => _showAppEditor(context, app: app),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: '앱 삭제',
                onPressed: () => _deleteApp(context, app),
                icon: const Icon(Icons.delete_outline, color: RobinTheme.error),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RobinTheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '기능 코드는 Python 앱의 버튼이나 실행 기능에서 권한을 확인할 때 사용합니다. 예: ${app.id}.create',
              style: RobinTheme.bodySm,
            ),
          ),
          const SizedBox(height: 16),
          Text('기능 권한 정의', style: RobinTheme.headingSm),
          const SizedBox(height: 8),
          if (app.actions.isEmpty)
            Text('등록된 기능 권한이 없습니다.', style: RobinTheme.bodySm),
          ...app.actions.map((action) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  border: Border.all(color: RobinTheme.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.key_outlined,
                        size: 19, color: RobinTheme.primary),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 110,
                      child: Text(action.name,
                          style: RobinTheme.bodyMd
                              .copyWith(fontWeight: FontWeight.w700)),
                    ),
                    SizedBox(
                      width: 190,
                      child: SelectableText('${app.id}.${action.id}',
                          style: RobinTheme.labelXs),
                    ),
                    Expanded(
                        child:
                            Text(action.description, style: RobinTheme.bodySm)),
                    IconButton(
                      tooltip: '기능 권한 삭제',
                      onPressed: () => _deleteAction(context, app, action),
                      icon: const Icon(Icons.delete_outline,
                          size: 19, color: RobinTheme.error),
                    ),
                  ],
                ),
              )),
        ],
      );

  Future<void> _showAppEditor(BuildContext context,
      {PythonAppPermission? app}) async {
    final name = TextEditingController(text: app?.name ?? '');
    final code = TextEditingController(text: app?.id ?? '');
    final description = TextEditingController(text: app?.description ?? '');
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(app == null ? 'Python 앱 추가' : 'Python 앱 정보 수정'),
        content: SizedBox(
          width: 450,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                      labelText: '앱 이름', border: OutlineInputBorder()),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: code,
                  enabled: app == null,
                  decoration: const InputDecoration(
                    labelText: '앱 코드 (영문/숫자/밑줄)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final normalized = _normalizeCode(value ?? '');
                    if (normalized.isEmpty) return '앱 코드를 입력해주세요.';
                    if (app == null &&
                        pythonAppPermissions.value
                            .any((item) => item.id == normalized)) {
                      return '이미 사용 중인 앱 코드입니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: description,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: '설명', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (saved == true) {
      final updated = PythonAppPermission(
        id: app?.id ?? _normalizeCode(code.text),
        name: name.text.trim(),
        description: description.text.trim(),
        actions: app?.actions ?? const [],
      );
      pythonAppPermissions.value = app == null
          ? [...pythonAppPermissions.value, updated]
          : [
              for (final item in pythonAppPermissions.value)
                if (item.id == app.id) updated else item,
            ];
      setState(() => _selectedAppId = updated.id);
    }
  }

  Future<void> _showActionEditor(
      BuildContext context, PythonAppPermission app) async {
    final name = TextEditingController();
    final code = TextEditingController();
    final description = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${app.name} 기능 권한 추가'),
        content: SizedBox(
          width: 450,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                      labelText: '기능 이름 (예: 생성)', border: OutlineInputBorder()),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: code,
                  decoration: const InputDecoration(
                    labelText: '기능 코드 (예: create)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final normalized = _normalizeCode(value ?? '');
                    if (normalized.isEmpty) return '기능 코드를 입력해주세요.';
                    if (app.actions.any((action) => action.id == normalized)) {
                      return '이미 사용 중인 기능 코드입니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: description,
                  decoration: const InputDecoration(
                      labelText: '설명', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
    if (saved == true) {
      final action = PythonActionPermission(
        id: _normalizeCode(code.text),
        name: name.text.trim(),
        description: description.text.trim(),
      );
      pythonAppPermissions.value = [
        for (final item in pythonAppPermissions.value)
          if (item.id == app.id)
            item.copyWith(actions: [...item.actions, action])
          else
            item,
      ];
    }
  }

  Future<void> _deleteAction(BuildContext context, PythonAppPermission app,
      PythonActionPermission action) async {
    final confirmed = await _confirm(
      context,
      '기능 권한 삭제',
      '${action.name} (${app.id}.${action.id}) 권한을 삭제할까요?\n모든 그룹에서도 제거됩니다.',
    );
    if (!confirmed) return;
    pythonAppPermissions.value = [
      for (final item in pythonAppPermissions.value)
        if (item.id == app.id)
          item.copyWith(
              actions:
                  item.actions.where((entry) => entry.id != action.id).toList())
        else
          item,
    ];
    pythonPermissionGroups.value = [
      for (final group in pythonPermissionGroups.value)
        group.copyWith(appActionIds: {
          for (final entry in group.appActionIds.entries)
            if (entry.key != app.id)
              entry.key: {...entry.value}
            else if (({...entry.value}..remove(action.id)).isNotEmpty)
              entry.key: {...entry.value}..remove(action.id),
        }),
    ];
  }

  Future<void> _deleteApp(BuildContext context, PythonAppPermission app) async {
    final confirmed = await _confirm(
      context,
      'Python 앱 삭제',
      '${app.name} 앱과 기능 권한을 삭제할까요?\n모든 그룹의 앱 연결도 제거됩니다.',
    );
    if (!confirmed) return;
    pythonAppPermissions.value =
        pythonAppPermissions.value.where((item) => item.id != app.id).toList();
    pythonPermissionGroups.value = [
      for (final group in pythonPermissionGroups.value)
        group.copyWith(appActionIds: {
          for (final entry in group.appActionIds.entries)
            if (entry.key != app.id) entry.key: {...entry.value},
        }),
    ];
    setState(() => _selectedAppId = null);
  }

  Future<bool> _confirm(
          BuildContext context, String title, String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('취소')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: RobinTheme.error),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('삭제'),
            ),
          ],
        ),
      ) ??
      false;

  static String? _requiredValidator(String? value) =>
      (value?.trim().isEmpty ?? true) ? '필수 항목입니다.' : null;

  static String _normalizeCode(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}

class _PermissionRequestPanel extends StatelessWidget {
  const _PermissionRequestPanel();

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<List<RobinPermissionRequest>>(
        valueListenable: robinPermissionRequests,
        builder: (context, requests, _) => Container(
          decoration: _cardDecoration(),
          child: requests.isEmpty
              ? Center(child: Text('권한 신청 내역이 없습니다.', style: RobinTheme.bodySm))
              : ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    final groupNames = request.requestedPythonGroupIds
                        .map(pythonGroupName)
                        .join(', ');
                    final detail = [
                      if (request.requestedRole != null)
                        '역할 ${request.requestedRole!.label}',
                      if (request.requestedDepartment != null)
                        '${request.requestedDepartment!.label} 권한',
                      if (groupNames.isNotEmpty) 'Python $groupNames',
                    ].join(' · ');
                    final displayName = employeeDisplayName(request.employeeId);
                    final decisionHistory = request.status ==
                            PermissionRequestStatus.pending
                        ? '결재 대기'
                        : '${request.status.label}: ${employeeDisplayName(request.decidedBy ?? '')} · '
                            '${request.decidedAt == null ? '-' : DateFormat('yyyy-MM-dd HH:mm').format(request.decidedAt!)}\n'
                            '결재 의견: ${request.decisionNote ?? '-'}';
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: RobinTheme.accentLight,
                        child: Text(displayName.isEmpty ? '?' : displayName[0]),
                      ),
                      title: Text('${request.documentNo} · ${request.title}',
                          style: RobinTheme.headingSm),
                      subtitle: Text(
                        '대상 $displayName · 신청자 ${employeeDisplayName(request.requesterId)}\n'
                        '${request.requestType} · $detail\n'
                        '품의 사유: ${request.reason} · ${DateFormat('yyyy-MM-dd HH:mm').format(request.requestedAt)}\n'
                        '$decisionHistory',
                        style: RobinTheme.bodySm,
                      ),
                      isThreeLine: false,
                      trailing:
                          request.status == PermissionRequestStatus.pending
                              ? Wrap(
                                  spacing: 7,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () =>
                                          _showRejectDialog(context, request),
                                      child: const Text('반려'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          _showGrantDialog(context, request),
                                      child: const Text('권한 설정·승인'),
                                    ),
                                  ],
                                )
                              : _requestStatusBadge(request.status),
                    );
                  },
                ),
        ),
      );

  static Future<void> _showGrantDialog(
      BuildContext context, RobinPermissionRequest request) async {
    var department =
        request.requestedDepartment ?? RobinDepartmentPermission.sales;
    RobinEmployee? requestedEmployee;
    for (final employee in robinEmployees.value) {
      if (employee.id == request.employeeId) requestedEmployee = employee;
    }
    final selectedGroupIds = <String>{
      ...?requestedEmployee?.pythonGroupIds,
      ...request.requestedPythonGroupIds,
    };
    final decisionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${employeeDisplayName(request.employeeId)} 권한 설정'),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<RobinDepartmentPermission>(
                      initialValue: department,
                      decoration: const InputDecoration(
                        labelText: '부서 권한',
                        border: OutlineInputBorder(),
                      ),
                      items: RobinDepartmentPermission.values
                          .map((item) => DropdownMenuItem(
                              value: item, child: Text('${item.label} 권한')))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => department = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Python 권한 그룹', style: RobinTheme.headingSm),
                    const SizedBox(height: 4),
                    Text('부서 권한과 관계없이 필요한 Python 그룹을 선택합니다.',
                        style: RobinTheme.bodySm),
                    const SizedBox(height: 6),
                    ...pythonPermissionGroups.value.map((group) {
                      final actionCount = group.appActionIds.values
                          .fold<int>(0, (sum, ids) => sum + ids.length);
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: selectedGroupIds.contains(group.id),
                        title: Text(group.name),
                        subtitle: Text(
                          '${group.description}\n앱 ${group.appActionIds.length}개 · 기능 $actionCount개',
                          style: RobinTheme.labelXs,
                        ),
                        onChanged: (checked) => setDialogState(() {
                          if (checked ?? false) {
                            selectedGroupIds.add(group.id);
                          } else {
                            selectedGroupIds.remove(group.id);
                          }
                        }),
                      );
                    }),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const ValueKey('permission-decision-note'),
                      controller: decisionController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '결재 의견',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.trim().isEmpty ?? true
                          ? '결재 의견을 입력해주세요.'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('취소')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                _grant(request, department, selectedGroupIds,
                    decisionController.text.trim());
                Navigator.pop(dialogContext);
              },
              child: const Text('권한 부여 및 승인'),
            ),
          ],
        ),
      ),
    );
  }

  static void _grant(
      RobinPermissionRequest request,
      RobinDepartmentPermission department,
      Set<String> selectedGroupIds,
      String decisionNote) {
    final employees = [...robinEmployees.value];
    final index = employees.indexWhere((item) => item.id == request.employeeId);
    if (index >= 0) {
      employees[index] = employees[index].copyWith(
        role: request.requestedRole,
        departmentPermission: department,
        pythonGroupIds: {...selectedGroupIds},
      );
    } else {
      employees.add(RobinEmployee(
        id: request.employeeId,
        name: '최신입',
        rank: '사원',
        department: department.label,
        email: '${request.employeeId}@robostar.com',
        phone: '-',
        role: RobinAccountRole.employee,
        departmentPermission: department,
        pythonGroupIds: {...selectedGroupIds},
      ));
    }
    robinEmployees.value = employees;
    _setStatus(request, PermissionRequestStatus.approved, decisionNote);
  }

  static Future<void> _showRejectDialog(
      BuildContext context, RobinPermissionRequest request) async {
    final formKey = GlobalKey<FormState>();
    final decisionController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('권한 품의 반려'),
        content: Form(
          key: formKey,
          child: TextFormField(
            key: const ValueKey('permission-reject-note'),
            controller: decisionController,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '반려 사유',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value?.trim().isEmpty ?? true ? '반려 사유를 입력해주세요.' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: RobinTheme.error),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              _setStatus(request, PermissionRequestStatus.rejected,
                  decisionController.text.trim());
              Navigator.pop(dialogContext);
            },
            child: const Text('반려 확정'),
          ),
        ],
      ),
    );
  }

  static void _setStatus(RobinPermissionRequest request,
      PermissionRequestStatus status, String decisionNote) {
    robinPermissionRequests.value = [
      for (final item in robinPermissionRequests.value)
        if (item.id == request.id)
          item.copyWith(
            status: status,
            decidedBy: robinUserProfile.value.username,
            decidedAt: DateTime.now(),
            decisionNote: decisionNote,
          )
        else
          item,
    ];
  }

  static Widget _requestStatusBadge(PermissionRequestStatus status) {
    final color = status == PermissionRequestStatus.approved
        ? RobinTheme.signalGreen
        : RobinTheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: RobinTheme.labelXs
            .copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: RobinTheme.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: RobinTheme.border),
    );
