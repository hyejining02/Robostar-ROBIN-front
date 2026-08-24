import 'package:flutter/material.dart';

import '../services/project_todo_service.dart';
import '../theme/robin_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/user_profile.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  String _stage = '전체 단계';
  String _ratio = '전체 재료비율';
  _OrderRow? _selected;
  final _tableController = ScrollController();

  static const _rows = [
    _OrderRow('RB-2608-014', 'A사', '서울 대리점', '김로빈 책임', 'Negotiation',
        '자동화라인 증설', 125000, 97200, 77.8, 95400, '결재 진행', 2, 1),
    _OrderRow('RB-2608-011', 'B사', '본사 직판', '박로빈 사원', 'Proposal', '물류 로봇 시스템',
        84000, 63800, 76.0, 0, '제안 검토', 1, 3),
    _OrderRow('RB-2608-009', 'C사', '경기 대리점', '이영업 선임', 'Assess', '협동로봇 4대',
        46000, 0, 0, 0, '물동 확인', 0, 0),
    _OrderRow('RB-2608-006', 'D사', '본사 직판', '김로빈 책임', 'Negotiation',
        '검사 자동화 설비', 98000, 82100, 83.8, 80500, '사업부장 결재', 4, 2),
    _OrderRow('SO-2608-002', 'E사', '부산 대리점', '박영업 책임', 'Closed Won', '로봇 제어시스템',
        72000, 51800, 71.9, 50600, 'ERP 수주확정', 0, 1),
  ];

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (robinUserProfile.value.isDealer) return _buildDealerBidScreen();
    final visible = _rows.where((row) {
      if (_stage != '전체 단계' && row.stage != _stage) {
        return false;
      }
      if (_ratio == '80% 이상' && row.materialRatio < 80) {
        return false;
      }
      if (_ratio == '75~80%' &&
          (row.materialRatio < 75 || row.materialRatio >= 80)) {
        return false;
      }
      if (_ratio == '75% 미만' &&
          (row.materialRatio == 0 || row.materialRatio >= 75)) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: RobinTheme.background,
      appBar: const RobinAppBar(title: '수주관리'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('수주관리', style: RobinTheme.headingLg),
            const SizedBox(height: 4),
            Text('파이프라인 단계별 매출, 원가 시뮬레이션, 재료비율과 결재 현황을 관리합니다.',
                style: RobinTheme.bodySm),
            const SizedBox(height: 16),
            const _OrderKpiGrid(),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: _storyCard(),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _stage,
                      decoration: const InputDecoration(
                          labelText: '파이프라인 단계',
                          border: OutlineInputBorder(),
                          isDense: true),
                      items: const [
                        '전체 단계',
                        'Assess',
                        'Proposal',
                        'Negotiation',
                        'Closed Won',
                        'Closed Lost'
                      ]
                          .map((value) => DropdownMenuItem(
                              value: value, child: Text(value)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _stage = value ?? '전체 단계'),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _ratio,
                      decoration: const InputDecoration(
                          labelText: '재료비율',
                          border: OutlineInputBorder(),
                          isDense: true),
                      items: const ['전체 재료비율', '80% 이상', '75~80%', '75% 미만']
                          .map((value) => DropdownMenuItem(
                              value: value, child: Text(value)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _ratio = value ?? '전체 재료비율'),
                    ),
                  ),
                  const SizedBox(
                    width: 230,
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: '고객사·대리점·담당자 검색',
                          prefixIcon: Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(),
                          isDense: true),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _stage = '전체 단계';
                      _ratio = '전체 재료비율';
                    }),
                    icon: const Icon(Icons.refresh, size: 17),
                    label: const Text('초기화'),
                  ),
                  const _ApprovalRuleGuide(),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              decoration: _storyCard(),
              child: LayoutBuilder(
                builder: (context, constraints) => Scrollbar(
                  controller: _tableController,
                  thumbVisibility: true,
                  interactive: true,
                  scrollbarOrientation: ScrollbarOrientation.bottom,
                  child: SingleChildScrollView(
                    controller: _tableController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        horizontalMargin: 8,
                        checkboxHorizontalMargin: 6,
                        columnSpacing: 10,
                        headingRowHeight: 56,
                        dataRowMinHeight: 62,
                        dataRowMaxHeight: 92,
                        columns: [
                          DataColumn(label: _storyTableText(86, '수주번호')),
                          DataColumn(label: _storyTableText(76, '단계')),
                          DataColumn(label: _storyTableText(42, '고객사')),
                          DataColumn(label: _storyTableText(95, '대리점/직판 담당자')),
                          DataColumn(label: _storyTableText(115, '수주 과제')),
                          DataColumn(
                              label: _storyTableText(98, '수주제안가(ROBIN)')),
                          DataColumn(
                              label: _storyTableText(98, '원가 시뮬(ROBIN)')),
                          DataColumn(label: _storyTableText(62, '재료비율')),
                          DataColumn(label: _storyTableText(98, '원가 확정(ERP)')),
                          DataColumn(label: _storyTableText(90, '수주확정(ERP)')),
                          DataColumn(label: _storyTableText(90, '변경')),
                          DataColumn(label: _storyTableText(88, '관리')),
                        ],
                        rows: visible.map((row) {
                          final selected = _selected?.number == row.number;
                          return DataRow(
                            selected: selected,
                            onSelectChanged: (_) {
                              setState(() => _selected = row);
                              _showOrderDetail(context, row);
                            },
                            cells: [
                              DataCell(_storyTableText(
                                86,
                                row.number,
                                style: RobinTheme.bodySm.copyWith(
                                  color: RobinTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              )),
                              DataCell(SizedBox(
                                  width: 76, child: _stageChip(row.stage))),
                              DataCell(_storyTableText(42, row.customer)),
                              DataCell(_storyTableText(
                                  95, '${row.channel}\n${row.owner}')),
                              DataCell(_storyTableText(115, row.task)),
                              DataCell(_storyTableText(
                                  98, '${_money(row.proposalPrice)}만원')),
                              DataCell(_storyTableText(
                                  98,
                                  row.simulatedCost == 0
                                      ? '-'
                                      : '${_money(row.simulatedCost)}만원')),
                              DataCell(SizedBox(
                                  width: 62,
                                  child: _ratioChip(row.materialRatio))),
                              DataCell(_storyTableText(
                                  98,
                                  row.erpCost == 0
                                      ? '-'
                                      : '${_money(row.erpCost)}만원')),
                              DataCell(SizedBox(
                                  width: 90, child: _statusChip(row.approval))),
                              DataCell(_storyTableText(90,
                                  '주문 ${row.orderChanges} · 사양 ${row.specChanges}')),
                              DataCell(SizedBox(
                                width: 88,
                                child: FilledButton(
                                  onPressed: () =>
                                      _showOrderDetail(context, row),
                                  child: const Text('상세/결재'),
                                ),
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDealerBidScreen() {
    final department = robinUserProfile.value.department;
    final rows = _rows.where((row) => row.channel == department).toList();
    return Scaffold(
      backgroundColor: RobinTheme.background,
      appBar: const RobinAppBar(title: '내 입찰'),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('내 입찰', style: RobinTheme.headingLg),
            const SizedBox(height: 4),
            Text('내 대리점이 참여한 입찰과 제안 진행 상태만 조회합니다.', style: RobinTheme.bodySm),
            const SizedBox(height: 14),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: _storyCard(),
                child: rows.isEmpty
                    ? const Center(child: Text('등록된 입찰 건이 없습니다.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: rows.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final row = rows[index];
                          return ListTile(
                            leading: const Icon(Icons.gavel_outlined,
                                color: RobinTheme.primary),
                            title: Text('${row.number} · ${row.task}',
                                style: RobinTheme.headingSm),
                            subtitle: Text(
                                '${row.customer} · 제안가 ${_money(row.proposalPrice)}만원'),
                            trailing: Chip(label: Text(row.stage)),
                            onTap: () => _showDealerBidDetail(context, row),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDealerBidDetail(BuildContext context, _OrderRow row) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${row.number} · ${row.task}'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailValue('고객사', row.customer),
              _detailValue('진행 단계', row.stage),
              _detailValue('제안 금액', '${_money(row.proposalPrice)}만원'),
              _detailValue('입찰 상태', row.approval),
              const SizedBox(height: 8),
              Text('원가·재료비·내부 결재 정보는 대리점 계정에 제공되지 않습니다.',
                  style: RobinTheme.bodySm),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('닫기')),
        ],
      ),
    );
  }

  Future<void> _showOrderDetail(BuildContext context, _OrderRow row) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${row.number} · ${row.task}'),
        content: SizedBox(
          width: 760,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _detailValue('Proposal 도면', 'PDM Rev.03 연계'),
                    _detailValue('상세 Spec.', '가반하중 80kg · Reach 2,100mm'),
                    _detailValue('재료비율', '${row.materialRatio}%'),
                    _detailValue('증빙',
                        row.materialRatio >= 80 ? '미첨부 · RED' : '첨부완료 · GREEN'),
                  ],
                ),
                const SizedBox(height: 16),
                Text('원가 시뮬레이션', style: RobinTheme.headingSm),
                const SizedBox(height: 8),
                const _SimulationTable(),
                const SizedBox(height: 16),
                Text('결재선', style: RobinTheme.headingSm),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _approvalStep('기안자', '${row.owner}\n상신 완료', true),
                      const _ApprovalArrow(),
                      _approvalStep('영업팀장', '검토 대기', false),
                      if (row.materialRatio >= 80) ...[
                        const _ApprovalArrow(),
                        _approvalStep('사업부장', '승인 대기', false),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('제안검토 · 수주 사양 변경이력', style: RobinTheme.headingSm),
                const SizedBox(height: 8),
                const _OrderChangeHistory(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('닫기')),
          OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.attach_file, size: 17),
              label: const Text('증빙 첨부')),
          FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('결재가 상신되었습니다.')));
              },
              icon: const Icon(Icons.approval_outlined, size: 17),
              label: const Text('결재 상신')),
        ],
      ),
    );
  }
}

class ProjectManagementScreen extends StatefulWidget {
  const ProjectManagementScreen({super.key});

  @override
  State<ProjectManagementScreen> createState() =>
      _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  _ProjectRow _selected = _projects.first;
  final _tableController = ScrollController();
  final Map<String, List<_ProjectMemoEntry>> _memoThreads = {};

  static const _projects = [
    _ProjectRow('SO-2608-014', 'A사 자동화라인 증설', '구매', '2026-09-20', '2026-09-27',
        true, 'BOM 장기재고 2건 확인 필요', '서울 대리점'),
    _ProjectRow('SO-2608-011', 'B사 물류 로봇 시스템', '생산', '2026-09-05', '-', false,
        'Work Center 생산예정일 입력 대기', '본사 직판'),
    _ProjectRow('SO-2608-009', 'C사 협동로봇 공급', '품질', '2026-08-28', '2026-08-30',
        true, 'OQC 검사 예정', '경기 대리점'),
    _ProjectRow('SO-2608-006', 'D사 검사 자동화 설비', '물류', '2026-08-24', '-', false,
        '납품처 확인 완료 · 배차 대기', '본사 직판'),
    _ProjectRow('SO-2608-002', 'E사 제어시스템', '마감', '2026-08-18', '-', false,
        'ERP 거래명세서 발생 대기', '부산 대리점'),
  ];

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (robinUserProfile.value.isDealer) return _buildDealerProgressScreen();
    return Scaffold(
      backgroundColor: RobinTheme.background,
      appBar: const RobinAppBar(title: '프로젝트 관리'),
      body: DefaultTabController(
        length: 5,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('프로젝트 관리', style: RobinTheme.headingLg),
              const SizedBox(height: 4),
              Text('수주 확정 프로젝트를 설계부터 마감까지 단계별로 관리합니다.',
                  style: RobinTheme.bodySm),
              const SizedBox(height: 15),
              const _ProjectStageSummary(),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                decoration: _storyCard(),
                child: LayoutBuilder(
                  builder: (context, constraints) => Scrollbar(
                    controller: _tableController,
                    thumbVisibility: true,
                    interactive: true,
                    scrollbarOrientation: ScrollbarOrientation.bottom,
                    child: SingleChildScrollView(
                      controller: _tableController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          horizontalMargin: 10,
                          checkboxHorizontalMargin: 8,
                          columnSpacing: 14,
                          headingRowHeight: 56,
                          dataRowMinHeight: 62,
                          dataRowMaxHeight: 94,
                          columns: const [
                            DataColumn(label: Text('수주번호')),
                            DataColumn(label: Text('프로젝트명')),
                            DataColumn(label: Text('설계')),
                            DataColumn(label: Text('구매')),
                            DataColumn(label: Text('생산')),
                            DataColumn(label: Text('품질')),
                            DataColumn(label: Text('물류')),
                            DataColumn(label: Text('마감')),
                            DataColumn(label: Text('기존 납기일')),
                            DataColumn(label: Text('변경 납기일')),
                            DataColumn(label: Text('메모/산출물')),
                          ],
                          rows: _projects.map((row) {
                            final stageIndex =
                                _projectStages.indexOf(row.stage);
                            return DataRow(
                              selected: _selected.number == row.number,
                              onSelectChanged: (_) =>
                                  setState(() => _selected = row),
                              cells: [
                                DataCell(Text(row.number,
                                    style: RobinTheme.bodySm.copyWith(
                                        color: RobinTheme.primary,
                                        fontWeight: FontWeight.w700))),
                                DataCell(SizedBox(
                                    width: 150,
                                    child:
                                        Text(row.projectName, softWrap: true))),
                                for (var index = 0;
                                    index < _projectStages.length;
                                    index++)
                                  DataCell(
                                      _progressDot(row, index, stageIndex)),
                                DataCell(Text(row.dueDate)),
                                DataCell(Row(children: [
                                  Text(row.changedDueDate),
                                  if (row.urgent) ...[
                                    const SizedBox(width: 5),
                                    _statusChip('긴급'),
                                  ]
                                ])),
                                DataCell(SizedBox(
                                    width: 170,
                                    child: Text(row.memo, softWrap: true))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: _storyCard(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${_selected.number} · ${_selected.projectName}',
                                    style: RobinTheme.headingSm),
                                Text(
                                    '현재 단계 ${_selected.stage} · ${_selected.memo}',
                                    style: RobinTheme.bodySm),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                              onPressed: () => _showMemoDialog(context),
                              icon:
                                  const Icon(Icons.note_add_outlined, size: 17),
                              label: const Text('메모·댓글')),
                          const SizedBox(width: 7),
                          FilledButton.icon(
                              onPressed: () => _showDueDateDialog(context),
                              icon: const Icon(Icons.event_repeat, size: 17),
                              label: const Text('납기 변경')),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    const TabBar(
                      tabs: [
                        Tab(text: '구매'),
                        Tab(text: '생산'),
                        Tab(text: '품질'),
                        Tab(text: '물류'),
                        Tab(text: '마감'),
                      ],
                    ),
                    SizedBox(
                      height: 360,
                      child: TabBarView(
                        children: [
                          _PurchasePanel(
                              project: _selected, projects: _projects),
                          _ProductionPanel(
                              project: _selected, projects: _projects),
                          _QualityPanel(
                              project: _selected, projects: _projects),
                          _LogisticsPanel(
                              project: _selected, projects: _projects),
                          _ClosingPanel(
                              project: _selected, projects: _projects),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDealerProgressScreen() {
    final department = robinUserProfile.value.department;
    final rows = _projects.where((row) => row.channel == department).toList();
    return Scaffold(
      backgroundColor: RobinTheme.background,
      appBar: const RobinAppBar(title: '진행단계 조회'),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('진행단계 조회', style: RobinTheme.headingLg),
            const SizedBox(height: 4),
            Text('내 대리점의 수주 프로젝트 진행 상태를 읽기 전용으로 확인합니다.',
                style: RobinTheme.bodySm),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, rowIndex) {
                  final row = rows[rowIndex];
                  final stageIndex = _projectStages.indexOf(row.stage);
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _storyCard(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${row.number} · ${row.projectName}',
                            style: RobinTheme.headingSm),
                        const SizedBox(height: 5),
                        Text(
                            '납기 ${row.changedDueDate == '-' ? row.dueDate : row.changedDueDate}',
                            style: RobinTheme.bodySm),
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var index = 0;
                                  index < _projectStages.length;
                                  index++) ...[
                                _dealerStageItem(index, stageIndex),
                                if (index < _projectStages.length - 1)
                                  Container(
                                    width: 34,
                                    height: 2,
                                    color: index < stageIndex
                                        ? RobinTheme.primary
                                        : RobinTheme.border,
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dealerStageItem(int index, int currentIndex) {
    final complete = index < currentIndex;
    final current = index == currentIndex;
    final color =
        complete || current ? RobinTheme.primary : RobinTheme.textMuted;
    return Tooltip(
      message:
          '${_projectStageOwners[index]} · ${complete ? '완료' : current ? '진행 중' : '대기'}',
      child: SizedBox(
        width: 74,
        child: Column(
          children: [
            Icon(complete ? Icons.check_circle : Icons.radio_button_checked,
                color: color, size: 22),
            const SizedBox(height: 4),
            Text(_projectStages[index], style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  Future<void> _showMemoDialog(BuildContext context) async {
    final initial = _memoThreads.putIfAbsent(
      _selected.number,
      () => [
        _ProjectMemoEntry(
          id: 'initial-${_selected.number}',
          parentId: null,
          author: '김로빈 책임',
          assignee: _projectStageOwners[
              _projectStages.indexOf(_selected.stage).clamp(0, 5)],
          message: _selected.memo,
          at: '2026-08-21 10:20',
          attachment: '진행현황_검토자료.xlsx',
        ),
      ],
    );
    final result = await showDialog<_ProjectMemoResult>(
      context: context,
      builder: (dialogContext) => _ProjectMemoDialog(
        project: _selected,
        initialEntries: initial,
      ),
    );
    if (result == null || !context.mounted) return;
    setState(() => _memoThreads[_selected.number] = result.entries);
    for (final entry in result.newEntries) {
      addProjectTodo(
        ProjectTodoItem(
          id: entry.id,
          orderNo: _selected.number,
          projectName: _selected.projectName,
          stage: _selected.stage,
          assignee: entry.assignee,
          task: entry.message,
          createdBy: entry.author,
          createdAt: entry.at,
        ),
      );
    }
    if (result.newEntries.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('메모 ${result.newEntries.length}건을 저장하고 담당자 To-Do를 생성했습니다.'),
        ),
      );
    }
  }

  Future<void> _showDueDateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('납기일 변경'),
        content: const SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  decoration: InputDecoration(
                      labelText: '변경 납기일',
                      suffixIcon: Icon(Icons.calendar_month),
                      border: OutlineInputBorder())),
              SizedBox(height: 12),
              TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                      labelText: '변경 사유', border: OutlineInputBorder())),
              SizedBox(height: 8),
              CheckboxListTile(
                  value: true, onChanged: null, title: Text('긴급 프로젝트로 표시')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('변경 저장')),
        ],
      ),
    );
  }
}

class _ProjectMemoDialog extends StatefulWidget {
  final _ProjectRow project;
  final List<_ProjectMemoEntry> initialEntries;

  const _ProjectMemoDialog({
    required this.project,
    required this.initialEntries,
  });

  @override
  State<_ProjectMemoDialog> createState() => _ProjectMemoDialogState();
}

class _ProjectMemoDialogState extends State<_ProjectMemoDialog> {
  static const _assignees = [
    '이설계 책임',
    '김구매 팀장',
    '박생산 책임',
    '최품질 책임',
    '김로빈 책임',
  ];

  late final List<_ProjectMemoEntry> _entries;
  final List<_ProjectMemoEntry> _newEntries = [];
  final _message = TextEditingController();
  final _attachment = TextEditingController();
  String _assignee = _assignees.first;
  String? _replyTo;

  @override
  void initState() {
    super.initState();
    _entries = [...widget.initialEntries];
    final stageIndex = _projectStages.indexOf(widget.project.stage);
    if (stageIndex >= 0) _assignee = _projectStageOwners[stageIndex];
  }

  @override
  void dispose() {
    _message.dispose();
    _attachment.dispose();
    super.dispose();
  }

  void _addMemo() {
    final message = _message.text.trim();
    if (message.isEmpty) return;
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    final entry = _ProjectMemoEntry(
      id: 'memo-${now.microsecondsSinceEpoch}',
      parentId: _replyTo,
      author: robinUserProfile.value.name,
      assignee: _assignee,
      message: message,
      at: '${now.year}-${two(now.month)}-${two(now.day)} '
          '${two(now.hour)}:${two(now.minute)}',
      attachment:
          _attachment.text.trim().isEmpty ? null : _attachment.text.trim(),
    );
    setState(() {
      _entries.add(entry);
      _newEntries.add(entry);
      _message.clear();
      _attachment.clear();
      _replyTo = null;
    });
  }

  @override
  Widget build(BuildContext context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860, maxHeight: 760),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 10, 12),
                child: Row(
                  children: [
                    const Icon(Icons.forum_outlined, color: RobinTheme.primary),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('프로젝트 메모·댓글 이력', style: RobinTheme.headingLg),
                          Text(
                              '${widget.project.number} · ${widget.project.projectName}',
                              style: RobinTheme.bodySm),
                        ],
                      ),
                    ),
                    Chip(label: Text('${_entries.length}건')),
                    IconButton(
                      tooltip: '닫기',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    for (final entry in _entries) ...[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            entry.parentId == null ? 4 : 38, 7, 4, 7),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              entry.parentId == null
                                  ? Icons.chat_bubble_outline
                                  : Icons.subdirectory_arrow_right,
                              size: 18,
                              color: RobinTheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${entry.author} · 담당 ${entry.assignee} · ${entry.at}',
                                      style: RobinTheme.labelXs),
                                  const SizedBox(height: 3),
                                  Text(entry.message),
                                  if (entry.attachment != null) ...[
                                    const SizedBox(height: 4),
                                    Chip(
                                      avatar: const Icon(
                                          Icons.attach_file_outlined,
                                          size: 15),
                                      label: Text(entry.attachment!),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _replyTo = entry.id),
                              child: const Text('답글'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      key: const ValueKey('project-memo-assignee'),
                      initialValue: _assignee,
                      decoration: const InputDecoration(
                        labelText: 'To-Do 담당자',
                        border: OutlineInputBorder(),
                      ),
                      items: _assignees
                          .map((assignee) => DropdownMenuItem(
                              value: assignee, child: Text(assignee)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _assignee = value ?? _assignee),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const ValueKey('project-memo-input'),
                      controller: _message,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: _replyTo == null ? '프로젝트 메모' : '선택한 메모에 답글',
                        border: const OutlineInputBorder(),
                        suffixIcon: _replyTo == null
                            ? null
                            : IconButton(
                                tooltip: '답글 취소',
                                onPressed: () =>
                                    setState(() => _replyTo = null),
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const ValueKey('project-memo-attachment'),
                      controller: _attachment,
                      decoration: const InputDecoration(
                        labelText: '산출물 파일명 (선택)',
                        hintText: 'PDF, XLSX, DWG 등',
                        prefixIcon: Icon(Icons.attach_file),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        key: const ValueKey('add-project-memo'),
                        onPressed: _addMemo,
                        icon: const Icon(Icons.add_task, size: 17),
                        label: const Text('메모 등록 · To-Do 생성'),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Text('등록한 메모마다 담당자 To-Do가 생성됩니다.'),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    const SizedBox(width: 6),
                    FilledButton(
                      key: const ValueKey('save-project-memos'),
                      onPressed: () => Navigator.pop(
                        context,
                        _ProjectMemoResult(
                          entries: _entries,
                          newEntries: _newEntries,
                        ),
                      ),
                      child: const Text('이력 저장'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _PurchasePanel extends StatelessWidget {
  final _ProjectRow project;
  final List<_ProjectRow> projects;
  const _PurchasePanel({required this.project, required this.projects});

  @override
  Widget build(BuildContext context) => _panel(
        title: 'ERP BOM별 구매·재고 진행현황',
        action: Row(
          children: [
            OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ERP BOM을 동기화했습니다.'))),
                icon: const Icon(Icons.sync, size: 16),
                label: const Text('ERP BOM 동기화')),
            const SizedBox(width: 7),
            FilledButton.icon(
                onPressed: () =>
                    _openProjectStageInput(context, '구매', project, projects),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('재고/입고 입력')),
          ],
        ),
        child: const _CompactTable(
          headers: ['BOM', '품명', '재고 구분', '수량', '발주/입고일', '상태'],
          rows: [
            ['B-001', '서보모터', '일반재고', '4', '-', '확보'],
            ['B-002', '감속기', '장기재고', '2', '-', '확인 필요'],
            ['B-003', '안전센서', '발주품', '8', '08-26', '발주 완료'],
            ['B-004', '제어반 부품', '사급품', '1', '08-22', '입고 대기'],
          ],
        ),
      );
}

class _ProductionPanel extends StatelessWidget {
  final _ProjectRow project;
  final List<_ProjectRow> projects;
  const _ProductionPanel({required this.project, required this.projects});

  @override
  Widget build(BuildContext context) => _panel(
        title: 'Work Center 생산 진행현황',
        action: FilledButton.icon(
            onPressed: () =>
                _openProjectStageInput(context, '생산', project, projects),
            icon: const Icon(Icons.edit_calendar_outlined, size: 16),
            label: const Text('생산 예정일 입력')),
        child: const _CompactTable(
          headers: ['Work Center', '계획수량', '지시수량', '실적수량', '창고입고', '생산 예정일'],
          rows: [
            ['WC-조립1', '4', '4', '2', '0', '2026-08-25'],
            ['WC-배선', '4', '4', '3', '1', '2026-08-23'],
            ['사내도급 A', '2', '2', '0', '0', '입력 대기'],
          ],
        ),
      );
}

class _QualityPanel extends StatelessWidget {
  final _ProjectRow project;
  final List<_ProjectRow> projects;
  const _QualityPanel({required this.project, required this.projects});

  @override
  Widget build(BuildContext context) => _panel(
        title: 'IQC · LQC · OQC 단계별 검사 입력',
        action: FilledButton.icon(
            onPressed: () =>
                _openProjectStageInput(context, '품질', project, projects),
            icon: const Icon(Icons.fact_check_outlined, size: 16),
            label: const Text('검사 결과 입력')),
        child: const _CompactTable(
          headers: ['검사 단계', 'ERP BOM', '검사수량', '양품', '불량', '불량률'],
          rows: [
            ['IQC 수입검사', 'B-001~004', '15', '15', '0', '0.0%'],
            ['LQC 공정검사', 'ASSEMBLY', '8', '7', '1', '12.5%'],
            ['OQC 출하검사', 'PRODUCT', '4', '4', '0', '0.0%'],
          ],
        ),
      );
}

class _LogisticsPanel extends StatelessWidget {
  final _ProjectRow project;
  final List<_ProjectRow> projects;
  const _LogisticsPanel({required this.project, required this.projects});

  @override
  Widget build(BuildContext context) => _panel(
        title: '납품 정보 및 배차·상차 진행현황',
        action: FilledButton.icon(
            onPressed: () =>
                _openProjectStageInput(context, '물류', project, projects),
            icon: const Icon(Icons.local_shipping_outlined, size: 16),
            label: const Text('납품/배차 입력')),
        child: const _CompactTable(
          headers: ['납품처', '수령 담당자', '납품일', '차량', '출고요청', '상차'],
          rows: [
            ['창원시 성산구 A사 2공장', '이현장 부장', '2026-08-28', '5톤 윙바디', '완료', '대기'],
            ['부산 강서구 A사 물류센터', '박수령 과장', '2026-08-29', '배차 대기', '완료', '대기'],
          ],
        ),
      );
}

class _ClosingPanel extends StatelessWidget {
  final _ProjectRow project;
  final List<_ProjectRow> projects;
  const _ClosingPanel({required this.project, required this.projects});

  @override
  Widget build(BuildContext context) => _panel(
        title: 'ERP 거래명세서 기준 마감 현황',
        action: Row(
          children: [
            OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('마감 이력 Excel을 생성했습니다.'))),
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('마감 이력 Excel')),
            const SizedBox(width: 7),
            FilledButton.icon(
                onPressed: () =>
                    _openProjectStageInput(context, '마감', project, projects),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('마감 입력')),
          ],
        ),
        child: const _CompactTable(
          headers: ['거래명세서', 'ERP 출하일', '매출 마감', '최종 담당자', '완료일', '상태'],
          rows: [
            ['ERP-TS-260814', '2026-08-28', '발생', '김로빈 책임', '2026-08-29', '완료'],
            ['ERP-TS-260815', '-', '미발생', '박로빈 사원', '-', '대기'],
          ],
        ),
      );
}

Future<void> _openProjectStageInput(BuildContext context, String stage,
    _ProjectRow current, List<_ProjectRow> projects) async {
  final project = await showDialog<_ProjectRow>(
    context: context,
    builder: (context) => _ProjectOrderSearchDialog(
      stage: stage,
      projects: projects,
      initial: current,
    ),
  );
  if (project == null || !context.mounted) return;
  final dialog = switch (stage) {
    '구매' => _PurchaseInputDialog(project: project),
    '생산' => _ProductionInputDialog(project: project),
    '품질' => _QualityInputDialog(project: project),
    '물류' => _LogisticsInputDialog(project: project),
    '마감' => _ClosingInputDialog(project: project),
    _ => null,
  };
  if (dialog != null) {
    await showDialog<void>(context: context, builder: (_) => dialog);
  }
}

class _ProjectOrderSearchDialog extends StatefulWidget {
  final String stage;
  final List<_ProjectRow> projects;
  final _ProjectRow initial;

  const _ProjectOrderSearchDialog({
    required this.stage,
    required this.projects,
    required this.initial,
  });

  @override
  State<_ProjectOrderSearchDialog> createState() =>
      _ProjectOrderSearchDialogState();
}

class _ProjectOrderSearchDialogState extends State<_ProjectOrderSearchDialog> {
  final _search = TextEditingController();
  late _ProjectRow _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final rows = widget.projects
        .where((project) =>
            query.isEmpty ||
            project.number.toLowerCase().contains(query) ||
            project.projectName.toLowerCase().contains(query))
        .toList();
    final salesStage = widget.stage == '물류' || widget.stage == '마감';
    return AlertDialog(
      title: Text('${widget.stage} 입력 · 수주번호 검색'),
      content: SizedBox(
        width: 620,
        height: 430,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(label: Text('담당 조직: ${salesStage ? '영업' : widget.stage}')),
                const SizedBox(width: 7),
                const Text('수주번호를 선택한 후 단계별 입력 모달로 이동합니다.'),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              key: const ValueKey('project-order-search-input'),
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: '수주번호 또는 프로젝트명',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: rows.isEmpty
                  ? const Center(child: Text('검색 결과가 없습니다.'))
                  : ListView.builder(
                      itemCount: rows.length,
                      itemBuilder: (context, index) {
                        final project = rows[index];
                        final selected = _selected.number == project.number;
                        return ListTile(
                          selected: selected,
                          onTap: () => setState(() => _selected = project),
                          leading: Icon(selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked),
                          title: Text(project.number),
                          subtitle: Text(
                              '${project.projectName} · 현재 ${project.stage}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('취소')),
        FilledButton.icon(
          key: const ValueKey('continue-project-stage-input'),
          onPressed: rows.any((row) => row.number == _selected.number)
              ? () => Navigator.pop(context, _selected)
              : null,
          icon: const Icon(Icons.arrow_forward, size: 17),
          label: const Text('선택 후 입력'),
        ),
      ],
    );
  }
}

Widget _panel(
        {required String title,
        required Widget action,
        required Widget child}) =>
    Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(title, style: RobinTheme.headingSm)),
            action,
          ]),
          const SizedBox(height: 10),
          Expanded(child: SingleChildScrollView(child: child)),
        ],
      ),
    );

class _PurchaseInputDialog extends StatefulWidget {
  final _ProjectRow project;
  const _PurchaseInputDialog({required this.project});

  @override
  State<_PurchaseInputDialog> createState() => _PurchaseInputDialogState();
}

class _PurchaseInputDialogState extends State<_PurchaseInputDialog> {
  String _inventoryType = '일반재고';

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('BOM 재고/발주/입고 입력'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogProjectNumber(project: widget.project),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                    labelText: 'ERP BOM/Item', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _inventoryType,
                decoration: const InputDecoration(
                    labelText: '재고 구분 인자', border: OutlineInputBorder()),
                items: const ['일반재고', '장기재고', '발주품', '사급품']
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _inventoryType = value ?? _inventoryType),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: '수량', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText:
                            _inventoryType == '사급품' ? '사급품 입고일' : '발주/예정 입고일',
                        suffixIcon: const Icon(Icons.calendar_month),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: _dialogActions(context, 'BOM 진행현황을 저장했습니다.'),
      );
}

class _ProductionInputDialog extends StatelessWidget {
  final _ProjectRow project;
  const _ProductionInputDialog({required this.project});

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Work Center 생산 진행현황 입력'),
        content: SizedBox(
          width: 620,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogProjectNumber(project: project),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(
                      child: TextField(
                          decoration: InputDecoration(
                              labelText: 'Work Center/사내도급사',
                              border: OutlineInputBorder()))),
                  SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          decoration: InputDecoration(
                              labelText: '생산예정일',
                              suffixIcon: Icon(Icons.calendar_month),
                              border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(child: _QuantityField('생산계획수량')),
                  SizedBox(width: 7),
                  Expanded(child: _QuantityField('작업지시수량')),
                  SizedBox(width: 7),
                  Expanded(child: _QuantityField('생산실적수량')),
                  SizedBox(width: 7),
                  Expanded(child: _QuantityField('제품창고입고수량')),
                ],
              ),
            ],
          ),
        ),
        actions: _dialogActions(context, '생산 진행현황을 저장했습니다.'),
      );
}

class _QualityInputDialog extends StatefulWidget {
  final _ProjectRow project;
  const _QualityInputDialog({required this.project});

  @override
  State<_QualityInputDialog> createState() => _QualityInputDialogState();
}

class _QualityInputDialogState extends State<_QualityInputDialog> {
  final _inspection = TextEditingController(text: '10');
  final _defect = TextEditingController(text: '0');
  String _stage = 'IQC 수입검사';

  double get _rate {
    final total = int.tryParse(_inspection.text) ?? 0;
    final defect = int.tryParse(_defect.text) ?? 0;
    return total == 0 ? 0 : defect / total * 100;
  }

  @override
  void dispose() {
    _inspection.dispose();
    _defect.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('품질 검사 결과 입력'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogProjectNumber(project: widget.project),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _stage,
                decoration: const InputDecoration(
                    labelText: '검사 단계', border: OutlineInputBorder()),
                items: const ['IQC 수입검사', 'LQC 공정검사', 'OQC 출하검사']
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) => setState(() => _stage = value ?? _stage),
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                    labelText: 'ERP BOM · 불량 항목',
                    hintText: '수주번호로 ERP BOM 조회',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: _inspection,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                              labelText: '검사수량',
                              border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          controller: _defect,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                              labelText: '불량수량',
                              helperText: '기본값 0(양품)',
                              border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: '불량률', border: OutlineInputBorder()),
                      child: Text('${_rate.toStringAsFixed(1)}%',
                          style: RobinTheme.headingSm.copyWith(
                              color: _rate == 0
                                  ? RobinTheme.signalGreen
                                  : RobinTheme.signalRed)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: _dialogActions(context, '품질 검사 결과를 저장했습니다.'),
      );
}

class _LogisticsInputDialog extends StatelessWidget {
  final _ProjectRow project;
  const _LogisticsInputDialog({required this.project});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: AlertDialog(
          title: const Text('출하 · 납품 · 배차 입력'),
          content: SizedBox(
            width: 640,
            height: 360,
            child: Column(
              children: [
                _DialogProjectNumber(project: project),
                const SizedBox(height: 8),
                const TabBar(tabs: [
                  Tab(text: '영업 · Works 출고요청'),
                  Tab(text: '물류 · 배차/상차'),
                ]),
                const Expanded(
                  child: TabBarView(children: [
                    _LogisticsSalesForm(),
                    _LogisticsAssignmentForm(),
                  ]),
                ),
              ],
            ),
          ),
          actions: _dialogActions(context, '납품/배차 정보를 저장했습니다.'),
        ),
      );
}

class _LogisticsSalesForm extends StatelessWidget {
  const _LogisticsSalesForm();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Column(children: [
          TextField(
              decoration: InputDecoration(
                  labelText: '납품처 주소', border: OutlineInputBorder())),
          SizedBox(height: 9),
          Row(children: [
            Expanded(
                child: TextField(
                    decoration: InputDecoration(
                        labelText: '수령 담당자/연락처',
                        border: OutlineInputBorder()))),
            SizedBox(width: 8),
            Expanded(
                child: TextField(
                    decoration: InputDecoration(
                        labelText: '납품일',
                        suffixIcon: Icon(Icons.calendar_month),
                        border: OutlineInputBorder()))),
          ]),
          SizedBox(height: 9),
          ListTile(
              leading: Icon(Icons.outbox_outlined),
              title: Text('Works 출고요청 영업 직접 등록'),
              subtitle: Text('출고요청 → 생산완료확정 → 배차생성 → 상차')),
        ]),
      );
}

class _LogisticsAssignmentForm extends StatelessWidget {
  const _LogisticsAssignmentForm();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Column(children: [
          Row(children: [
            Expanded(
                child: TextField(
                    decoration: InputDecoration(
                        labelText: '화물차/배차업체', border: OutlineInputBorder()))),
            SizedBox(width: 8),
            Expanded(
                child: TextField(
                    decoration: InputDecoration(
                        labelText: '차량번호/기사 연락처',
                        border: OutlineInputBorder()))),
          ]),
          SizedBox(height: 9),
          TextField(
              decoration: InputDecoration(
                  labelText: '상차 완료시각',
                  suffixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder())),
          SizedBox(height: 9),
          CheckboxListTile(
              value: false,
              onChanged: null,
              title: Text('상차 완료 확인'),
              subtitle: Text('생산완료확정 후 활성화')),
        ]),
      );
}

class _ClosingInputDialog extends StatelessWidget {
  final _ProjectRow project;

  const _ClosingInputDialog({required this.project});

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('ERP 거래명세서 · 매출 마감 입력'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogProjectNumber(project: project),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'ERP 거래명세서 번호',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'ERP 출하일',
                        suffixIcon: Icon(Icons.calendar_month),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: '매출 마감일',
                        suffixIcon: Icon(Icons.calendar_month),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const TextField(
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: '영업 마감 비고',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: _dialogActions(context, '매출 마감 정보를 저장했습니다.'),
      );
}

class _DialogProjectNumber extends StatelessWidget {
  final _ProjectRow project;
  const _DialogProjectNumber({required this.project});
  @override
  Widget build(BuildContext context) => InputDecorator(
        decoration: const InputDecoration(
            labelText: '수주번호 · 프로젝트', border: OutlineInputBorder()),
        child: Text('${project.number} · ${project.projectName}'),
      );
}

class _QuantityField extends StatelessWidget {
  final String label;
  const _QuantityField(this.label);
  @override
  Widget build(BuildContext context) => TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
      );
}

List<Widget> _dialogActions(BuildContext context, String message) => [
      TextButton(
          onPressed: () => Navigator.pop(context), child: const Text('취소')),
      FilledButton(
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        },
        child: const Text('저장'),
      ),
    ];

class _CompactTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  const _CompactTable({required this.headers, required this.rows});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowHeight: 54,
          dataRowMinHeight: 44,
          dataRowMaxHeight: 68,
          columns: headers
              .map((header) => DataColumn(label: Text(header, softWrap: true)))
              .toList(),
          rows: rows
              .map((row) => DataRow(
                    cells: row
                        .map((value) => DataCell(Text(value, softWrap: true)))
                        .toList(),
                  ))
              .toList(),
        ),
      );
}

class _OrderKpiGrid extends StatelessWidget {
  const _OrderKpiGrid();

  static const _items = [
    _OrderKpi('Assess', '12건', '18.4억원', '물동 3건 변경'),
    _OrderKpi('Proposal', '8건', '13.1억원', '도면 5건 변경'),
    _OrderKpi('Negotiation', '6건', '9.8억원', '결재 3건 대기'),
    _OrderKpi('Closed Won', '4건', '7.2억원', 'ERP 확정 4건'),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 980) {
            return Row(
              children: [
                Expanded(child: _OrderKpiGridItem(item: _items[0])),
                const SizedBox(width: 10),
                Expanded(child: _OrderKpiGridItem(item: _items[1])),
                const SizedBox(width: 10),
                Expanded(child: _OrderKpiGridItem(item: _items[2])),
                const SizedBox(width: 10),
                Expanded(child: _OrderKpiGridItem(item: _items[3])),
              ],
            );
          }
          final width = (constraints.maxWidth - 10) / 2;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _items
                .map((item) => SizedBox(
                    width: width, child: _OrderKpiGridItem(item: item)))
                .toList(),
          );
        },
      );
}

class _OrderKpiGridItem extends StatelessWidget {
  final _OrderKpi item;
  const _OrderKpiGridItem({required this.item});

  @override
  Widget build(BuildContext context) => item;
}

class _OrderKpi extends StatelessWidget {
  final String stage;
  final String count;
  final String amount;
  final String note;
  const _OrderKpi(this.stage, this.count, this.amount, this.note);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: _storyCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stage,
                style:
                    RobinTheme.headingSm.copyWith(color: RobinTheme.primary)),
            const SizedBox(height: 8),
            Row(children: [
              Text(count, style: RobinTheme.numericMd),
              const SizedBox(width: 8),
              Expanded(
                child: Text(amount,
                    textAlign: TextAlign.right,
                    softWrap: true,
                    style: RobinTheme.bodySm),
              ),
            ]),
            const SizedBox(height: 5),
            Text(note, softWrap: true, style: RobinTheme.labelXs),
          ],
        ),
      );
}

class _ApprovalRuleGuide extends StatelessWidget {
  const _ApprovalRuleGuide();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: RobinTheme.signalYellow.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text('75~80%: 영업팀장 결재 · 80% 이상: 사업부장 추가 결재',
            style: RobinTheme.labelXs.copyWith(fontWeight: FontWeight.w700)),
      );
}

class _SimulationTable extends StatelessWidget {
  const _SimulationTable();
  @override
  Widget build(BuildContext context) => const _CompactTable(
        headers: ['구분', '기준', '예상 원가', '근거'],
        rows: [
          ['가공품', '과거 유사 실적가', '31,200만원', '최근 3개 프로젝트 평균'],
          ['기성품', '표준 단가+옵션', '42,500만원', '홀 수·길이 옵션 반영'],
          ['기타/외주', '구매 견적', '8,400만원', '견적 증빙 첨부'],
        ],
      );
}

class _OrderChangeHistory extends StatelessWidget {
  const _OrderChangeHistory();

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: RobinTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: RobinTheme.border),
        ),
        child: Column(
          children: [
            const ListTile(
              dense: true,
              leading: Icon(Icons.rate_review_outlined,
                  color: RobinTheme.signalYellow),
              title: Text('제안검토'),
              subtitle:
                  Text('2026-08-17 15:32 · 이설계 책임 · Proposal 도면 Rev.03 검토'),
              trailing: Chip(label: Text('별도 표기')),
            ),
            const Divider(height: 1),
            const ListTile(
              dense: true,
              leading: Icon(Icons.history, color: RobinTheme.signalGreen),
              title: Text('수주 사양 변경'),
              subtitle: Text(
                  '2026-08-18 09:10 · 김로빈 책임 · 가반하중 60kg → 80kg · 고객 승인서 첨부'),
              trailing: Chip(label: Text('이력 저장')),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('사양 변경 입력창을 열었습니다.'))),
                  icon: const Icon(Icons.edit_note_outlined, size: 17),
                  label: const Text('사양 수정/제안검토 추가'),
                ),
              ),
            ),
          ],
        ),
      );
}

class _ApprovalArrow extends StatelessWidget {
  const _ApprovalArrow();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.arrow_forward, color: RobinTheme.textMuted),
      );
}

class _ProjectStageSummary extends StatelessWidget {
  const _ProjectStageSummary();
  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          const counts = [15, 12, 9, 7, 5, 3];
          final columns = constraints.maxWidth >= 1050 ? 6 : 3;
          final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_projectStages.length, (index) {
              return SizedBox(
                width: width,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 58),
                  padding: const EdgeInsets.all(10),
                  decoration: _storyCard(),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: index < 2
                          ? RobinTheme.successLight
                          : RobinTheme.accentLight,
                      child: Text('${index + 1}', style: RobinTheme.labelXs),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                        child: Text(_projectStages[index],
                            softWrap: true, style: RobinTheme.bodySm)),
                    const SizedBox(width: 4),
                    Text('${counts[index]}', style: RobinTheme.headingSm),
                  ]),
                ),
              );
            }),
          );
        },
      );
}

const _projectStages = ['설계', '구매', '생산', '품질', '물류', '마감'];
const _projectStageOwners = [
  '이설계 책임',
  '김구매 팀장',
  '박생산 책임',
  '최품질 책임',
  '김로빈 책임',
  '김로빈 책임',
];

Widget _progressDot(_ProjectRow row, int index, int current) {
  final done = index < current;
  final active = index == current;
  final seed = int.tryParse(row.number.split('-').last) ?? 0;
  final day = 18 + index + (seed % 3);
  final completion = done
      ? '2026-08-${day.toString().padLeft(2, '0')}'
      : active
          ? '진행 중'
          : '-';
  return Tooltip(
    key: ValueKey('project-stage-${row.number}-${_projectStages[index]}'),
    message:
        '${_projectStages[index]} · 담당자: ${_projectStageOwners[index]} · 완료일: $completion',
    child: Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: done
            ? RobinTheme.signalGreen
            : active
                ? RobinTheme.signalYellow
                : RobinTheme.background,
        shape: BoxShape.circle,
        border: Border.all(
            color: done
                ? RobinTheme.signalGreen
                : active
                    ? RobinTheme.signalYellow
                    : RobinTheme.border),
      ),
      child: Icon(
          done
              ? Icons.check
              : active
                  ? Icons.more_horiz
                  : Icons.circle,
          size: 13,
          color: done || active ? Colors.white : RobinTheme.textMuted),
    ),
  );
}

Widget _stageChip(String stage) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: RobinTheme.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(stage,
          style: RobinTheme.labelXs.copyWith(
              color: RobinTheme.primary, fontWeight: FontWeight.w700)),
    );

Widget _ratioChip(double value) {
  if (value == 0) return const Text('-');
  final color = value >= 80
      ? RobinTheme.signalRed
      : value >= 75
          ? RobinTheme.signalYellow
          : RobinTheme.signalGreen;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10)),
    child: Text('${value.toStringAsFixed(1)}%',
        style: RobinTheme.labelXs
            .copyWith(color: color, fontWeight: FontWeight.w700)),
  );
}

Widget _statusChip(String value) {
  final color = value.contains('완료') || value.contains('확정')
      ? RobinTheme.signalGreen
      : value.contains('긴급') || value.contains('사업부장')
          ? RobinTheme.signalRed
          : RobinTheme.signalYellow;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10)),
    child: Text(value,
        style: RobinTheme.labelXs
            .copyWith(color: color, fontWeight: FontWeight.w700)),
  );
}

Widget _storyTableText(
  double width,
  String value, {
  TextStyle? style,
}) =>
    SizedBox(
      width: width,
      child: Text(value, softWrap: true, style: style),
    );

Widget _detailValue(String label, String value) => Container(
      width: 175,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
          color: RobinTheme.background, borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: RobinTheme.labelXs),
        const SizedBox(height: 4),
        Text(value, style: RobinTheme.headingSm),
      ]),
    );

Widget _approvalStep(String title, String subtitle, bool completed) => SizedBox(
      width: 205,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (completed ? RobinTheme.signalGreen : RobinTheme.primary)
              .withValues(alpha: .08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(children: [
          Icon(completed ? Icons.check_circle : Icons.schedule,
              color: completed ? RobinTheme.signalGreen : RobinTheme.primary),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            softWrap: true,
            style: RobinTheme.headingSm,
          ),
          Text(subtitle,
              textAlign: TextAlign.center,
              softWrap: true,
              style: RobinTheme.labelXs),
        ]),
      ),
    );

String _money(double value) => value
    .toStringAsFixed(0)
    .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');

BoxDecoration _storyCard() => BoxDecoration(
      color: RobinTheme.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: RobinTheme.border),
    );

class _OrderRow {
  final String number;
  final String customer;
  final String channel;
  final String owner;
  final String stage;
  final String task;
  final double proposalPrice;
  final double simulatedCost;
  final double materialRatio;
  final double erpCost;
  final String approval;
  final int orderChanges;
  final int specChanges;

  const _OrderRow(
      this.number,
      this.customer,
      this.channel,
      this.owner,
      this.stage,
      this.task,
      this.proposalPrice,
      this.simulatedCost,
      this.materialRatio,
      this.erpCost,
      this.approval,
      this.orderChanges,
      this.specChanges);
}

class _ProjectRow {
  final String number;
  final String projectName;
  final String stage;
  final String dueDate;
  final String changedDueDate;
  final bool urgent;
  final String memo;
  final String channel;

  const _ProjectRow(this.number, this.projectName, this.stage, this.dueDate,
      this.changedDueDate, this.urgent, this.memo, this.channel);
}

class _ProjectMemoEntry {
  final String id;
  final String? parentId;
  final String author;
  final String assignee;
  final String message;
  final String at;
  final String? attachment;

  const _ProjectMemoEntry({
    required this.id,
    required this.parentId,
    required this.author,
    required this.assignee,
    required this.message,
    required this.at,
    required this.attachment,
  });
}

class _ProjectMemoResult {
  final List<_ProjectMemoEntry> entries;
  final List<_ProjectMemoEntry> newEntries;

  const _ProjectMemoResult({
    required this.entries,
    required this.newEntries,
  });
}
