import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/access_control.dart';
import '../models/order_project.dart';
import '../services/project_todo_service.dart';
import '../theme/robin_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/user_profile.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: RobinTheme.background,
        appBar: const RobinAppBar(title: 'ROBIN Home'),
        body: ValueListenableBuilder<List<ProjectTodoItem>>(
          valueListenable: projectTodoItems,
          builder: (context, _, __) => ValueListenableBuilder<RobinUserProfile>(
            valueListenable: robinUserProfile,
            builder: (context, profile, _) =>
                ValueListenableBuilder<List<RobinTeam>>(
              valueListenable: robinTeams,
              builder: (context, teams, _) =>
                  ValueListenableBuilder<List<RobinEmployee>>(
                valueListenable: robinEmployees,
                builder: (context, employees, _) => LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 1200;
                    final isCommonViewer = teams.any((team) =>
                        team.division == RobinBusinessDivision.common &&
                        team.memberIds.contains(profile.username));
                    final visibleTeams = profile.isAdmin || isCommonViewer
                        ? teams
                        : teams
                            .where((team) => team.leaderId == profile.username)
                            .toList();
                    final memberDivisions = teams
                        .where(
                            (team) => team.memberIds.contains(profile.username))
                        .map((team) => team.division)
                        .toSet();
                    final todoDivisions = profile.isAdmin || isCommonViewer
                        ? const [
                            RobinBusinessDivision.robot,
                            RobinBusinessDivision.platformModule,
                          ]
                        : memberDivisions
                            .where((division) =>
                                division != RobinBusinessDivision.common)
                            .toList();
                    return SingleChildScrollView(
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
                                    Text('Home', style: RobinTheme.headingLg),
                                    const SizedBox(height: 4),
                                    Text('내가 처리할 업무를 먼저 확인하고 프로젝트 흐름을 이어가세요.',
                                        style: RobinTheme.bodySm),
                                  ],
                                ),
                              ),
                              _todoSummary(_TodoPanel.countFor(todoDivisions)),
                            ],
                          ),
                          if (visibleTeams.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _TeamWorkloadPanel(
                              teams: visibleTeams,
                              employees: employees,
                            ),
                          ],
                          const SizedBox(height: 16),
                          if (compact) ...[
                            _TodoPanel(
                              onNavigate: onNavigate,
                              divisions: todoDivisions,
                            ),
                            const SizedBox(height: 14),
                            _RightHomePanel(onNavigate: onNavigate),
                          ] else
                            SizedBox(
                              height: 660,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: _TodoPanel(
                                      onNavigate: onNavigate,
                                      divisions: todoDivisions,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    flex: 3,
                                    child:
                                        _RightHomePanel(onNavigate: onNavigate),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

  static Widget _todoSummary(int count) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: RobinTheme.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.assignment_turned_in_outlined,
                size: 19, color: Colors.white),
            const SizedBox(width: 8),
            Text('오늘 처리할 To-Do  $count건',
                style: RobinTheme.headingSm.copyWith(color: Colors.white)),
          ],
        ),
      );
}

class _TeamWorkloadPanel extends StatefulWidget {
  final List<RobinTeam> teams;
  final List<RobinEmployee> employees;

  const _TeamWorkloadPanel({required this.teams, required this.employees});

  @override
  State<_TeamWorkloadPanel> createState() => _TeamWorkloadPanelState();
}

class _TeamWorkloadPanelState extends State<_TeamWorkloadPanel> {
  static const _allDepartments = '전체 부서';
  static const _allTeams = '전체 팀';
  String _department = _allDepartments;
  String _teamId = _allTeams;

  static const _tasks = [
    _WorkloadTask('staff', '영업', '긴급'),
    _WorkloadTask('staff', '물류', '진행'),
    _WorkloadTask('staff', '마감', '대기'),
    _WorkloadTask('staff', '영업', '진행'),
    _WorkloadTask('staff', '물류', '대기'),
    _WorkloadTask('robot_sales_staff_2', '영업', '진행'),
    _WorkloadTask('robot_sales_staff_2', '마감', '대기'),
    _WorkloadTask('robot_sales_staff_3', '영업', '신규'),
    _WorkloadTask('engineer', '설계', '긴급'),
    _WorkloadTask('engineer', '설계', '지연'),
    _WorkloadTask('engineer', '설계', '진행'),
    _WorkloadTask('engineer', '설계', '진행'),
    _WorkloadTask('engineer', '설계', '대기'),
    _WorkloadTask('engineer', '설계', '대기'),
    _WorkloadTask('engineer', '설계', '진행'),
    _WorkloadTask('platform_staff', '영업', '진행'),
    _WorkloadTask('platform_staff', '영업', '대기'),
    _WorkloadTask('platform_staff', '마감', '대기'),
    _WorkloadTask('admin', '권한', '긴급'),
    _WorkloadTask('admin', '공통', '진행'),
  ];

  @override
  Widget build(BuildContext context) {
    final departments = widget.teams.map((team) => team.department).toSet()
      ..removeWhere((value) => value.trim().isEmpty);
    final sortedDepartments = departments.toList()..sort();
    final departmentTeams = _department == _allDepartments
        ? widget.teams
        : widget.teams.where((team) => team.department == _department).toList();
    final effectiveTeamId =
        departmentTeams.any((team) => team.id == _teamId) ? _teamId : _allTeams;
    final displayTeams = effectiveTeamId == _allTeams
        ? departmentTeams
        : departmentTeams.where((team) => team.id == effectiveTeamId).toList();
    final selectedMemberIds = effectiveTeamId == _allTeams
        ? <String>{}
        : displayTeams.expand((team) => team.memberIds).toSet();
    final visibleEmployees = widget.employees
        .where((employee) => selectedMemberIds.contains(employee.id))
        .toList();
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: RobinTheme.warningLight,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.groups_2_outlined,
                      color: RobinTheme.warning),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('팀별·담당자별 업무 부하 현황', style: RobinTheme.headingLg),
                      Text('관리자와 팀장은 담당 조직의 현재 To-Do 분포를 확인할 수 있습니다.',
                          style: RobinTheme.bodySm),
                    ],
                  ),
                ),
                _workloadBadge(
                    '조회 팀 ${displayTeams.length}개', RobinTheme.primary),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    key: const ValueKey('workload-department-filter'),
                    initialValue: _department,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: '부서',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [_allDepartments, ...sortedDepartments]
                        .map((value) =>
                            DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _department = value;
                        _teamId = _allTeams;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: DropdownButtonFormField<String>(
                    key: const ValueKey('workload-team-filter'),
                    initialValue: effectiveTeamId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: '팀',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: _allTeams, child: Text(_allTeams)),
                      ...departmentTeams.map((team) => DropdownMenuItem(
                          value: team.id, child: Text(team.name))),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _teamId = value);
                    },
                  ),
                ),
                Text(
                  effectiveTeamId == _allTeams
                      ? '전체 조회에서는 팀 요약만 표시합니다.'
                      : '선택한 팀의 팀원 ${visibleEmployees.length}명을 표시합니다.',
                  style: RobinTheme.bodySm,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1050
                    ? 3
                    : constraints.maxWidth >= 620
                        ? 2
                        : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 10) / columns;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final team in displayTeams)
                      SizedBox(
                        width: width,
                        child: InkWell(
                          onTap: () => setState(() => _teamId = team.id),
                          borderRadius: BorderRadius.circular(9),
                          child: _teamLoadCard(team),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          if (effectiveTeamId != _allTeams) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${displayTeams.first.name} 팀원별 업무 부하 현황',
                      style: RobinTheme.headingSm),
                  const SizedBox(height: 9),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900 ? 2 : 1;
                      final width =
                          (constraints.maxWidth - (columns - 1) * 10) / columns;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          for (final employee in visibleEmployees)
                            SizedBox(
                              width: width,
                              child: _ownerLoadRow(employee, displayTeams),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _teamLoadCard(RobinTeam team) {
    final tasks =
        _tasks.where((task) => team.memberIds.contains(task.ownerId)).toList();
    final urgent = tasks
        .where((task) => task.priority == '긴급' || task.priority == '지연')
        .length;
    final memberCount = team.memberIds.length;
    final ratio = memberCount == 0
        ? 0.0
        : (tasks.length / (memberCount * 6)).clamp(0.0, 1.0);
    final color = ratio >= .85
        ? RobinTheme.signalRed
        : ratio >= .6
            ? RobinTheme.signalYellow
            : RobinTheme.signalGreen;
    RobinEmployee? leader;
    for (final employee in widget.employees) {
      if (employee.id == team.leaderId) leader = employee;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RobinTheme.background,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: RobinTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(team.name, style: RobinTheme.headingSm)),
              _workloadBadge(team.division.label, color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '팀장 ${leader == null ? '미지정' : leader.name} · 인원 $memberCount명',
            style: RobinTheme.labelXs,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('진행 ${tasks.length}건', style: RobinTheme.bodySm),
              const Spacer(),
              Text('긴급·지연 $urgent건',
                  style: RobinTheme.labelXs.copyWith(
                      color: urgent > 0
                          ? RobinTheme.signalRed
                          : RobinTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: ratio,
            minHeight: 7,
            borderRadius: BorderRadius.circular(7),
            color: color,
            backgroundColor: RobinTheme.border,
          ),
        ],
      ),
    );
  }

  Widget _ownerLoadRow(RobinEmployee employee, List<RobinTeam> teams) {
    final tasks = _tasks.where((task) => task.ownerId == employee.id).toList();
    final urgent = tasks
        .where((task) => task.priority == '긴급' || task.priority == '지연')
        .length;
    final teamNames = teams
        .where((team) => team.memberIds.contains(employee.id))
        .map((team) => team.name)
        .join(', ');
    final loadLabel = tasks.length >= 7
        ? '과부하'
        : tasks.length >= 4
            ? '적정'
            : '여유';
    final color = loadLabel == '과부하'
        ? RobinTheme.signalRed
        : loadLabel == '적정'
            ? RobinTheme.signalYellow
            : RobinTheme.signalGreen;
    final stageCounts = <String, int>{};
    for (final task in tasks) {
      stageCounts[task.stage] = (stageCounts[task.stage] ?? 0) + 1;
    }
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: RobinTheme.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: color.withValues(alpha: .12),
            child: Text(employee.name.isEmpty ? '?' : employee.name[0],
                style: RobinTheme.headingSm.copyWith(color: color)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('${employee.name} ${employee.rank}',
                          style: RobinTheme.headingSm),
                    ),
                    _workloadBadge(loadLabel, color),
                  ],
                ),
                const SizedBox(height: 3),
                Text(teamNames,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RobinTheme.labelXs),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text('전체 ${tasks.length}건', style: RobinTheme.bodySm),
                    if (urgent > 0)
                      Text('긴급·지연 $urgent건',
                          style: RobinTheme.labelXs
                              .copyWith(color: RobinTheme.signalRed)),
                    for (final entry in stageCounts.entries)
                      Text('${entry.key} ${entry.value}',
                          style: RobinTheme.labelXs),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _workloadBadge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: RobinTheme.labelXs
                .copyWith(color: color, fontWeight: FontWeight.w700)),
      );
}

class _WorkloadTask {
  final String ownerId;
  final String stage;
  final String priority;

  const _WorkloadTask(this.ownerId, this.stage, this.priority);
}

class _TodoPanel extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  final List<RobinBusinessDivision> divisions;

  const _TodoPanel({required this.onNavigate, required this.divisions});

  static int countFor(Iterable<RobinBusinessDivision> divisions) {
    final allowed = divisions.toSet();
    final base = _TodoPanelState._items
        .where((item) => allowed.contains(item.division))
        .length;
    final project = projectTodoItems.value
        .where((item) => allowed.contains(item.division))
        .length;
    return base + project;
  }

  @override
  State<_TodoPanel> createState() => _TodoPanelState();
}

class _TodoPanelState extends State<_TodoPanel> {
  static const _allDivisions = '전체 사업부';
  String _filter = '전체';
  String _divisionFilter = _allDivisions;

  static const _items = [
    _TodoData(
        '긴급',
        'SO-2405-003',
        '물류 자동화 프로젝트',
        '구매',
        '생산',
        'BOM 장기재고 2건 확인 및 생산 예정일 입력',
        '수주 Spec. 변경: 컨베이어 길이 12m → 15m',
        '오늘 14:00',
        division: RobinBusinessDivision.robot),
    _TodoData('신규', 'SO-2405-001', '자동화 라인 구축 프로젝트', '설계', '구매',
        '설계 완료 승인 후 BOM 구매 구분 등록', '도면 Rev.03 / 안전펜스 사양 추가', '오늘 16:00',
        division: RobinBusinessDivision.robot),
    _TodoData('지연', 'SO-2405-005', '검사 장비 개선', '생산', '품질',
        '생산완료 수량 확인 후 IQC/LQC/OQC 검사계획 등록', '카메라 모델 변경 및 검사 기준 업데이트', 'D+1',
        division: RobinBusinessDivision.robot),
    _TodoData('신규', 'SO-2405-007', 'AGV 공급 건', '품질', '물류',
        '출하검사 완료 확인 및 납품처 정보 입력', '배터리 사양 48V 100Ah 확정', '08-20',
        division: RobinBusinessDivision.robot),
    _TodoData('대기', 'SO-2405-002', '스마트 팩토리 플랫폼 구축', '물류', '마감',
        '배차 생성 및 상차 완료 처리', '납품처: 창원 2공장으로 변경', '08-21',
        division: RobinBusinessDivision.platformModule),
    _TodoData('대기', 'SO-2405-006', '모듈 조립라인 공급 건', '마감', '완료',
        'ERP 거래명세서 발행 여부 확인', '변경사항 없음', '08-22',
        division: RobinBusinessDivision.platformModule),
  ];

  @override
  void initState() {
    super.initState();
    projectTodoItems.addListener(_refreshProjectTodos);
  }

  @override
  void dispose() {
    projectTodoItems.removeListener(_refreshProjectTodos);
    super.dispose();
  }

  void _refreshProjectTodos() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final allowedDivisions = widget.divisions.toSet();
    final canSwitchDivision = allowedDivisions.length > 1;
    RobinBusinessDivision? selectedDivision;
    if (allowedDivisions.length == 1) {
      selectedDivision = allowedDivisions.first;
    } else if (canSwitchDivision && _divisionFilter != _allDivisions) {
      for (final division in allowedDivisions) {
        if (division.name == _divisionFilter) selectedDivision = division;
      }
    }
    final allItems = [
      ...projectTodoItems.value.map(_TodoData.fromProject),
      ..._items,
    ];
    final divisionItems = allItems
        .where((item) =>
            allowedDivisions.contains(item.division) &&
            (selectedDivision == null || item.division == selectedDivision))
        .toList();
    final visible = _filter == '전체'
        ? divisionItems
        : divisionItems.where((item) => item.nextStage == _filter).toList();
    return Container(
      height: 660,
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: RobinTheme.primary.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.checklist_rounded,
                          color: RobinTheme.primary),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('To-Do List', style: RobinTheme.headingLg),
                          Text('이전 단계 완료 후 나에게 넘어온 프로젝트 업무',
                              style: RobinTheme.bodySm),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (canSwitchDivision)
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          key: const ValueKey('todo-division-filter'),
                          initialValue: _divisionFilter,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: '사업부',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: _allDivisions,
                              child: Text(_allDivisions),
                            ),
                            ...allowedDivisions
                                .map((division) => DropdownMenuItem(
                                      value: division.name,
                                      child: Text(division.label),
                                    )),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _divisionFilter = value);
                            }
                          },
                        ),
                      )
                    else
                      _stageBadge(
                        allowedDivisions.isEmpty
                            ? '배정 사업부 없음'
                            : allowedDivisions.first.label,
                      ),
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<String>(
                        key: const ValueKey('todo-stage-filter'),
                        initialValue: _filter,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: '업무 단계',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const ['전체', '설계', '구매', '생산', '품질', '물류', '마감']
                            .map((value) => DropdownMenuItem(
                                value: value, child: Text(value)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _filter = value);
                        },
                      ),
                    ),
                    Text('조회 ${visible.length}건', style: RobinTheme.bodySm),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('해당 사업부·단계의 To-Do가 없습니다.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = visible[index];
                      return InkWell(
                        onTap: () => widget.onNavigate(3),
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: RobinTheme.background,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                                color: item.priority == '긴급'
                                    ? RobinTheme.signalRed
                                        .withValues(alpha: .45)
                                    : RobinTheme.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _priorityBadge(item.priority),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(item.orderNo,
                                            style: RobinTheme.labelXs.copyWith(
                                                color: RobinTheme.primary,
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(width: 8),
                                        _stageBadge(
                                          item.division ==
                                                  RobinBusinessDivision.robot
                                              ? '로봇'
                                              : '플랫폼·모듈',
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(item.projectName,
                                              overflow: TextOverflow.ellipsis,
                                              style: RobinTheme.headingSm),
                                        ),
                                        Text(item.due,
                                            style: RobinTheme.labelXs),
                                      ],
                                    ),
                                    const SizedBox(height: 7),
                                    Row(
                                      children: [
                                        _stageBadge(item.previousStage,
                                            completed: true),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Icon(Icons.arrow_forward,
                                              size: 14,
                                              color: RobinTheme.textMuted),
                                        ),
                                        _stageBadge(item.nextStage),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: Text(item.task,
                                              overflow: TextOverflow.ellipsis,
                                              style: RobinTheme.bodySm),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 7),
                                    Text(item.specChange,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: RobinTheme.labelXs.copyWith(
                                            color: RobinTheme.textSecondary)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right,
                                  color: RobinTheme.textMuted),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static Widget _priorityBadge(String value) {
    final color = switch (value) {
      '긴급' || '지연' => RobinTheme.signalRed,
      '신규' => RobinTheme.primary,
      _ => RobinTheme.textMuted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(value,
          style: RobinTheme.labelXs
              .copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }

  static Widget _stageBadge(String value, {bool completed = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: (completed ? RobinTheme.signalGreen : RobinTheme.primary)
              .withValues(alpha: .1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(value,
            style: RobinTheme.labelXs.copyWith(
                color:
                    completed ? RobinTheme.signalGreen : RobinTheme.primary)),
      );
}

class _RightHomePanel extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const _RightHomePanel({required this.onNavigate});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 660,
        child: Column(
          children: [
            Expanded(
              child: _HomeListCard(
                title: '공지사항',
                icon: Icons.campaign_outlined,
                onMore: () => onNavigate(6),
                children: SampleData.notices
                    .take(3)
                    .map((notice) => _homeRow(
                        notice.title, DateFormat('MM-dd').format(notice.date)))
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _HomeListCard(
                title: '업데이트 사항',
                icon: Icons.update_outlined,
                onMore: () => onNavigate(7),
                children: ([...SampleData.updates]
                      ..sort((a, b) => b.datetime.compareTo(a.datetime)))
                    .take(3)
                    .map((update) => _homeRow(update.description,
                        DateFormat('MM-dd HH:mm').format(update.datetime),
                        label: update.orderNo))
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    RobinTheme.primary,
                    RobinTheme.primary.withValues(alpha: .78)
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome_outlined,
                          color: Colors.white, size: 19),
                      SizedBox(width: 7),
                      Text('AI Assistant',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text('“이 수주의 다음 To-Do와 납기 위험을 알려줘”',
                      style: RobinTheme.bodySm.copyWith(color: Colors.white)),
                  const SizedBox(height: 11),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => onNavigate(5),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54)),
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text('AI 챗봇 열기'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  static Widget _homeRow(String title, String date, {String? label}) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(label,
                        style: RobinTheme.labelXs
                            .copyWith(color: RobinTheme.primary)),
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: RobinTheme.bodySm),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(date, style: RobinTheme.labelXs),
          ],
        ),
      );
}

class _HomeListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onMore;
  final List<Widget> children;

  const _HomeListCard({
    required this.title,
    required this.icon,
    required this.onMore,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: RobinTheme.primary),
                const SizedBox(width: 7),
                Text(title, style: RobinTheme.headingSm),
                const Spacer(),
                TextButton(onPressed: onMore, child: const Text('더보기')),
              ],
            ),
            const SizedBox(height: 6),
            ...children,
          ],
        ),
      );
}

class _TodoData {
  final String priority;
  final String orderNo;
  final String projectName;
  final String previousStage;
  final String nextStage;
  final String task;
  final String specChange;
  final String due;
  final RobinBusinessDivision division;

  const _TodoData(this.priority, this.orderNo, this.projectName,
      this.previousStage, this.nextStage, this.task, this.specChange, this.due,
      {required this.division});

  factory _TodoData.fromProject(ProjectTodoItem item) => _TodoData(
        '신규',
        item.orderNo,
        item.projectName,
        item.stage,
        item.stage,
        '[${item.assignee}] ${item.task}',
        '프로젝트 메모 자동 생성 · ${item.createdBy}',
        '신규',
        division: item.division,
      );
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: RobinTheme.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: RobinTheme.border),
    );
