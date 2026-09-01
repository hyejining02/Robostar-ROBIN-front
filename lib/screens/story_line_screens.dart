import 'package:flutter/material.dart';

import '../services/desktop_file_service.dart';
import '../services/project_todo_service.dart';
import '../theme/robin_theme.dart';
import '../utils/search_query.dart';
import '../widgets/app_bar.dart';
import '../widgets/robin_dialog.dart';
import '../widgets/user_profile.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  String _stage = '전체 단계';
  String _searchType = '고객사별';
  _OrderRow? _selected;
  final _tableController = ScrollController();
  final _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (robinUserProfile.value.isDealer) return _buildDealerBidScreen();
    final query = _searchController.text.trim().toLowerCase();
    final visible = _rows.where((row) {
      if (_stage != '전체 단계' && row.stage != _stage) {
        return false;
      }
      final fields = switch (_searchType) {
        '담당자별' => [row.owner, row.task, row.number],
        '재료비율별' => [
            '${row.materialRatio.toStringAsFixed(1)}%',
            row.task,
            row.number,
          ],
        _ => [row.customer, row.task, row.number],
      };
      return matchesSearchQuery(fields, query);
    }).toList();

    return Scaffold(
      backgroundColor: RobinTheme.background,
      appBar: const RobinAppBar(title: '수주관리'),
      body: SingleChildScrollView(
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
                      Text('수주관리', style: RobinTheme.headingLg),
                      const SizedBox(height: 3),
                      Text('전체 파이프라인의 가격·원가·이익률·결재 현황을 한 화면에서 조회합니다.',
                          style: RobinTheme.bodySm),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('파이프라인 등록 화면에서 신규 수주를 등록합니다.')),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('수주 등록'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const _OrderKpiGrid(),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: _storyCard(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stages = Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (final stage in const [
                        '전체 단계',
                        'Assess',
                        'Proposal',
                        'Negotiation',
                        'Closed Won',
                        'Closed Lost'
                      ])
                        ChoiceChip(
                          label: Text(stage == '전체 단계' ? '전체' : stage),
                          selected: _stage == stage,
                          onSelected: (_) => setState(() => _stage = stage),
                        ),
                    ],
                  );
                  final search = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 160,
                        child: DropdownButtonFormField<String>(
                          key: const ValueKey('order-search-type'),
                          isExpanded: true,
                          initialValue: _searchType,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: const ['고객사별', '담당자별', '재료비율별']
                              .map((value) => DropdownMenuItem(
                                  value: value, child: Text(value)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _searchType = value ?? '고객사별'),
                        ),
                      ),
                      const SizedBox(width: 7),
                      SizedBox(
                        width: constraints.maxWidth >= 1100 ? 300 : 260,
                        child: TextField(
                          key: const ValueKey('order-management-search'),
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: '고객사 / 프로젝트명 검색 (% 조건)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  );
                  if (constraints.maxWidth < 1050) {
                    return Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [stages, search],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: stages),
                      const SizedBox(width: 10),
                      search,
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
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
                        headingRowHeight: 40,
                        dataRowMinHeight: 40,
                        dataRowMaxHeight: 52,
                        columns: [
                          DataColumn(label: _storyTableText(86, '수주번호')),
                          DataColumn(label: _storyTableText(76, '단계')),
                          DataColumn(label: _storyTableText(70, '고객사')),
                          DataColumn(label: _storyTableText(180, '프로젝트명')),
                          DataColumn(
                              label: _storyTableText(100, '수주제안가(ROBIN)')),
                          DataColumn(label: _storyTableText(62, '재료비율')),
                          DataColumn(label: _storyTableText(55, '이익률')),
                          DataColumn(label: _storyTableText(86, '결재상태')),
                          DataColumn(label: _storyTableText(76, '담당자')),
                          DataColumn(label: _storyTableText(62, '처리')),
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
                              DataCell(_storyTableText(70, row.customer)),
                              DataCell(_storyTableText(180, row.task)),
                              DataCell(_storyTableText(
                                  100, '${_money(row.proposalPrice)}만원')),
                              DataCell(SizedBox(
                                  width: 62,
                                  child: _ratioChip(row.materialRatio))),
                              DataCell(_storyTableText(
                                  55,
                                  row.materialRatio == 0
                                      ? '-'
                                      : '${(100 - row.materialRatio).toStringAsFixed(1)}%')),
                              DataCell(SizedBox(
                                  width: 86, child: _statusChip(row.approval))),
                              DataCell(_storyTableText(76, row.owner)),
                              DataCell(SizedBox(
                                width: 62,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(0, 30),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 5),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () =>
                                      _showOrderDetail(context, row),
                                  child: Text(row.approval.contains('결재')
                                      ? '결재'
                                      : '상세'),
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
        padding: const EdgeInsets.all(16),
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
      builder: (dialogContext) => RobinAlertDialog(
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
      builder: (dialogContext) => RobinAlertDialog(
        title: Text('${row.number} · ${row.task}'),
        content: SizedBox(
          width: 760,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('수주·원가 요약', style: RobinTheme.headingSm),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _detailValue('고객사', row.customer),
                    _detailValue('영업 채널', row.channel),
                    _detailValue('담당자', row.owner),
                    _detailValue(
                        '수주제안가(ROBIN)', '${_money(row.proposalPrice)}만원'),
                    _detailValue(
                        '원가 시뮬(ROBIN)',
                        row.simulatedCost == 0
                            ? '-'
                            : '${_money(row.simulatedCost)}만원'),
                    _detailValue('원가 확정(ERP)',
                        row.erpCost == 0 ? '-' : '${_money(row.erpCost)}만원'),
                    _detailValue(
                        '수주확정가(ERP)',
                        row.stage == 'Closed Won'
                            ? '${_money(row.proposalPrice * .98)}만원'
                            : '-'),
                    _detailValue('재료비율',
                        row.materialRatio == 0 ? '-' : '${row.materialRatio}%'),
                    _detailValue(
                        '이익률',
                        row.materialRatio == 0
                            ? '-'
                            : '${(100 - row.materialRatio).toStringAsFixed(1)}%'),
                    _detailValue('결재상태', row.approval),
                  ],
                ),
                const SizedBox(height: 16),
                Text('제안·사양 정보', style: RobinTheme.headingSm),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _detailValue('Proposal 도면', 'PDM Rev.03 연계'),
                    _detailValue('상세 Spec.', '가반하중 80kg · Reach 2,100mm'),
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
  String _selectedProjectNumber = 'PJ-2608-001';
  final _tableController = ScrollController();
  final _projectListVerticalController = ScrollController();
  final Map<String, List<_ProjectMemoEntry>> _memoThreads = {};
  int _selectedStageIndex = 1;
  String _projectSearch = '';

  static final _projects = <_ProjectRow>[
    const _ProjectRow(
      number: 'SO-2608-014',
      projectNumber: 'PJ-2608-001',
      projectName: 'A사 AGV 통합 자동화 프로젝트',
      orderName: '로봇 본체',
      customer: 'A사',
      pm: '김PM 책임',
      model: 'RS-N120',
      stage: '구매',
      leadTime: '18.5일',
      progress: 34,
      dueDate: '2026-09-20',
      changedDueDate: '2026-09-27',
      urgent: true,
      memo: 'BOM 장기재고 2건 확인 필요',
      channel: '서울 대리점',
      closeStatus: '진행중',
    ),
    const _ProjectRow(
      number: 'SO-2608-011',
      projectNumber: 'PJ-2608-001',
      projectName: 'A사 AGV 통합 자동화 프로젝트',
      orderName: '이송 모듈',
      customer: 'A사',
      pm: '김PM 책임',
      model: 'AMR-500',
      stage: '생산',
      leadTime: '22.0일',
      progress: 52,
      dueDate: '2026-09-22',
      changedDueDate: '-',
      urgent: false,
      memo: 'Work Center 생산예정일 입력 대기',
      channel: '서울 대리점',
      closeStatus: '진행중',
    ),
    const _ProjectRow(
      number: 'SO-2608-009',
      projectNumber: 'PJ-2608-001',
      projectName: 'A사 AGV 통합 자동화 프로젝트',
      orderName: '그리퍼 어셈블리',
      customer: 'A사',
      pm: '김PM 책임',
      model: 'GRP-VAC-40',
      stage: '품질',
      leadTime: '15.5일',
      progress: 68,
      dueDate: '2026-09-24',
      changedDueDate: '-',
      urgent: false,
      memo: 'OQC 검사 예정',
      channel: '서울 대리점',
      closeStatus: '진행중',
    ),
    const _ProjectRow(
      number: 'SO-2608-006',
      projectNumber: 'PJ-2608-002',
      projectName: 'D사 검사 자동화 설비',
      orderName: '검사 자동화 본체',
      customer: 'D사',
      pm: '박PM 책임',
      model: 'VI-220',
      stage: '물류',
      leadTime: '27.0일',
      progress: 84,
      dueDate: '2026-08-24',
      changedDueDate: '-',
      urgent: false,
      memo: '납품처 확인 완료 · 배차 대기',
      channel: '본사 직판',
      closeStatus: '진행중',
    ),
    const _ProjectRow(
      number: 'SO-2608-002',
      projectNumber: 'PJ-2608-003',
      projectName: 'E사 제어시스템',
      orderName: '안전·제어 패키지',
      customer: 'E사',
      pm: '이PM 책임',
      model: 'RCX-500',
      stage: '마감',
      leadTime: '12.0일',
      progress: 96,
      dueDate: '2026-08-18',
      changedDueDate: '-',
      urgent: false,
      memo: 'ERP 거래명세서 발생 대기',
      channel: '부산 대리점',
      closeStatus: '마감대기',
    ),
    ..._buildAdditionalProjectRows(),
  ];

  @override
  void dispose() {
    _tableController.dispose();
    _projectListVerticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (robinUserProfile.value.isDealer) return _buildDealerProgressScreen();
    return Scaffold(
      backgroundColor: RobinTheme.background,
      appBar: const RobinAppBar(title: '프로젝트 관리'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('프로젝트 관리', style: RobinTheme.headingLg),
            const SizedBox(height: 4),
            Text('프로젝트를 선택하고 포함된 수주별로 설계부터 마감까지 독립 관리합니다.',
                style: RobinTheme.bodySm),
            const SizedBox(height: 10),
            const _ProjectStageSummary(),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: _storyCard(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '프로젝트 현황 — ${_filteredProjectSummaries.length}건',
                                  style: RobinTheme.headingSm),
                              Text('프로젝트 선택 시 포함된 수주별 진행현황을 조회합니다.',
                                  style: RobinTheme.labelXs),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 260,
                          child: TextField(
                            key: const ValueKey('project-management-search'),
                            decoration: const InputDecoration(
                              isDense: true,
                              prefixIcon: Icon(Icons.search, size: 18),
                              hintText: '프로젝트명 / 수주번호 / 고객사 검색',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                setState(() => _projectSearch = value),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  SizedBox(
                    height: (_filteredProjectSummaries.length * 48 + 46)
                        .clamp(94, 300)
                        .toDouble(),
                    child: Scrollbar(
                      controller: _projectListVerticalController,
                      thumbVisibility: _filteredProjectSummaries.length > 5,
                      child: SingleChildScrollView(
                        key: const ValueKey('project-list-scroll'),
                        controller: _projectListVerticalController,
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
                                constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth),
                                child: DataTable(
                                  horizontalMargin: 10,
                                  checkboxHorizontalMargin: 8,
                                  columnSpacing: 14,
                                  headingRowHeight: 38,
                                  dataRowMinHeight: 38,
                                  dataRowMaxHeight: 48,
                                  columns: const [
                                    DataColumn(label: Text('프로젝트번호')),
                                    DataColumn(label: Text('프로젝트명')),
                                    DataColumn(label: Text('Lead Time')),
                                    DataColumn(label: Text('고객사')),
                                    DataColumn(label: Text('PM')),
                                    DataColumn(label: Text('현재단계')),
                                    DataColumn(label: Text('진척도')),
                                    DataColumn(label: Text('납기일')),
                                    DataColumn(label: Text('변경 납기일')),
                                    DataColumn(label: Text('상태')),
                                  ],
                                  rows:
                                      _filteredProjectSummaries.map((project) {
                                    return DataRow(
                                      selected: _selectedProjectNumber ==
                                          project.projectNumber,
                                      onSelectChanged: (_) => setState(() {
                                        _selectedProjectNumber =
                                            project.projectNumber;
                                        _selected = _projects.firstWhere(
                                            (row) =>
                                                row.projectNumber ==
                                                project.projectNumber);
                                        _selectedStageIndex = _projectStages
                                            .indexOf(_selected.stage);
                                      }),
                                      cells: [
                                        DataCell(Text(project.projectNumber,
                                            style: RobinTheme.bodySm.copyWith(
                                                color: RobinTheme.primary,
                                                fontWeight: FontWeight.w700))),
                                        DataCell(SizedBox(
                                            width: 210,
                                            child: Text(project.projectName,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis))),
                                        DataCell(Text(project.leadTime)),
                                        DataCell(Text(project.customer)),
                                        DataCell(Text(project.pm)),
                                        DataCell(_stageChip(project.stage)),
                                        DataCell(SizedBox(
                                          width: 92,
                                          child: Row(children: [
                                            Expanded(
                                                child: LinearProgressIndicator(
                                              value: project.progress / 100,
                                              minHeight: 5,
                                            )),
                                            const SizedBox(width: 5),
                                            Text('${project.progress}%'),
                                          ]),
                                        )),
                                        DataCell(Text(project.dueDate)),
                                        DataCell(Row(children: [
                                          Text(project.changedDueDate),
                                          if (project.urgent) ...[
                                            const SizedBox(width: 5),
                                            _statusChip('긴급'),
                                          ]
                                        ])),
                                        DataCell(_statusChip(
                                            project.urgent ? '납기 위험' : '진행중')),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildProjectOrderList(),
            const SizedBox(height: 8),
            Container(
              decoration: _storyCard(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSelectedOrderOverview(),
                  const Divider(height: 1),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    child: Row(
                      children: [
                        for (var index = 0;
                            index < _projectStages.length;
                            index++) ...[
                          _progressDot(
                            _selected,
                            index,
                            _projectStages.indexOf(_selected.stage),
                          ),
                          const SizedBox(width: 4),
                          Text(_projectStages[index],
                              style: RobinTheme.labelXs),
                          if (index < _projectStages.length - 1)
                            Expanded(
                              child: Container(
                                height: 1,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 7),
                                color: RobinTheme.border,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _buildStageSelector(),
                  const Divider(height: 1),
                  _buildSelectedStagePanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ProjectSummary> get _filteredProjectSummaries {
    final query = _projectSearch.trim().toLowerCase();
    if (query.isEmpty) return _projectSummaries;
    return _projectSummaries.where((project) {
      return project.projectNumber.toLowerCase().contains(query) ||
          project.projectName.toLowerCase().contains(query) ||
          project.customer.toLowerCase().contains(query) ||
          _projects.any((row) =>
              row.projectNumber == project.projectNumber &&
              row.number.toLowerCase().contains(query));
    }).toList();
  }

  Widget _buildSelectedOrderOverview() => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final title = Text(
                    '${_selected.number} · ${_selected.orderName}',
                    style: RobinTheme.headingSm);
                final actions = Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _stageChip('현재 단계: ${_selected.stage}'),
                    OutlinedButton.icon(
                      onPressed: () => _showMemoDialog(context),
                      icon: const Icon(Icons.note_add_outlined, size: 17),
                      label: const Text('메모·댓글'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showDueDateDialog(context),
                      icon: const Icon(Icons.event_repeat, size: 17),
                      label: const Text('납기 변경'),
                    ),
                  ],
                );
                if (constraints.maxWidth >= 820) {
                  return Row(children: [Expanded(child: title), actions]);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 8), actions],
                );
              },
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1050
                    ? 6
                    : constraints.maxWidth >= 680
                        ? 3
                        : 2;
                final width =
                    (constraints.maxWidth - (columns - 1) * 8) / columns;
                final items = [
                  ('수주번호', _selected.number),
                  ('수주명', _selected.orderName),
                  ('모델명', _selected.model),
                  ('고객사', _selected.customer),
                  ('Lead Time', _selected.leadTime),
                  (
                    '납기일',
                    _selected.changedDueDate == '-'
                        ? _selected.dueDate
                        : _selected.changedDueDate
                  ),
                ];
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in items)
                      Container(
                        width: width,
                        constraints: const BoxConstraints(minHeight: 58),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 9),
                        decoration: BoxDecoration(
                          color: RobinTheme.background,
                          border: Border.all(color: RobinTheme.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.$1, style: RobinTheme.labelXs),
                            const SizedBox(height: 3),
                            Text(item.$2,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: RobinTheme.bodySm
                                    .copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      );

  Widget _buildStageSelector() => SizedBox(
        width: double.infinity,
        child: Wrap(
          children: List.generate(_projectStages.length, (index) {
            final selected = _selectedStageIndex == index;
            return InkWell(
              key: ValueKey('project-stage-tab-${_projectStages[index]}'),
              onTap: () => setState(() => _selectedStageIndex = index),
              child: Container(
                width: 112,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? RobinTheme.primary : Colors.transparent,
                  border: Border(
                    right: const BorderSide(color: RobinTheme.border),
                    bottom: BorderSide(
                        color:
                            selected ? RobinTheme.primary : Colors.transparent,
                        width: 2),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _projectStages[index],
                  style: RobinTheme.bodySm.copyWith(
                    color: selected ? Colors.white : RobinTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }),
        ),
      );

  Widget _buildSelectedStagePanel() => switch (_selectedStageIndex) {
        0 => _DesignPanel(project: _selected),
        1 => _PurchasePanel(project: _selected, projects: _projects),
        2 => _ProductionPanel(project: _selected, projects: _projects),
        3 => _QualityPanel(project: _selected, projects: _projects),
        4 => _LogisticsPanel(project: _selected, projects: _projects),
        _ => _ClosingPanel(project: _selected, projects: _projects),
      };

  List<_ProjectSummary> get _projectSummaries {
    final numbers = _projects.map((row) => row.projectNumber).toSet();
    return [
      for (final number in numbers)
        (() {
          final rows =
              _projects.where((row) => row.projectNumber == number).toList();
          final current = rows.reduce((a, b) =>
              _projectStages.indexOf(a.stage) >= _projectStages.indexOf(b.stage)
                  ? a
                  : b);
          final progress =
              rows.fold<int>(0, (sum, row) => sum + row.progress) ~/
                  rows.length;
          final maxLeadTime = rows
              .map((row) =>
                  double.tryParse(row.leadTime.replaceAll('일', '')) ?? 0)
              .reduce((a, b) => a > b ? a : b);
          final changed = rows
              .map((row) => row.changedDueDate)
              .firstWhere((value) => value != '-', orElse: () => '-');
          return _ProjectSummary(
            projectNumber: number,
            projectName: rows.first.projectName,
            leadTime: '${maxLeadTime.toStringAsFixed(1)}일',
            customer: rows.first.customer,
            pm: rows.first.pm,
            stage: current.stage,
            progress: progress,
            dueDate: rows.map((row) => row.dueDate).last,
            changedDueDate: changed,
            urgent: rows.any((row) => row.urgent),
          );
        })(),
    ];
  }

  List<_ProjectRow> get _selectedProjectOrders => _projects
      .where((row) => row.projectNumber == _selectedProjectNumber)
      .toList();

  Widget _buildProjectOrderList() {
    final orders = _selectedProjectOrders;
    return Container(
      width: double.infinity,
      decoration: _storyCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_selectedProjectNumber · ${orders.first.projectName}',
                        style: RobinTheme.headingSm,
                      ),
                      Text('프로젝트는 상위 묶음이며 실제 진행·납기·마감은 수주번호별로 독립 관리합니다.',
                          style: RobinTheme.labelXs),
                    ],
                  ),
                ),
                Chip(label: Text('수주 ${orders.length}건')),
              ],
            ),
          ),
          const Divider(height: 1),
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  horizontalMargin: 10,
                  columnSpacing: 16,
                  headingRowHeight: 36,
                  dataRowMinHeight: 38,
                  dataRowMaxHeight: 44,
                  columns: const [
                    DataColumn(label: Text('수주번호')),
                    DataColumn(label: Text('수주명')),
                    DataColumn(label: Text('모델명')),
                    DataColumn(label: Text('현재 프로세스')),
                    DataColumn(label: Text('Lead Time')),
                    DataColumn(label: Text('납기일')),
                    DataColumn(label: Text('진척도')),
                    DataColumn(label: Text('마감 상태')),
                  ],
                  rows: orders.map((row) {
                    return DataRow(
                      selected: _selected.number == row.number,
                      onSelectChanged: (_) => setState(() {
                        _selected = row;
                        _selectedStageIndex = _projectStages.indexOf(row.stage);
                      }),
                      cells: [
                        DataCell(Text(row.number,
                            style: RobinTheme.bodySm.copyWith(
                                color: RobinTheme.primary,
                                fontWeight: FontWeight.w700))),
                        DataCell(SizedBox(
                            width: 155,
                            child: Text(row.orderName,
                                maxLines: 1, overflow: TextOverflow.ellipsis))),
                        DataCell(Text(row.model)),
                        DataCell(_stageChip(row.stage)),
                        DataCell(Text(row.leadTime)),
                        DataCell(Text(row.changedDueDate == '-'
                            ? row.dueDate
                            : row.changedDueDate)),
                        DataCell(SizedBox(
                          width: 100,
                          child: Row(children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: row.progress / 100,
                                minHeight: 5,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text('${row.progress}%'),
                          ]),
                        )),
                        DataCell(_statusChip(row.closeStatus)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(16),
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
      builder: (dialogContext) => RobinAlertDialog(
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

  Future<void> _selectAttachment() async {
    try {
      final file = await DesktopFileService.pickDocument();
      if (file == null || !mounted) return;
      setState(() => _attachment.text = file.name);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('파일 선택 실패: $error')));
    }
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const ValueKey('project-memo-attachment'),
                            controller: _attachment,
                            decoration: const InputDecoration(
                              labelText: '산출물 파일명 (선택)',
                              hintText: 'PDF, XLSX, DWG 등',
                              prefixIcon: Icon(Icons.attach_file),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        OutlinedButton.icon(
                          onPressed: _selectAttachment,
                          icon:
                              const Icon(Icons.folder_open_outlined, size: 16),
                          label: const Text('파일 선택'),
                        ),
                      ],
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

class _DesignPanel extends StatelessWidget {
  final _ProjectRow project;
  const _DesignPanel({required this.project});

  @override
  Widget build(BuildContext context) => _panel(
        title: '설계 현황 — ${project.number}',
        action: const Chip(label: Text('Proposal 확정본 연계')),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StageInfoGrid(items: [
              ('설계 담당자', '이설계 책임'),
              ('설계 착수일', '2026-08-12'),
              ('도면 승인일', '2026-08-20'),
              ('설계 상태', '완료'),
            ]),
            SizedBox(height: 12),
            _CompactTable(
              headers: ['도면/문서', 'Revision', '상태', '최종일', '출처'],
              rows: [
                [
                  'Concept_Layout.pdf',
                  'Rev.03',
                  '확정',
                  '2026-08-19',
                  'Proposal'
                ],
                ['Spec_RS-N120.xlsx', 'Rev.05', '확정', '2026-08-20', 'ROBIN'],
                ['Assembly_3D.step', 'Rev.02', '검토완료', '2026-08-21', 'PDM'],
              ],
            ),
          ],
        ),
      );
}

class _PurchasePanel extends StatelessWidget {
  final _ProjectRow project;
  final List<_ProjectRow> projects;
  const _PurchasePanel({required this.project, required this.projects});

  @override
  Widget build(BuildContext context) => _panel(
        title: '구매 현황 — ${project.number} · ${project.orderName}',
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
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('수주번호 기준 BOM 10개 품목 관리'),
            SizedBox(height: 8),
            _CompactTable(
              headers: [
                '품번',
                '품목명',
                '재고상태',
                '필요수량',
                '재고/발주',
                '입고예정일',
                '실제입고일',
                '구매 진행상태'
              ],
              rows: [
                ['B-001', '서보모터', '일반재고', '4', '재고', '-', '08-21', '입고완료'],
                ['B-002', '감속기', '장기재고', '2', '확인', '08-29', '-', '확인 필요'],
                ['B-003', '안전센서', '발주품', '8', '발주', '08-26', '-', '발주 완료'],
                ['B-004', '제어반 부품', '사급품', '1', '사급', '08-22', '-', '입고 대기'],
                ['B-005', '로봇 케이블', '일반재고', '4', '재고', '-', '08-20', '입고완료'],
                ['B-006', '안전펜스', '발주품', '12', '발주', '09-01', '-', '제작중'],
                ['B-007', 'PLC 모듈', '일반재고', '2', '재고', '-', '08-21', '입고완료'],
                ['B-008', '비전 카메라', '발주품', '2', '발주', '09-03', '-', '납기확인'],
                ['B-009', '그리퍼 패드', '일반재고', '16', '재고', '-', '08-22', '입고완료'],
                ['B-010', '공압 유닛', '발주품', '4', '발주', '08-30', '-', '발주 완료'],
              ],
            ),
            SizedBox(height: 8),
            Text('재고구분·입고예정일·실제입고일·구매 진행상태를 ERP BOM 기준으로 관리합니다.'),
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
        title: '생산 현황 — ${project.number} · ${project.orderName}',
        action: FilledButton.icon(
            onPressed: () =>
                _openProjectStageInput(context, '생산', project, projects),
            icon: const Icon(Icons.edit_calendar_outlined, size: 16),
            label: const Text('생산 예정일 입력')),
        child: const _CompactTable(
          headers: [
            '품번',
            'Work Center',
            '생산계획',
            '작업지시',
            '생산실적',
            '창고입고',
            '생산 예정일',
            '진행률'
          ],
          rows: [
            [
              'RS-N120-001',
              'WC-조립1',
              '4EA',
              '4EA',
              '2EA',
              '0EA',
              '2026-08-25',
              '50%'
            ],
            [
              'RS-CTRL-001',
              'WC-배선',
              '4EA',
              '4EA',
              '3EA',
              '1EA',
              '2026-08-23',
              '75%'
            ],
            ['RS-GRP-001', '사내도급 A', '2EA', '2EA', '0EA', '0EA', '입력 대기', '0%'],
          ],
        ),
      );
}

class _QualityPanel extends StatefulWidget {
  final _ProjectRow project;
  final List<_ProjectRow> projects;
  const _QualityPanel({required this.project, required this.projects});

  @override
  State<_QualityPanel> createState() => _QualityPanelState();
}

class _QualityPanelState extends State<_QualityPanel> {
  String _selectedInspection = 'IQC';

  @override
  void didUpdateWidget(covariant _QualityPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.number != widget.project.number) {
      _selectedInspection = 'IQC';
    }
  }

  @override
  Widget build(BuildContext context) => _panel(
        title: '품질 현황 — ${widget.project.number} · ${widget.project.orderName}',
        action: FilledButton.icon(
            onPressed: () => _openProjectStageInput(
                context, '품질', widget.project, widget.projects),
            icon: const Icon(Icons.fact_check_outlined, size: 16),
            label: const Text('검사 결과 입력')),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StageInfoGrid(items: [
              ('수주번호', widget.project.number),
              ('도면번호', 'DWG-${widget.project.model}-B02'),
              ('모델명', widget.project.model),
              ('제품번호', 'PRD-${widget.project.number.substring(3)}-01'),
              ('고객사', widget.project.customer),
              ('현재 검사', _inspectionTitle(_selectedInspection)),
            ]),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: RobinTheme.border),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  _qualityTab('IQC', '수입검사 IQC'),
                  _qualityTab('LQC', '공정검사 LQC'),
                  _qualityTab('OQC', '출하검사 OQC'),
                ],
              ),
            ),
            _inspectionPanel(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: RobinTheme.border)),
              ),
              child: Text(
                '디폴트: 양품 · 불량 발생 시 조치 담당부서 To-Do 자동 생성',
                style: RobinTheme.bodySm,
              ),
            ),
          ],
        ),
      );

  Widget _qualityTab(String value, String label) {
    final selected = _selectedInspection == value;
    return Expanded(
      child: InkWell(
        key: ValueKey('quality-tab-${value.toLowerCase()}'),
        onTap: () => setState(() => _selectedInspection = value),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? RobinTheme.primary : RobinTheme.background,
            border: value == 'IQC'
                ? null
                : const Border(left: BorderSide(color: RobinTheme.border)),
          ),
          child: Text(
            label,
            style: RobinTheme.bodySm.copyWith(
              color: selected ? Colors.white : RobinTheme.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _inspectionPanel() {
    final (description, background, headers, rows) =
        switch (_selectedInspection) {
      'LQC' => (
          '공정검사 (LQC) — 생산 공정 중 검사. 작업지시별 검사 결과 입력',
          RobinTheme.warningLight,
          const ['공정', '작업지시번호', '검사일', '판정', '불량수량', '불량 원인', '조치 담당'],
          const [
            ['조립 공정', 'WO-2608-001', '2026-08-24', '양품', '0', '-', '-'],
            [
              '배선 공정',
              'WO-2608-002',
              '2026-08-25',
              '불량',
              '1',
              '배선 접촉 불량',
              '생산팀'
            ],
          ]
        ),
      'OQC' => (
          '출하검사 (OQC) — 출하 전 최종 검사. 합격 시 물류 단계 진행 가능',
          RobinTheme.successLight,
          const ['품목', '수량', '검사일', '판정', '불량수량', '최종 판정', '검사자'],
          const [
            ['RS-N120 완성품', '4EA', '2026-08-28', '양품', '0', '출하 가능', '최품질 책임'],
          ]
        ),
      _ => (
          '수입검사 (IQC) — 자재 입고 시 검사. 수주번호 + ERP BOM 연동. 디폴트: 양품',
          RobinTheme.accentLight,
          const [
            '품번',
            '품목명',
            '수량',
            '검사일',
            '판정',
            '불량수량',
            '불량 원인',
            '조치 담당부서',
            '조치 결과'
          ],
          const [
            [
              'RS-N120-001',
              '서보 모터 (2kW)',
              '4EA',
              '2026-08-23',
              '양품',
              '0',
              '-',
              '-',
              '완료'
            ],
            [
              'RS-CTRL-001',
              '제어기',
              '2EA',
              '2026-08-23',
              '양품',
              '0',
              '-',
              '-',
              '완료'
            ],
            [
              'SAUP-GRIPPER',
              '그리퍼 (사급품)',
              '2EA',
              '입력 대기',
              '양품',
              '0',
              '-',
              '-',
              '대기'
            ],
          ]
        ),
    };

    return Container(
      key: ValueKey('quality-panel-${_selectedInspection.toLowerCase()}'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(description, style: RobinTheme.bodySm),
          ),
          const SizedBox(height: 8),
          _CompactTable(headers: headers, rows: rows),
        ],
      ),
    );
  }

  String _inspectionTitle(String value) => switch (value) {
        'LQC' => 'LQC · 공정검사',
        'OQC' => 'OQC · 출하검사',
        _ => 'IQC · 수입검사',
      };
}

class _LogisticsPanel extends StatelessWidget {
  final _ProjectRow project;
  final List<_ProjectRow> projects;
  const _LogisticsPanel({required this.project, required this.projects});

  @override
  Widget build(BuildContext context) => _panel(
        title: '물류 / 인수증 관리 — ${project.number}',
        action: FilledButton.icon(
            onPressed: () =>
                _openProjectStageInput(context, '물류', project, projects),
            icon: const Icon(Icons.local_shipping_outlined, size: 16),
            label: const Text('납품/배차 입력')),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('납품 정보 입력 → 배차/상차 → 고객 인수 → 인수증 등록까지 관리합니다.'),
            const SizedBox(height: 10),
            _LogisticsProcessCards(project: project),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: RobinTheme.warningLight,
                border: Border.all(color: RobinTheme.signalYellow),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('완료 기준: 실제 납품 완료 + 고객 인수 확인 + 인수증 등록 완료'),
            ),
            const SizedBox(height: 12),
            const Text('인수증 이력'),
            const SizedBox(height: 6),
            const _CompactTable(
              headers: ['회차', '납품일', '인수자', '납품수량', '인수수량', '상태', '인수증', '등록자'],
              rows: [
                [
                  '1차',
                  '2026-08-28',
                  '이현장 부장',
                  '4EA',
                  '4EA',
                  '인수완료',
                  '인수증_A사.pdf',
                  '김로빈 책임'
                ],
              ],
            ),
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
        title: '마감 현황 — ${project.number} · ${project.orderName}',
        action: Row(
          children: [
            OutlinedButton.icon(
                onPressed: () => _exportClosingHistory(context),
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
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CompactTable(
              headers: ['수주번호', '고객사', '수주금액', 'ERP 거래명세서', '마감 상태', '마감일'],
              rows: [
                [
                  'SO-2608-014',
                  'A사',
                  '1,450만원',
                  'ERP-TS-260814',
                  '완료',
                  '2026-08-29'
                ],
                ['SO-2608-011', 'A사', '1,180만원', '미발행', '진행 중', '-'],
              ],
            ),
            SizedBox(height: 8),
            Text('ERP 거래명세서가 발생하면 해당 수주가 자동으로 마감 완료 처리됩니다.'),
          ],
        ),
      );

  Future<void> _exportClosingHistory(BuildContext context) async {
    final path = await DesktopFileService.saveWorkbook(
      suggestedName: '마감이력_${project.projectNumber}.xlsx',
      sheetName: '마감이력',
      headers: const ['수주번호', '고객사', '수주금액', 'ERP 거래명세서', '마감 상태', '마감일'],
      rows: const [
        ['SO-2608-014', 'A사', '1,450만원', 'ERP-TS-260814', '완료', '2026-08-29'],
        ['SO-2608-011', 'A사', '1,180만원', '미발행', '진행 중', '-'],
      ],
    );
    if (path == null || !context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Excel 저장 완료: $path')));
  }
}

class _StageInfoGrid extends StatelessWidget {
  final List<(String, String)> items;
  const _StageInfoGrid({required this.items});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900
              ? 3
              : constraints.maxWidth >= 560
                  ? 2
                  : 1;
          final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final item in items)
                Container(
                  width: width,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                  decoration: BoxDecoration(
                    color: RobinTheme.background,
                    border: Border.all(color: RobinTheme.border),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$1, style: RobinTheme.labelXs),
                      const SizedBox(height: 4),
                      Text(item.$2,
                          style: RobinTheme.bodySm
                              .copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          );
        },
      );
}

class _LogisticsProcessCards extends StatefulWidget {
  final _ProjectRow project;
  const _LogisticsProcessCards({required this.project});

  @override
  State<_LogisticsProcessCards> createState() => _LogisticsProcessCardsState();
}

class _LogisticsProcessCardsState extends State<_LogisticsProcessCards> {
  late final TextEditingController _address;
  late final TextEditingController _receiver;
  late final TextEditingController _dueDate;
  late final TextEditingController _deliveryNote;
  late final TextEditingController _driver;
  late final TextEditingController _loadedAt;
  late final TextEditingController _deliveredAt;
  late final TextEditingController _receivedAt;
  late final TextEditingController _recipient;
  late final TextEditingController _receivedQuantity;
  late final TextEditingController _receiptFile;
  String? _receiptPath;
  String _vehicle = '5톤 윙바디 / 경기1가1234';
  String _deliveryStatus = '배송 중';
  String _receiptStatus = '인수 완료';

  @override
  void initState() {
    super.initState();
    _address = TextEditingController();
    _receiver = TextEditingController();
    _dueDate = TextEditingController();
    _deliveryNote = TextEditingController();
    _driver = TextEditingController();
    _loadedAt = TextEditingController();
    _deliveredAt = TextEditingController();
    _receivedAt = TextEditingController();
    _recipient = TextEditingController();
    _receivedQuantity = TextEditingController();
    _receiptFile = TextEditingController();
    _loadProjectValues();
  }

  @override
  void didUpdateWidget(covariant _LogisticsProcessCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.number != widget.project.number) {
      _loadProjectValues();
    }
  }

  void _loadProjectValues() {
    _address.text = '창원시 ${widget.project.customer} 2공장';
    _receiver.text = '이현장 부장 / 010-1234-5678';
    _dueDate.text = widget.project.dueDate;
    _deliveryNote.text = '오전 10시 이전 도착 요청';
    _driver.text = '김기사 / 010-7777-8888';
    _loadedAt.text = '2026-08-28 08:30';
    _deliveredAt.text = '2026-08-28';
    _receivedAt.text = '2026-08-28';
    _recipient.text = '이현장 부장';
    _receivedQuantity.text = '4 / 4EA';
    _receiptFile.text = '인수증_${widget.project.customer}.pdf';
    _receiptPath = null;
    _vehicle = '5톤 윙바디 / 경기1가1234';
    _deliveryStatus = '배송 중';
    _receiptStatus = '인수 완료';
  }

  @override
  void dispose() {
    _address.dispose();
    _receiver.dispose();
    _dueDate.dispose();
    _deliveryNote.dispose();
    _driver.dispose();
    _loadedAt.dispose();
    _deliveredAt.dispose();
    _receivedAt.dispose();
    _recipient.dispose();
    _receivedQuantity.dispose();
    _receiptFile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 980 ? 3 : 1;
          final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _inputCard(
                    width: width,
                    title: '① 영업 입력 — 납품 정보',
                    children: [
                      _field('납품처 주소', _address,
                          key: 'logistics-address-input'),
                      _field('수령 담당자 / 연락처', _receiver),
                      _field('납품 예정일', _dueDate,
                          icon: Icons.calendar_month_outlined),
                      _field('납품 특이사항', _deliveryNote, maxLines: 2),
                    ],
                  ),
                  _inputCard(
                    width: width,
                    title: '② 물류담당자 입력 — 배송 처리',
                    children: [
                      _dropdown(
                        label: '화물차 배정',
                        value: _vehicle,
                        values: const [
                          '5톤 윙바디 / 경기1가1234',
                          '2.5톤 트럭 / 서울34나5678',
                          '미배정'
                        ],
                        onChanged: (value) =>
                            setState(() => _vehicle = value ?? _vehicle),
                      ),
                      _field('기사 / 연락처', _driver),
                      _field('상차 완료일시', _loadedAt,
                          icon: Icons.schedule_outlined),
                      _field('실제 납품일', _deliveredAt,
                          icon: Icons.calendar_month_outlined),
                      _dropdown(
                        key: 'logistics-delivery-status',
                        label: '배송 상태',
                        value: _deliveryStatus,
                        values: const [
                          '준비 중',
                          '배차 완료',
                          '상차 완료',
                          '배송 중',
                          '납품 완료'
                        ],
                        onChanged: (value) => setState(
                            () => _deliveryStatus = value ?? _deliveryStatus),
                      ),
                    ],
                  ),
                  _inputCard(
                    width: width,
                    title: '③ 인수증 관리 — 고객 인수 확인',
                    highlighted: true,
                    children: [
                      _dropdown(
                        key: 'logistics-receipt-status',
                        label: '인수 상태',
                        value: _receiptStatus,
                        values: const ['인수 대기', '인수 완료', '부분 인수', '반려 / 재납품'],
                        onChanged: (value) => setState(
                            () => _receiptStatus = value ?? _receiptStatus),
                      ),
                      _field('인수일자', _receivedAt,
                          icon: Icons.calendar_month_outlined),
                      _field('인수자', _recipient),
                      _field('인수 수량', _receivedQuantity),
                      Row(
                        children: [
                          Expanded(child: _field('인수증 파일', _receiptFile)),
                          const SizedBox(width: 6),
                          OutlinedButton(
                            key: const ValueKey('logistics-receipt-upload'),
                            onPressed: _selectReceipt,
                            child: const Text('업로드'),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 6,
                        children: [
                          TextButton.icon(
                            onPressed: _previewReceipt,
                            icon:
                                const Icon(Icons.visibility_outlined, size: 16),
                            label: const Text('미리보기'),
                          ),
                          TextButton.icon(
                            onPressed: _downloadReceipt,
                            icon: const Icon(Icons.download_outlined, size: 16),
                            label: const Text('다운로드'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 7,
                children: [
                  OutlinedButton(
                    onPressed: () => _showMessage('물류 정보를 임시 저장했습니다.'),
                    child: const Text('임시 저장'),
                  ),
                  FilledButton(
                    key: const ValueKey('logistics-save'),
                    onPressed: () => _showMessage('물류 및 인수증 정보를 저장했습니다.'),
                    child: const Text('저장'),
                  ),
                ],
              ),
            ],
          );
        },
      );

  Widget _inputCard({
    required double width,
    required String title,
    required List<Widget> children,
    bool highlighted = false,
  }) =>
      Container(
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: highlighted ? RobinTheme.successLight : RobinTheme.surface,
          border: Border.all(
              color: highlighted ? RobinTheme.signalGreen : RobinTheme.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: RobinTheme.bodySm.copyWith(
                color: highlighted
                    ? RobinTheme.signalGreen
                    : RobinTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 9),
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      );

  Widget _field(String label, TextEditingController controller,
          {String? key, IconData? icon, int maxLines = 1}) =>
      TextField(
        key: key == null ? null : ValueKey(key),
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: icon == null ? null : Icon(icon, size: 17),
          border: const OutlineInputBorder(),
        ),
      );

  Widget _dropdown({
    String? key,
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
  }) =>
      DropdownButtonFormField<String>(
        key: key == null ? null : ValueKey(key),
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        items: values
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      );

  void _showMessage(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _selectReceipt() async {
    try {
      _showMessage('Windows 파일 선택창을 여는 중입니다.');
      final file = await DesktopFileService.pickDocument(
        extensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      );
      if (file == null || !mounted) return;
      setState(() {
        _receiptPath = file.path;
        _receiptFile.text = file.name;
      });
      _showMessage('인수증 파일을 선택했습니다: ${file.name}');
    } on Object catch (error) {
      if (mounted) _showMessage('인수증 파일 선택 실패: $error');
    }
  }

  Future<void> _previewReceipt() async {
    final path = _receiptPath;
    if (path == null) {
      _showMessage('미리볼 인수증 파일을 먼저 선택해주세요.');
      return;
    }
    try {
      await DesktopFileService.openWithDefaultApp(path);
    } on Object catch (error) {
      _showMessage('인수증을 열지 못했습니다: $error');
    }
  }

  Future<void> _downloadReceipt() async {
    final path = _receiptPath;
    if (path == null) {
      _showMessage('다운로드할 인수증 파일을 먼저 선택해주세요.');
      return;
    }
    final savedPath = await DesktopFileService.saveCopy(
      sourcePath: path,
      suggestedName: _receiptFile.text,
    );
    if (savedPath != null && mounted) {
      _showMessage('인수증 저장 완료: $savedPath');
    }
  }
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
    return RobinAlertDialog(
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(title, style: RobinTheme.headingSm),
              action,
            ],
          ),
          const SizedBox(height: 10),
          child,
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
  Widget build(BuildContext context) => RobinAlertDialog(
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
  Widget build(BuildContext context) => RobinAlertDialog(
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
  Widget build(BuildContext context) => RobinAlertDialog(
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
        child: RobinAlertDialog(
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
  Widget build(BuildContext context) => RobinAlertDialog(
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
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              horizontalMargin: 10,
              columnSpacing: 16,
              headingRowHeight: 38,
              dataRowMinHeight: 38,
              dataRowMaxHeight: 48,
              columns: headers
                  .map((header) =>
                      DataColumn(label: Text(header, softWrap: true)))
                  .toList(),
              rows: rows
                  .map((row) => DataRow(
                        cells: row
                            .map((value) =>
                                DataCell(Text(value, softWrap: true)))
                            .toList(),
                      ))
                  .toList(),
            ),
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: _storyCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stage,
                style:
                    RobinTheme.headingSm.copyWith(color: RobinTheme.primary)),
            const SizedBox(height: 4),
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
            const SizedBox(height: 3),
            Text(note, softWrap: true, style: RobinTheme.labelXs),
          ],
        ),
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

List<_ProjectRow> _buildAdditionalProjectRows() {
  const projectNames = [
    '스마트팩토리 증설',
    '물류 자동화 시스템',
    '클린룸 핸들링',
    '공정 자동화 라인',
    '웨이퍼 이송 모듈',
    '조립 자동화 셀',
    '패키징 자동화',
    '공정 물류 개선',
    '자동창고 연계',
    'AGV 자동화라인',
  ];
  const orderNames = [
    '로봇 본체',
    '이송 모듈',
    '그리퍼 어셈블리',
    '안전·제어 패키지',
  ];
  const customers = [
    '삼성전자',
    'LG전자',
    '현대자동차',
    'SK하이닉스',
    '포스코',
    '한화비전',
    '현대모비스',
    '삼성전기',
    'LG디스플레이',
    '한미반도체',
  ];
  const projectManagers = [
    '최PM 책임',
    '송PM 책임',
    '이PM 책임',
    '정PM 책임',
    '윤PM 책임',
    '박PM 책임'
  ];
  const models = ['RS-N120', 'AMR-500', 'GRP-VAC-40', 'RCX-500', 'VI-220'];
  const channels = ['본사 직판', '서울 대리점', '경기 대리점', '부산 대리점'];
  const progressByStage = [18, 35, 55, 72, 88, 98];

  return List.generate(27, (offset) {
    final projectIndex = offset + 4;
    final stageIndex = offset % _projectStages.length;
    final dueDay = ((projectIndex * 3) % 30) + 1;
    final urgent = projectIndex % 7 == 0;
    final changedDay = (dueDay + 4).clamp(1, 30);
    final projectNumber = 'PJ-2608-${projectIndex.toString().padLeft(3, '0')}';
    return _ProjectRow(
      number: 'SO-2608-${(100 + projectIndex).toString().padLeft(3, '0')}',
      projectNumber: projectNumber,
      projectName:
          '${customers[offset % customers.length]} ${projectNames[offset % projectNames.length]}',
      orderName: orderNames[offset % orderNames.length],
      customer: customers[offset % customers.length],
      pm: projectManagers[offset % projectManagers.length],
      model: models[offset % models.length],
      stage: _projectStages[stageIndex],
      leadTime: '${(10 + (projectIndex * 1.3) % 22).toStringAsFixed(1)}일',
      progress: (progressByStage[stageIndex] + offset % 4).clamp(0, 100),
      dueDate: '2026-09-${dueDay.toString().padLeft(2, '0')}',
      changedDueDate:
          urgent ? '2026-09-${changedDay.toString().padLeft(2, '0')}' : '-',
      urgent: urgent,
      memo: '${_projectStages[stageIndex]} 단계 진행사항 확인',
      channel: channels[offset % channels.length],
      closeStatus: stageIndex == _projectStages.length - 1 ? '마감대기' : '진행중',
    );
  });
}

class _ProjectRow {
  final String number;
  final String projectNumber;
  final String projectName;
  final String orderName;
  final String customer;
  final String pm;
  final String model;
  final String stage;
  final String leadTime;
  final int progress;
  final String dueDate;
  final String changedDueDate;
  final bool urgent;
  final String memo;
  final String channel;
  final String closeStatus;

  const _ProjectRow({
    required this.number,
    required this.projectNumber,
    required this.projectName,
    required this.orderName,
    required this.customer,
    required this.pm,
    required this.model,
    required this.stage,
    required this.leadTime,
    required this.progress,
    required this.dueDate,
    required this.changedDueDate,
    required this.urgent,
    required this.memo,
    required this.channel,
    required this.closeStatus,
  });
}

class _ProjectSummary {
  final String projectNumber;
  final String projectName;
  final String leadTime;
  final String customer;
  final String pm;
  final String stage;
  final int progress;
  final String dueDate;
  final String changedDueDate;
  final bool urgent;

  const _ProjectSummary({
    required this.projectNumber,
    required this.projectName,
    required this.leadTime,
    required this.customer,
    required this.pm,
    required this.stage,
    required this.progress,
    required this.dueDate,
    required this.changedDueDate,
    required this.urgent,
  });
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
