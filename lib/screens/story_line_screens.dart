import 'package:flutter/material.dart';

import '../theme/robin_theme.dart';
import '../widgets/app_bar.dart';

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

  static const _projects = [
    _ProjectRow('SO-2608-014', 'A사 자동화라인 증설', '구매', '2026-09-20', '2026-09-27',
        true, 'BOM 장기재고 2건 확인 필요'),
    _ProjectRow('SO-2608-011', 'B사 물류 로봇 시스템', '생산', '2026-09-05', '-', false,
        'Work Center 생산예정일 입력 대기'),
    _ProjectRow('SO-2608-009', 'C사 협동로봇 공급', '품질', '2026-08-28', '2026-08-30',
        true, 'OQC 검사 예정'),
    _ProjectRow('SO-2608-006', 'D사 검사 자동화 설비', '물류', '2026-08-24', '-', false,
        '납품처 확인 완료 · 배차 대기'),
    _ProjectRow('SO-2608-002', 'E사 제어시스템', '마감', '2026-08-18', '-', false,
        'ERP 거래명세서 발생 대기'),
  ];

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
                Text('수주부터 마감까지 진행현황과 단계별 입력 업무를 관리합니다.',
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
                              DataColumn(label: Text('수주')),
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
                                      child: Text(row.projectName,
                                          softWrap: true))),
                                  for (var index = 0;
                                      index < _projectStages.length;
                                      index++)
                                    DataCell(_progressDot(index, stageIndex)),
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
                                icon: const Icon(Icons.note_add_outlined,
                                    size: 17),
                                label: const Text('메모/산출물')),
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
                            _PurchasePanel(project: _selected),
                            _ProductionPanel(project: _selected),
                            _QualityPanel(project: _selected),
                            _LogisticsPanel(project: _selected),
                            _ClosingPanel(project: _selected),
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

  Future<void> _showMemoDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('프로젝트 메모 및 산출물'),
        content: const SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                      labelText: '프로젝트 메모', border: OutlineInputBorder())),
              SizedBox(height: 12),
              ListTile(
                  leading: Icon(Icons.upload_file_outlined),
                  title: Text('도면·제안서·검사성적서 업로드'),
                  subtitle: Text('PDF, XLSX, DWG 등 프로젝트 산출물')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('저장')),
        ],
      ),
    );
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

class _PurchasePanel extends StatelessWidget {
  final _ProjectRow project;
  const _PurchasePanel({required this.project});

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
                onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _PurchaseInputDialog(project: project)),
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
  const _ProductionPanel({required this.project});

  @override
  Widget build(BuildContext context) => _panel(
        title: 'Work Center 생산 진행현황',
        action: FilledButton.icon(
            onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => _ProductionInputDialog(project: project)),
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
  const _QualityPanel({required this.project});

  @override
  Widget build(BuildContext context) => _panel(
        title: 'IQC · LQC · OQC 단계별 검사 입력',
        action: FilledButton.icon(
            onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => _QualityInputDialog(project: project)),
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
  const _LogisticsPanel({required this.project});

  @override
  Widget build(BuildContext context) => _panel(
        title: '납품 정보 및 배차·상차 진행현황',
        action: FilledButton.icon(
            onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => _LogisticsInputDialog(project: project)),
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
  const _ClosingPanel({required this.project});

  @override
  Widget build(BuildContext context) => _panel(
        title: 'ERP 거래명세서 기준 마감 현황',
        action: OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('마감 이력 Excel을 생성했습니다.'))),
            icon: const Icon(Icons.download_outlined, size: 16),
            label: const Text('마감 이력 Excel')),
        child: const _CompactTable(
          headers: ['거래명세서', 'ERP 출하일', '매출 마감', '최종 담당자', '완료일', '상태'],
          rows: [
            ['ERP-TS-260814', '2026-08-28', '발생', '김로빈 책임', '2026-08-29', '완료'],
            ['ERP-TS-260815', '-', '미발생', '박로빈 사원', '-', '대기'],
          ],
        ),
      );
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
          const counts = [18, 15, 12, 9, 7, 5, 3];
          final columns = constraints.maxWidth >= 1050 ? 7 : 4;
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

const _projectStages = ['수주', '설계', '구매', '생산', '품질', '물류', '마감'];

Widget _progressDot(int index, int current) {
  final done = index < current;
  final active = index == current;
  return Container(
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

  const _ProjectRow(this.number, this.projectName, this.stage, this.dueDate,
      this.changedDueDate, this.urgent, this.memo);
}
