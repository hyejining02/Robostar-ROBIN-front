import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/access_control.dart';
import '../models/order_project.dart';
import '../services/project_todo_service.dart';
import '../theme/robin_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/user_profile.dart';

final ValueNotifier<Set<String>> _completedTodoIds =
    ValueNotifier<Set<String>>(<String>{});

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
                      padding: const EdgeInsets.all(16),
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
                            ],
                          ),
                          if (visibleTeams.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _OrganizationDashboard(
                              teams: visibleTeams,
                              employees: employees,
                            ),
                          ],
                          const SizedBox(height: 10),
                          if (compact) ...[
                            _TodoPanel(
                              onNavigate: onNavigate,
                              divisions: todoDivisions,
                            ),
                            const SizedBox(height: 10),
                            _RightHomePanel(onNavigate: onNavigate),
                          ] else
                            SizedBox(
                              height: 590,
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
                                  const SizedBox(width: 10),
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
}

class _OrganizationDashboard extends StatefulWidget {
  final List<RobinTeam> teams;
  final List<RobinEmployee> employees;

  const _OrganizationDashboard({
    required this.teams,
    required this.employees,
  });

  @override
  State<_OrganizationDashboard> createState() => _OrganizationDashboardState();
}

class _OrganizationDashboardState extends State<_OrganizationDashboard> {
  RobinBusinessDivision? _division;

  @override
  Widget build(BuildContext context) {
    final filteredTeams = _division == null
        ? widget.teams
        : widget.teams.where((team) => team.division == _division).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('조직 현황판', style: RobinTheme.headingSm),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: RobinTheme.border),
              ),
              child: Wrap(
                spacing: 2,
                children: [
                  _divisionButton(null, '전체'),
                  _divisionButton(RobinBusinessDivision.robot, '로봇사업부'),
                  _divisionButton(
                      RobinBusinessDivision.platformModule, '플랫폼·모듈'),
                  _divisionButton(RobinBusinessDivision.common, '공통조직'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const _HomeKpiStrip(),
        const SizedBox(height: 10),
        const _ValueChainLoadPanel(),
        const SizedBox(height: 10),
        _TeamWorkloadPanel(
          teams: filteredTeams,
          employees: widget.employees,
        ),
      ],
    );
  }

  Widget _divisionButton(RobinBusinessDivision? value, String label) {
    final selected = _division == value;
    return InkWell(
      key: ValueKey('workload-division-${value?.name ?? 'all'}'),
      onTap: () => setState(() => _division = value),
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? RobinTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: RobinTheme.labelXs.copyWith(
            color: selected ? Colors.white : RobinTheme.textPrimary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _HomeKpiStrip extends StatelessWidget {
  const _HomeKpiStrip();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          const items = [
            ('이번 주 수주', '12건', '↑ 전주 대비 +3', RobinTheme.primary),
            ('납기 위험', '4건', 'RED 2건 · AMBER 2건', RobinTheme.warning),
            ('이번 달 수주 확정', '23건', '목표 대비 92%', RobinTheme.signalGreen),
            ('결재 대기', '3건', 'Negotiation 승인 필요', RobinTheme.pending),
          ];
          final columns = constraints.maxWidth < 760 ? 2 : 4;
          final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in items)
                SizedBox(
                  width: width,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: item.$4.withValues(alpha: .055),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: item.$4.withValues(alpha: .75)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$1, style: RobinTheme.labelXs),
                        const SizedBox(height: 4),
                        Text(item.$2,
                            style:
                                RobinTheme.numericMd.copyWith(color: item.$4)),
                        const SizedBox(height: 4),
                        Text(item.$3,
                            style: RobinTheme.labelXs.copyWith(color: item.$4)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      );
}

class _ValueChainLoadPanel extends StatelessWidget {
  const _ValueChainLoadPanel();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('설계', 32, 20, 8, 4),
      ('구매', 28, 16, 7, 5),
      ('생산', 18, 10, 4, 4),
      ('품질', 12, 8, 2, 2),
      ('물류', 9, 6, 2, 1),
      ('마감', 6, 4, 1, 1),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('밸류체인별 To-Do 업무 로드', style: RobinTheme.headingSm),
              const Spacer(),
              _workloadTag('ERP 담당자 배정 기준', RobinTheme.primary),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 850 ? 3 : 6;
              final width =
                  (constraints.maxWidth - (columns - 1) * 7) / columns;
              return Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: width,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 7),
                        decoration: BoxDecoration(
                          color: RobinTheme.background,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: RobinTheme.border),
                        ),
                        child: Column(
                          children: [
                            Text(item.$1, style: RobinTheme.headingSm),
                            const SizedBox(height: 4),
                            Text('${item.$2}', style: RobinTheme.numericMd),
                            const SizedBox(height: 4),
                            Text(
                                '정상 ${item.$3} · 주의 ${item.$4} · 위험 ${item.$5}',
                                style: RobinTheme.labelXs.copyWith(
                                  color: item.$5 >= 4
                                      ? RobinTheme.signalRed
                                      : RobinTheme.textMuted,
                                )),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TeamWorkloadPanel extends StatefulWidget {
  final List<RobinTeam> teams;
  final List<RobinEmployee> employees;

  const _TeamWorkloadPanel({required this.teams, required this.employees});

  @override
  State<_TeamWorkloadPanel> createState() => _TeamWorkloadPanelState();
}

class _TeamWorkloadPanelState extends State<_TeamWorkloadPanel> {
  final ScrollController _memberScrollController = ScrollController();

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
  void dispose() {
    _memberScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayTeams = widget.teams;
    final selectedMemberIds =
        displayTeams.expand((team) => team.memberIds).toSet();
    final visibleEmployees = widget.employees
        .where((employee) => selectedMemberIds.contains(employee.id))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
            child: Row(
              children: [
                Expanded(child: Text('팀원별 업무 로드', style: RobinTheme.headingSm)),
                _workloadTag('팀장 이상', RobinTheme.primary),
              ],
            ),
          ),
          const Divider(height: 1),
          if (visibleEmployees.isEmpty)
            Padding(
              padding: const EdgeInsets.all(22),
              child: Center(
                child: Text('선택한 조직에 표시할 팀원이 없습니다.', style: RobinTheme.bodySm),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: Scrollbar(
                controller: _memberScrollController,
                thumbVisibility: visibleEmployees.length > 5,
                child: SingleChildScrollView(
                  controller: _memberScrollController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.sizeOf(context).width - 64,
                      ),
                      child: _memberTable(visibleEmployees),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _memberTable(List<RobinEmployee> employees) => DataTable(
        headingRowHeight: 34,
        dataRowMinHeight: 38,
        dataRowMaxHeight: 38,
        horizontalMargin: 12,
        columnSpacing: 72,
        headingRowColor: WidgetStatePropertyAll(
            RobinTheme.background.withValues(alpha: .75)),
        columns: const [
          DataColumn(label: Text('담당자')),
          DataColumn(label: Text('진행 수주')),
          DataColumn(label: Text('납기 위험')),
          DataColumn(label: Text('이번 주 To-Do')),
          DataColumn(label: Text('상태')),
        ],
        rows: employees.map(_memberRow).toList(),
      );

  DataRow _memberRow(RobinEmployee employee) {
    final tasks = _tasks.where((task) => task.ownerId == employee.id).toList();
    final urgent = tasks
        .where((task) => task.priority == '긴급' || task.priority == '지연')
        .length;
    final loadLabel = tasks.length >= 7
        ? '과부하'
        : tasks.length >= 4
            ? '주의'
            : '정상';
    final color = loadLabel == '과부하'
        ? RobinTheme.signalRed
        : loadLabel == '주의'
            ? RobinTheme.signalYellow
            : RobinTheme.signalGreen;
    return DataRow(
      cells: [
        DataCell(Text('${employee.name} ${employee.rank}')),
        DataCell(Text('${tasks.length}건')),
        DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
          if (urgent > 0) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(urgent == 0 ? '-' : '$urgent건'),
        ])),
        DataCell(Text('${tasks.length}건')),
        DataCell(_workloadTag(loadLabel, color)),
      ],
    );
  }
}

Widget _workloadTag(String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: RobinTheme.labelXs
              .copyWith(color: color, fontWeight: FontWeight.w700)),
    );

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

  @override
  State<_TodoPanel> createState() => _TodoPanelState();
}

class _TodoPanelState extends State<_TodoPanel> {
  static const _allDivisions = '전체 사업부';
  String _divisionFilter = _allDivisions;
  final Map<String, String> _completedTimes = <String, String>{};

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
    final visible = divisionItems;
    var selectedDivisionLabel = _allDivisions;
    for (final division in allowedDivisions) {
      if (division.name == _divisionFilter) {
        selectedDivisionLabel = division.label;
      }
    }
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: RobinTheme.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: RobinTheme.primary),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: RobinTheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text('To-Do List',
                          style: RobinTheme.headingSm
                              .copyWith(color: Colors.white)),
                      Text(' ★ 오늘 처리 필요',
                          style:
                              RobinTheme.labelXs.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                Text('조회 ${visible.length}건',
                    style: RobinTheme.labelXs.copyWith(color: Colors.white70)),
                const SizedBox(width: 8),
                if (canSwitchDivision)
                  PopupMenuButton<String>(
                    key: const ValueKey('todo-division-filter'),
                    tooltip: '사업부 선택',
                    onSelected: (value) =>
                        setState(() => _divisionFilter = value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _allDivisions,
                        child: Text(_allDivisions),
                      ),
                      ...allowedDivisions.map((division) => PopupMenuItem(
                            value: division.name,
                            child: Text(division.label),
                          )),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(selectedDivisionLabel,
                              style: RobinTheme.labelXs
                                  .copyWith(color: Colors.white)),
                          const SizedBox(width: 3),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    allowedDivisions.isEmpty
                        ? '배정 사업부 없음'
                        : allowedDivisions.first.label,
                    style: RobinTheme.labelXs.copyWith(color: Colors.white),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.white, size: 17),
              ],
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('현재 나에게 배정된 To-Do가 없습니다.'))
                : ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final item = visible[index];
                      final completed =
                          _completedTodoIds.value.contains(item.id);
                      return InkWell(
                        onTap: () => widget.onNavigate(3),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
                          decoration: BoxDecoration(
                            color: completed
                                ? RobinTheme.signalGreen.withValues(alpha: .035)
                                : Colors.transparent,
                            border: const Border(
                              bottom: BorderSide(color: RobinTheme.border),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 30,
                                height: 30,
                                child: Checkbox(
                                  key: ValueKey('todo-complete-${item.id}'),
                                  value: completed,
                                  activeColor: RobinTheme.signalGreen,
                                  onChanged: (_) => _toggleCompleted(item),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 7,
                                      runSpacing: 4,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(item.orderNo,
                                            style:
                                                RobinTheme.headingSm.copyWith(
                                              color: completed
                                                  ? RobinTheme.textMuted
                                                  : RobinTheme.textPrimary,
                                              decoration: completed
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            )),
                                        Text('·',
                                            style:
                                                RobinTheme.headingSm.copyWith(
                                              color: RobinTheme.textMuted,
                                            )),
                                        Text(
                                          item.projectName,
                                          style: RobinTheme.headingSm.copyWith(
                                              color: completed
                                                  ? RobinTheme.textMuted
                                                  : RobinTheme.textPrimary,
                                              decoration: completed
                                                  ? TextDecoration.lineThrough
                                                  : null),
                                        ),
                                        if (!completed) _taskBadge(item),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        completed
                                            ? _completedTimes[item.id] ?? '완료'
                                            : '${item.previousStage} → ${item.nextStage} · ${item.task} · ${item.specChange} · ${item.due}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: RobinTheme.labelXs.copyWith(
                                            color: completed
                                                ? RobinTheme.textMuted
                                                : RobinTheme.textSecondary)),
                                  ],
                                ),
                              ),
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

  void _toggleCompleted(_TodoData item) {
    setState(() {
      final completed = {..._completedTodoIds.value};
      if (completed.remove(item.id)) {
        _completedTimes.remove(item.id);
      } else {
        completed.add(item.id);
        _completedTimes[item.id] =
            '완료 · ${DateFormat('HH:mm').format(DateTime.now())}';
      }
      _completedTodoIds.value = completed;
    });
  }

  static Widget _taskBadge(_TodoData item) {
    final color = switch (item.priority) {
      '긴급' || '지연' => RobinTheme.signalRed,
      '신규' => RobinTheme.primary,
      _ => RobinTheme.textMuted,
    };
    final label = item.priority == '긴급' || item.priority == '지연'
        ? '${item.nextStage} ${item.priority}'
        : '${item.nextStage} ${item.priority == '신규' ? '요청' : item.priority}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: RobinTheme.labelXs
              .copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _RightHomePanel extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const _RightHomePanel({required this.onNavigate});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 500,
        child: Column(
          children: [
            SizedBox(
              height: 190,
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
            const Expanded(child: _MiniAiChat()),
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

class _MiniAiChat extends StatefulWidget {
  const _MiniAiChat();

  @override
  State<_MiniAiChat> createState() => _MiniAiChatState();
}

class _MiniAiChatState extends State<_MiniAiChat> {
  static const _aiColor = Color(0xFF4F46E5);
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_MiniChatMessage> _messages = const [
    _MiniChatMessage(
      '안녕하세요! 수주 현황이나 프로젝트 데이터에 대해 질문하세요.',
      isUser: false,
    ),
  ].toList();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final question = _controller.text.trim();
    if (question.isEmpty) return;
    setState(() {
      _messages.add(_MiniChatMessage(question, isUser: true));
      _messages.add(_MiniChatMessage(_answerFor(question), isUser: false));
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  String _answerFor(String question) {
    if (question.contains('납기') || question.contains('위험')) {
      return '현재 납기 위험은 4건이며 RED 2건, AMBER 2건입니다.';
    }
    if (question.contains('결재')) {
      return '현재 결재 대기 3건이 있으며 Negotiation 승인 확인이 필요합니다.';
    }
    if (question.contains('수주')) {
      return '이번 주 수주는 12건이며 전주 대비 3건 증가했습니다.';
    }
    return '“$question” 질문을 확인했습니다. 관련 수주·프로젝트 데이터를 조회해 답변하겠습니다.';
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _aiColor.withValues(alpha: .035),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: _aiColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: RobinTheme.border)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, size: 8, color: _aiColor),
                  SizedBox(width: 7),
                  Text('AI Assistant',
                      style: TextStyle(
                          color: _aiColor, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8),
                  Text('수주 데이터 질의응답',
                      style:
                          TextStyle(color: RobinTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 330),
                      margin: const EdgeInsets.only(bottom: 7),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 8),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? _aiColor
                            : _aiColor.withValues(alpha: .07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message.text,
                        style: RobinTheme.bodySm.copyWith(
                          color: message.isUser ? Colors.white : _aiColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: RobinTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('mini-ai-chat-input'),
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: '예: 이번 주 납기 위험 건수는?',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  FilledButton(
                    key: const ValueKey('mini-ai-chat-send'),
                    onPressed: _send,
                    style: FilledButton.styleFrom(
                      backgroundColor: RobinTheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 12),
                    ),
                    child: const Text('전송'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _MiniChatMessage {
  final String text;
  final bool isUser;

  const _MiniChatMessage(this.text, {required this.isUser});
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

  String get id => '$orderNo::$task';

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
