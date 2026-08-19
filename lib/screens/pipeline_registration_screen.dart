import 'package:flutter/material.dart';

import '../theme/robin_theme.dart';
import '../widgets/user_profile.dart';

class PipelineRegistrationView extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const PipelineRegistrationView({super.key, this.onNavigate});

  @override
  State<PipelineRegistrationView> createState() =>
      _PipelineRegistrationViewState();
}

class _PipelineRegistrationViewState extends State<PipelineRegistrationView> {
  static const _stageNames = [
    'Assess',
    'Proposal',
    'Negotiation',
    'Closed Won',
    'Closed Lost',
    '수주 중단',
  ];
  static const _stageDescriptions = [
    '물동 · 최종 합의',
    '견적 · 컨셉 설계',
    '상세 Spec. · 가격',
    '수주 성공',
    '수주 실패',
    'ERP 중단 연계',
  ];
  static const _stageColors = [
    Color(0xFF2E7D32),
    Color(0xFF2563EB),
    Color(0xFFF57C00),
    Color(0xFF64748B),
    Color(0xFFC62828),
    Color(0xFF7C3AED),
  ];

  final _searchController = TextEditingController();
  final _historyController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _strokeController = TextEditingController(text: '1000');
  final _orderPriceController = TextEditingController(text: '15,000,000');
  final _assessTableController = ScrollController();

  final List<_PipelineLead> _leads = [
    const _PipelineLead(
      number: 'RB-2608-021',
      project: 'LGD 베트남 EGL 3D wafer 세정기',
      customer: '엘지디스플레이',
      dealer: '본사 직판',
      owner: '김로빈 책임',
      stage: 0,
      amount: 152400,
      materialCost: 98123,
      quantity: 12,
      orderMonth: '2026-10',
      arrivalMonth: '2026-11',
      productType: '기구부',
      destination: 'LG향',
      endUser: '엘지디스플레이',
      orderChanges: 1,
      specChanges: 2,
    ),
    const _PipelineLead(
      number: 'RB-2608-018',
      project: 'LGES 각형 CELL PKG 용접설비',
      customer: 'LG에너지솔루션',
      dealer: '시스템알앤디',
      owner: '박로빈 사원',
      stage: 0,
      amount: 182340,
      materialCost: 135387,
      quantity: 86,
      orderMonth: '2026-10',
      arrivalMonth: '2026-11',
      productType: '기구부',
      destination: 'LG향',
      endUser: 'LG에너지솔루션',
      orderChanges: 0,
      specChanges: 1,
    ),
    const _PipelineLead(
      number: 'RB-2608-014',
      project: '자동차 AGV 공급 프로젝트',
      customer: '현대자동차',
      dealer: '본사 직판',
      owner: '이연근 차장',
      stage: 1,
      amount: 150000,
      materialCost: 108000,
      quantity: 14,
      orderMonth: '2026-09',
      arrivalMonth: '2026-10',
      productType: 'AGV',
      destination: '자동차',
      endUser: '현대자동차',
      orderChanges: 2,
      specChanges: 4,
    ),
    const _PipelineLead(
      number: 'RB-2608-011',
      project: '애플向 단동기 9라인',
      customer: 'LG전자',
      dealer: '영신에프에이',
      owner: '금동연 책임',
      stage: 1,
      amount: 170000,
      materialCost: 126225,
      quantity: 9,
      orderMonth: '2026-12',
      arrivalMonth: '2026-12',
      productType: '리니어',
      destination: 'LG향',
      endUser: 'LG전자',
      orderChanges: 1,
      specChanges: 3,
    ),
    const _PipelineLead(
      number: 'RB-2608-009',
      project: '직교로봇 적재 시스템',
      customer: 'A사',
      dealer: '서울 대리점',
      owner: '박로빈 사원',
      stage: 2,
      amount: 98000,
      materialCost: 82100,
      quantity: 3,
      orderMonth: '2026-08',
      arrivalMonth: '2026-09',
      productType: '직교로봇',
      destination: '기타',
      endUser: 'A사',
      orderChanges: 3,
      specChanges: 5,
    ),
    const _PipelineLead(
      number: 'SO-2608-004',
      project: '협동로봇 제어 시스템',
      customer: 'B사',
      dealer: '본사 직판',
      owner: '김로빈 책임',
      stage: 3,
      amount: 72000,
      materialCost: 51800,
      quantity: 4,
      orderMonth: '2026-08',
      arrivalMonth: '2026-09',
      productType: '협동로봇',
      destination: '기타',
      endUser: 'B사',
      orderChanges: 1,
      specChanges: 1,
      erpLinked: true,
    ),
    const _PipelineLead(
      number: 'RB-2607-031',
      project: 'P-THLI Green Power SPARE PART',
      customer: 'LG에너지솔루션',
      dealer: '지역대리점',
      owner: '금동연 책임',
      stage: 4,
      amount: 28900,
      materialCost: 17918,
      quantity: 1,
      orderMonth: '2026-08',
      arrivalMonth: '2026-08',
      productType: '기구부',
      destination: 'LG향',
      endUser: 'LG에너지솔루션',
      orderChanges: 1,
      specChanges: 0,
      dropReason: '고객 투자 취소',
    ),
  ];

  final List<_PipelineHistory> _histories = [
    const _PipelineHistory(
      number: 'RB-2608-014',
      at: '2026-08-18 14:20',
      user: '이연근 차장',
      from: 'Assess',
      to: 'Proposal',
      note: '고객 요구 Spec. 접수 및 설계담당자 지정',
    ),
    const _PipelineHistory(
      number: 'RB-2608-009',
      at: '2026-08-18 10:05',
      user: '박로빈 사원',
      from: 'Proposal',
      to: 'Negotiation',
      note: '컨셉도면 Rev.03 확정, 상세 견적 요청',
    ),
  ];

  int _activeStage = 0;
  _PipelineLead? _selected;
  String _ratioFilter = '전체 재료비율';
  String _channelFilter = '전체 채널';
  String _productGroup = 'linear';
  int _modelIndex = 0;
  int _payloadCost = 0;
  int _axisCost = 0;
  bool _evidenceAttached = false;
  final Set<String> _selectedOptions = {};

  static const _models = {
    'linear': [
      _CostModel('LM-1200 표준형', 6900000, 1000),
      _CostModel('LM-1600 고하중형', 8400000, 1200),
      _CostModel('LM-2000 장축형', 10200000, 1500),
    ],
    'cartesian': [
      _CostModel('RC-1000 단축형', 7600000, 1000),
      _CostModel('RC-1500 2축 대응형', 9800000, 1200),
      _CostModel('RC-2000 고하중형', 12100000, 1500),
    ],
  };

  static const _optionCosts = {
    'B/S 고정-고정 방식': 420000,
    '파워락 적용': 280000,
    '병렬형 풀리 적용': 620000,
    '흑색처리': 310000,
    '레이던트 처리': 390000,
    '상면급유': 470000,
    '무급유 사양': 620000,
    '주유 배관처리': 360000,
    '매니폴드 적용': 290000,
    '바디 하네스 적용': 510000,
    '조합 출하': 750000,
  };

  @override
  void dispose() {
    _searchController.dispose();
    _historyController.dispose();
    _quantityController.dispose();
    _strokeController.dispose();
    _orderPriceController.dispose();
    _assessTableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIntro(),
        const SizedBox(height: 14),
        _buildStageStrip(),
        const SizedBox(height: 12),
        _buildFilters(),
        const SizedBox(height: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final workspace = Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildWorkspaceTabs(),
                    const Divider(height: 1),
                    Expanded(child: _buildActiveWorkspace()),
                  ],
                ),
              );
              if (constraints.maxWidth < 1250) return workspace;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: workspace),
                  const SizedBox(width: 12),
                  SizedBox(width: 340, child: _buildHistoryPanel()),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIntro() => LayoutBuilder(
        builder: (context, constraints) {
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('파이프라인 등록', style: RobinTheme.headingLg),
              const SizedBox(height: 4),
              Text(
                '물동 → 컨셉설계 → 상세 Spec.·가격·결재를 하나의 수주 이력으로 관리합니다.',
                style: RobinTheme.bodySm,
              ),
            ],
          );
          final actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _activeStage = 0),
                icon: const Icon(Icons.edit_note_outlined, size: 18),
                label: const Text('단계별 입력'),
              ),
              OutlinedButton.icon(
                onPressed: _receiveErpStop,
                icon: const Icon(Icons.sync_problem_outlined, size: 18),
                label: const Text('ERP 수주중단 수신'),
              ),
              FilledButton.icon(
                onPressed: _registerPipeline,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('신규 파이프라인'),
              ),
            ],
          );
          if (constraints.maxWidth < 1050) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 10), actions],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: title),
              const SizedBox(width: 12),
              actions,
            ],
          );
        },
      );

  Widget _buildStageStrip() => SizedBox(
        height: 158,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _stageNames.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final rows = _leads.where((lead) => lead.stage == index).toList();
            final amount =
                rows.fold<double>(0, (sum, lead) => sum + lead.amount);
            final orders =
                rows.fold<int>(0, (sum, lead) => sum + lead.orderChanges);
            final specs =
                rows.fold<int>(0, (sum, lead) => sum + lead.specChanges);
            final active = _activeStage == index;
            return InkWell(
              key: ValueKey('pipeline-stage-$index'),
              onTap: () => setState(() => _activeStage = index),
              borderRadius: BorderRadius.circular(9),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 196,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: active
                      ? _stageColors[index].withValues(alpha: .07)
                      : RobinTheme.surface,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: active ? _stageColors[index] : RobinTheme.border,
                    width: active ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          index < 3
                              ? Icons.check_circle_outline
                              : Icons.flag_outlined,
                          size: 17,
                          color: _stageColors[index],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(_stageNames[index],
                              style: RobinTheme.headingSm
                                  .copyWith(color: _stageColors[index])),
                        ),
                        Text('${rows.length}건', style: RobinTheme.headingSm),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_stageDescriptions[index],
                        maxLines: 2, style: RobinTheme.labelXs),
                    const Spacer(),
                    Text(
                      '${_compactMoney(amount)} · 주문 $orders · 사양 $specs',
                      style: RobinTheme.labelXs
                          .copyWith(color: RobinTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

  Widget _buildFilters() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: _cardDecoration(),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'ERP 고객사·대리점·PJT명 검색',
                  prefixIcon: Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _channelFilter,
                decoration: const InputDecoration(
                    labelText: '채널',
                    border: OutlineInputBorder(),
                    isDense: true),
                items: const ['전체 채널', '직판', '대리점']
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _channelFilter = value ?? '전체 채널'),
              ),
            ),
            SizedBox(
              width: 170,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _ratioFilter,
                decoration: const InputDecoration(
                    labelText: '재료비율 %',
                    border: OutlineInputBorder(),
                    isDense: true),
                items: const [
                  '전체 재료비율',
                  '75% 미만',
                  '75~80%',
                  '80% 초과',
                ]
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _ratioFilter = value ?? '전체 재료비율'),
              ),
            ),
            const Chip(
              avatar: Icon(Icons.cloud_done_outlined, size: 16),
              label: Text('ERP 기초데이터 연계'),
            ),
            OutlinedButton.icon(
              onPressed: _showHistoryPanelDialog,
              icon: const Icon(Icons.history, size: 17),
              label: const Text('단계 변경 이력'),
            ),
            Text('조회 ${_filteredForStage.length}건', style: RobinTheme.bodySm),
          ],
        ),
      );

  Widget _buildWorkspaceTabs() => SizedBox(
        height: 52,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            for (var index = 0; index < _stageNames.length; index++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
                child: TextButton(
                  onPressed: () => setState(() => _activeStage = index),
                  style: TextButton.styleFrom(
                    foregroundColor: _activeStage == index
                        ? _stageColors[index]
                        : RobinTheme.textSecondary,
                    backgroundColor: _activeStage == index
                        ? _stageColors[index].withValues(alpha: .08)
                        : Colors.transparent,
                  ),
                  child: Text(index == 0
                      ? 'Assess · 물동'
                      : index == 1
                          ? 'Proposal · 컨셉설계'
                          : index == 2
                              ? 'Negotiation · 원가/결재'
                              : _stageNames[index]),
                ),
              ),
          ],
        ),
      );

  Widget _buildActiveWorkspace() => switch (_activeStage) {
        0 => _buildAssessWorkspace(),
        1 => _buildProposalWorkspace(),
        2 => _buildNegotiationWorkspace(),
        _ => _buildTerminalWorkspace(),
      };

  Widget _buildAssessWorkspace() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '수주물동관리 양식의 47개 필드 중 파이프라인 판단 필수값을 표시합니다.',
                    style: RobinTheme.bodySm,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _message('수주물동관리 양식.xlsx의 컬럼 매핑을 확인했습니다.'),
                  icon: const Icon(Icons.upload_file_outlined, size: 17),
                  label: const Text('물동 Excel 불러오기'),
                ),
                const SizedBox(width: 7),
                FilledButton.icon(
                  onPressed: _registerPipeline,
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text('물동 행 추가'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => Scrollbar(
                controller: _assessTableController,
                thumbVisibility: true,
                interactive: true,
                scrollbarOrientation: ScrollbarOrientation.bottom,
                child: SingleChildScrollView(
                  controller: _assessTableController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DataTable(
                        showCheckboxColumn: false,
                        horizontalMargin: 8,
                        columnSpacing: 8,
                        headingTextStyle: RobinTheme.bodySm
                            .copyWith(fontWeight: FontWeight.w700),
                        dataTextStyle: RobinTheme.bodySm,
                        headingRowHeight: 52,
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 82,
                        columns: [
                          DataColumn(label: _pipelineTableText(52, '수주월')),
                          DataColumn(label: _pipelineTableText(52, '입고월')),
                          DataColumn(label: _pipelineTableText(78, '가수주번호')),
                          DataColumn(label: _pipelineTableText(68, '담당자')),
                          DataColumn(label: _pipelineTableText(38, '제품류')),
                          DataColumn(label: _pipelineTableText(38, '향지')),
                          DataColumn(label: _pipelineTableText(70, '채널/거래처')),
                          DataColumn(label: _pipelineTableText(75, 'End User')),
                          DataColumn(label: _pipelineTableText(105, 'PJT명')),
                          DataColumn(label: _pipelineTableText(28, '수량')),
                          DataColumn(label: _pipelineTableText(60, '판가(만원)')),
                          DataColumn(label: _pipelineTableText(65, '매출액(만원)')),
                          DataColumn(label: _pipelineTableText(55, '재료비율')),
                          DataColumn(
                              label: _pipelineTableText(55, 'BEST/WORST')),
                        ],
                        rows: _filteredForStage.map((lead) {
                          final selected = _selected?.number == lead.number;
                          return DataRow(
                            selected: selected,
                            onSelectChanged: (_) =>
                                setState(() => _selected = lead),
                            cells: [
                              DataCell(_pipelineTableText(52, lead.orderMonth)),
                              DataCell(
                                  _pipelineTableText(52, lead.arrivalMonth)),
                              DataCell(_pipelineTableText(
                                78,
                                lead.number,
                                style: const TextStyle(
                                  color: RobinTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              )),
                              DataCell(_pipelineTableText(68, lead.owner)),
                              DataCell(
                                  _pipelineTableText(38, lead.productType)),
                              DataCell(
                                  _pipelineTableText(38, lead.destination)),
                              DataCell(_pipelineTableText(70, lead.dealer)),
                              DataCell(_pipelineTableText(75, lead.endUser)),
                              DataCell(_pipelineTableText(105, lead.project)),
                              DataCell(
                                  _pipelineTableText(28, '${lead.quantity}')),
                              DataCell(_pipelineTableText(
                                  60, _money(lead.amount / lead.quantity))),
                              DataCell(
                                  _pipelineTableText(65, _money(lead.amount))),
                              DataCell(SizedBox(
                                  width: 55,
                                  child: _ratioBadge(lead.materialRatio))),
                              DataCell(_pipelineTableText(
                                  55,
                                  lead.materialRatio > 80
                                      ? 'WORST'
                                      : lead.materialRatio >= 75
                                          ? 'B-'
                                          : 'BEST')),
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
        ],
      );

  Widget _buildProposalWorkspace() {
    final rows = _filteredForStage;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Proposal 버튼을 선택하면 고객요구사항·설계담당자·도면·협의이력이 나래비로 펼쳐집니다.',
                style: RobinTheme.bodySm,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _message('SmartOrder 고객 기초정보를 불러왔습니다.'),
              icon: const Icon(Icons.sync, size: 17),
              label: const Text('SmartOrder 연계'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final lead in rows)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              key: ValueKey('proposal-${lead.number}'),
              initiallyExpanded: _selected?.number == lead.number,
              onExpansionChanged: (expanded) {
                if (expanded) setState(() => _selected = lead);
              },
              leading: CircleAvatar(
                backgroundColor: _stageColors[1].withValues(alpha: .1),
                child: const Icon(Icons.architecture_outlined,
                    color: Color(0xFF2563EB), size: 19),
              ),
              title: Text('${lead.number}  ${lead.project}',
                  style: RobinTheme.headingSm),
              subtitle: Text(
                  '${lead.customer} · ${lead.owner} · 사양변경 ${lead.specChanges}건'),
              trailing: const Chip(label: Text('Proposal')),
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      const Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _InfoBox('예상 물동', '3,500 ea/월'),
                          _InfoBox('작업/운영시간', '16 / 20 hr/일'),
                          _InfoBox('제품 크기', '1,200 × 800 × 900 mm'),
                          _InfoBox('이송 Capa', '350.0 kg/회'),
                          _InfoBox('예상 투자금액', '15.0억원'),
                          _InfoBox('설계담당자', '이설계 책임'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const _DocumentRow(Icons.table_view_outlined,
                          '고객 Spec. Sheet', '물동관리_현대자동차_AGV.xlsx', '접수 완료'),
                      const _DocumentRow(Icons.picture_as_pdf_outlined, '컨셉 도면',
                          'Layout_AGV_Concept_Rev03.pdf', 'PDM Rev.03'),
                      const _DocumentRow(Icons.forum_outlined, '협의 댓글',
                          '대리점 2건 · 설계팀 3건', '최종 합의'),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                              onPressed: () => _message('설계담당자 지정창을 열었습니다.'),
                              child: const Text('설계담당자 지정')),
                          const SizedBox(width: 7),
                          OutlinedButton(
                              onPressed: () => _message('도면/제안서 업로드를 준비했습니다.'),
                              child: const Text('도면 업로드')),
                          const SizedBox(width: 7),
                          FilledButton.icon(
                            onPressed: () => _changeStage(lead, 2),
                            icon: const Icon(Icons.arrow_forward, size: 17),
                            label: const Text('Negotiation으로'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNegotiationWorkspace() {
    final negotiationRows = _filteredForStage;
    final selectedLead = negotiationRows.contains(_selected)
        ? _selected
        : (negotiationRows.isEmpty ? null : negotiationRows.first);
    final calc = _calculateCost();
    final dealerView = (selectedLead?.dealer ?? '').contains('대리점') ||
        ((selectedLead?.dealer ?? '').isNotEmpty &&
            !(selectedLead?.dealer ?? '').contains('본사'));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<_PipelineLead>(
                  isExpanded: true,
                  initialValue: selectedLead,
                  decoration: const InputDecoration(
                    labelText: 'Negotiation 수주 선택',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: negotiationRows
                      .map((lead) => DropdownMenuItem(
                          value: lead,
                          child: Text('${lead.number} · ${lead.project}')))
                      .toList(),
                  onChanged: (lead) => setState(() => _selected = lead),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _message('Proposal 컨셉도면 Rev.03의 스펙을 불러왔습니다.'),
                icon: const Icon(Icons.file_download_outlined, size: 17),
                label: const Text('Proposal Spec. 불러오기'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _showPriceTableAdmin,
                icon: const Icon(Icons.price_change_outlined, size: 17),
                label: const Text('단가 테이블 관리'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildCostInputs()),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _buildCostResult(calc, dealerView)),
            ],
          ),
          const SizedBox(height: 12),
          _buildApprovalArea(calc, dealerView),
        ],
      ),
    );
  }

  Widget _buildCostInputs() => Container(
        padding: const EdgeInsets.all(12),
        decoration: _softPanel(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('특주 제품 사양', style: RobinTheme.headingSm),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _productGroup,
                    decoration: const InputDecoration(
                        labelText: '제품군',
                        border: OutlineInputBorder(),
                        isDense: true),
                    items: const [
                      DropdownMenuItem(value: 'linear', child: Text('리니어')),
                      DropdownMenuItem(value: 'cartesian', child: Text('직교로봇')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _productGroup = value;
                        _modelIndex = 0;
                        _strokeController.text =
                            '${_models[value]!.first.stroke}';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: _modelIndex,
                    decoration: const InputDecoration(
                        labelText: '기준 모델',
                        border: OutlineInputBorder(),
                        isDense: true),
                    items: [
                      for (var index = 0;
                          index < _models[_productGroup]!.length;
                          index++)
                        DropdownMenuItem(
                            value: index,
                            child: Text(_models[_productGroup]![index].name)),
                    ],
                    onChanged: (value) => setState(() {
                      _modelIndex = value ?? 0;
                      _strokeController.text =
                          '${_models[_productGroup]![_modelIndex].stroke}';
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child:
                        _numberField('수량', _quantityController, suffix: 'EA')),
                const SizedBox(width: 8),
                Expanded(
                    child: _numberField('X축 스트로크', _strokeController,
                        suffix: 'mm')),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: _payloadCost,
                    decoration: const InputDecoration(
                        labelText: '가반하중',
                        border: OutlineInputBorder(),
                        isDense: true),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('기본 사양')),
                      DropdownMenuItem(value: 350000, child: Text('상위 +35만')),
                      DropdownMenuItem(value: 700000, child: Text('고하중 +70만')),
                    ],
                    onChanged: (value) =>
                        setState(() => _payloadCost = value ?? 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: _axisCost,
                    decoration: const InputDecoration(
                        labelText: '조합 형태',
                        border: OutlineInputBorder(),
                        isDense: true),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('단축')),
                      DropdownMenuItem(value: 900000, child: Text('2축 +90만')),
                      DropdownMenuItem(value: 1800000, child: Text('3축 +180만')),
                    ],
                    onChanged: (value) =>
                        setState(() => _axisCost = value ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('상세 옵션', style: RobinTheme.headingSm),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 0,
              children: _optionCosts.entries
                  .map((entry) => FilterChip(
                        selected: _selectedOptions.contains(entry.key),
                        label: Text(
                            '${entry.key} (+${_money(entry.value / 10000)}만)'),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            _selectedOptions.add(entry.key);
                          } else {
                            _selectedOptions.remove(entry.key);
                          }
                        }),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome_outlined,
                      size: 17, color: Color(0xFF2563EB)),
                  SizedBox(width: 7),
                  Expanded(
                      child: Text(
                          '가공품 예상단가: 과거 유사 실적 3건 평균 ±3.2% · 기성품: 표준단가+홀 수·길이 옵션')),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _numberField(String label, TextEditingController controller,
          {required String suffix}) =>
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      );

  Widget _buildCostResult(_CostResult calc, bool dealerView) => Container(
        padding: const EdgeInsets.all(12),
        decoration: _softPanel(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('예상 재료비 검증', style: RobinTheme.headingSm),
                Chip(label: Text(dealerView ? '대리점 판가 노출' : '사내 원가 노출')),
              ],
            ),
            const SizedBox(height: 8),
            if (dealerView)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: RobinTheme.background,
                    borderRadius: BorderRadius.circular(7)),
                child: const Row(
                  children: [
                    Icon(Icons.visibility_off_outlined, size: 18),
                    SizedBox(width: 7),
                    Expanded(
                        child: Text('대리점에는 재료비 수치를 공개하지 않고 최소 판가만 표시합니다.')),
                  ],
                ),
              )
            else ...[
              _resultLine('기본 제품가', calc.baseCost),
              _resultLine('사양 추가비', calc.specCost),
              _resultLine('특주 옵션비', calc.optionCost),
              const Divider(),
              _resultLine('예상 재료비', calc.estimated, emphasis: true),
            ],
            const SizedBox(height: 9),
            TextField(
              controller: _orderPriceController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final number = _digits(value);
                final formatted = number == 0 ? '' : _money(number.toDouble());
                if (formatted != value) {
                  _orderPriceController.value = TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                }
                setState(() {});
              },
              decoration: const InputDecoration(
                labelText: '수주 제안가/대리점 입력단가',
                suffixText: '원',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('예상 재료비율', style: RobinTheme.bodySm),
                const Spacer(),
                Text('${calc.ratio.toStringAsFixed(1)}%',
                    style: RobinTheme.numericMd.copyWith(color: calc.color)),
              ],
            ),
            const SizedBox(height: 5),
            LinearProgressIndicator(
              value: (calc.ratio / 100).clamp(0, 1),
              minHeight: 8,
              color: calc.color,
              backgroundColor: RobinTheme.border,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text(calc.message,
                style: RobinTheme.bodySm.copyWith(color: calc.color)),
            if (calc.ratio > 80)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text('최소 제안가 ${_money(calc.minimumPrice)}원',
                    style: RobinTheme.headingSm),
              ),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: RobinTheme.warningLight,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Row(
                children: [
                  Icon(Icons.qr_code_2_outlined,
                      size: 18, color: RobinTheme.warning),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                        'ERP 제품코드 중복 검증: 모델명이 같고 Spec.이 다르면 별도 사양코드(-S01)로 생성합니다.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _resultLine(String label, double value, {bool emphasis = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(child: Text(label, style: RobinTheme.bodySm)),
            Text('${_money(value)}원',
                style: emphasis ? RobinTheme.headingSm : RobinTheme.bodyMd),
          ],
        ),
      );

  Widget _buildApprovalArea(_CostResult calc, bool dealerView) {
    final needsDivisionApproval = calc.ratio > 80;
    final isWarning = calc.ratio >= 75;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isWarning ? calc.color : RobinTheme.signalGreen)
            .withValues(alpha: .06),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
            color: (isWarning ? calc.color : RobinTheme.signalGreen)
                .withValues(alpha: .35)),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.approval_outlined, color: calc.color),
              Text('ROBIN 결재시스템', style: RobinTheme.headingSm),
              _evidenceBadge(_evidenceAttached),
              OutlinedButton.icon(
                onPressed: () => setState(() => _evidenceAttached = true),
                icon: const Icon(Icons.attach_file, size: 17),
                label: Text(dealerView ? '인보이스 발행 요청' : '발주서/증빙 첨부'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _approvalStep(
                    '기안자', dealerView ? '대리점/영업담당자' : '직판영업담당자', true),
                const _ApprovalArrow(),
                _approvalStep('영업팀장', isWarning ? '승인 필요' : '참조', !isWarning),
                if (needsDivisionApproval) ...[
                  const _ApprovalArrow(),
                  _approvalStep('사업부장', '80% 초과 자동생성', false),
                ],
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () {
                    if (_selected != null) {
                      _histories.insert(
                        0,
                        _PipelineHistory(
                          number: _selected!.number,
                          at: _now(),
                          user: robinUserProfile.value.name,
                          from: 'Negotiation',
                          to: '결재 상신',
                          note:
                              '재료비율 ${calc.ratio.toStringAsFixed(1)}% · ${_evidenceAttached ? '증빙 첨부' : '증빙 미첨부'}',
                        ),
                      );
                    }
                    setState(() {});
                    _message(needsDivisionApproval
                        ? '영업팀장 → 사업부장 결재를 상신했습니다.'
                        : '영업팀장 결재를 상신했습니다.');
                  },
                  icon: const Icon(Icons.send_outlined, size: 17),
                  label: const Text('결재 상신'),
                ),
              ],
            ),
          ),
          if ((_selected?.dealer ?? '').contains('대리점')) ...[
            const SizedBox(height: 9),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('대리점 최소 재료비율은 업체별 단가표로 검증하며, 대리점에는 판가만 노출됩니다.',
                  style: RobinTheme.labelXs),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTerminalWorkspace() {
    final rows = _filteredForStage;
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final lead = rows[index];
        return ListTile(
          selected: _selected?.number == lead.number,
          selectedTileColor: _stageColors[_activeStage].withValues(alpha: .06),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: RobinTheme.border)),
          onTap: () => setState(() => _selected = lead),
          leading: Icon(Icons.flag_circle_outlined,
              color: _stageColors[_activeStage]),
          title: Text('${lead.number}  ${lead.project}'),
          subtitle: Text(
              '${lead.customer} · ${_money(lead.amount)}만원${lead.dropReason == null ? '' : ' · ${lead.dropReason}'}'),
          trailing: OutlinedButton(
            onPressed: () => _showStageChangeDialog(lead),
            child: const Text('단계 변경'),
          ),
        );
      },
    );
  }

  Widget _buildHistoryPanel() {
    final selected = _selected;
    final rows = selected == null
        ? const <_PipelineHistory>[]
        : _histories.where((item) => item.number == selected.number).toList();
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                const Icon(Icons.history, size: 19, color: RobinTheme.primary),
                const SizedBox(width: 7),
                Text('단계 변경 이력', style: RobinTheme.headingSm),
                const Spacer(),
                if (selected != null)
                  IconButton(
                    tooltip: '단계 변경',
                    onPressed: () => _showStageChangeDialog(selected),
                    icon: const Icon(Icons.swap_horiz, size: 20),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (selected == null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.touch_app_outlined,
                          size: 38, color: RobinTheme.textMuted),
                      const SizedBox(height: 10),
                      Text('수주를 선택하면', style: RobinTheme.headingSm),
                      const SizedBox(height: 5),
                      const Text(
                        'Proposal 단계부터 변경시각·변경자·비고가 여기에 표시됩니다.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(selected.number,
                      style: RobinTheme.headingSm
                          .copyWith(color: RobinTheme.primary)),
                  const SizedBox(height: 3),
                  Text(selected.project,
                      softWrap: true, style: RobinTheme.bodySm),
                ],
              ),
            ),
            Expanded(
              child: rows.isEmpty
                  ? Center(
                      child:
                          Text('아직 저장된 변경 이력이 없습니다.', style: RobinTheme.bodySm))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: rows.length,
                      itemBuilder: (context, index) {
                        final history = rows[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          padding: const EdgeInsets.all(10),
                          decoration: _softPanel(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(history.at, style: RobinTheme.labelXs),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(child: Text(history.from)),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    child: Icon(Icons.arrow_forward, size: 13),
                                  ),
                                  Flexible(
                                      child: Text(history.to,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: RobinTheme.primary))),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(history.note, style: RobinTheme.bodySm),
                              const SizedBox(height: 5),
                              Text(history.user, style: RobinTheme.labelXs),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _historyController,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: '비고/특이사항 입력',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filled(
                    tooltip: '비고 저장',
                    onPressed: _addHistoryNote,
                    icon: const Icon(Icons.send, size: 17),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showHistoryPanelDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        contentPadding: const EdgeInsets.all(12),
        content: SizedBox(
          width: 380,
          height: MediaQuery.sizeOf(dialogContext).height * .72,
          child: _buildHistoryPanel(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  List<_PipelineLead> get _filteredForStage {
    final query = _searchController.text.trim().toLowerCase();
    return _leads.where((lead) {
      if (lead.stage != _activeStage) return false;
      if (query.isNotEmpty &&
          !'${lead.customer} ${lead.dealer} ${lead.project} ${lead.number}'
              .toLowerCase()
              .contains(query)) {
        return false;
      }
      if (_channelFilter == '직판' && !lead.dealer.contains('본사')) return false;
      if (_channelFilter == '대리점' && lead.dealer.contains('본사')) return false;
      final ratio = lead.materialRatio;
      if (_ratioFilter == '75% 미만' && ratio >= 75) return false;
      if (_ratioFilter == '75~80%' && (ratio < 75 || ratio > 80)) return false;
      if (_ratioFilter == '80% 초과' && ratio <= 80) return false;
      return true;
    }).toList();
  }

  _CostResult _calculateCost() {
    final model = _models[_productGroup]![_modelIndex];
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final stroke = int.tryParse(_strokeController.text) ?? model.stroke;
    final extraStroke = (stroke - model.stroke).clamp(0, 100000);
    final strokeCost = (extraStroke / 100).ceil() * 95000;
    final baseCost = model.cost * quantity.toDouble();
    final specCost =
        (strokeCost + _payloadCost + _axisCost) * quantity.toDouble();
    final optionCost = _selectedOptions.fold<int>(
            0, (sum, option) => sum + (_optionCosts[option] ?? 0)) *
        quantity.toDouble();
    final estimated = baseCost + specCost + optionCost;
    final orderPrice = _digits(_orderPriceController.text).toDouble();
    final ratio = orderPrice == 0 ? 0.0 : estimated / orderPrice * 100;
    final color = ratio > 80
        ? RobinTheme.signalRed
        : ratio >= 75
            ? RobinTheme.signalYellow
            : RobinTheme.signalGreen;
    final message = orderPrice == 0
        ? '수주 제안가를 입력해주세요.'
        : ratio > 80
            ? '80% 초과: 사업부장 추가 결재와 증빙이 필요합니다.'
            : ratio >= 75
                ? '75~80%: 기준 근접 · 영업팀장 결재 대상입니다.'
                : '제안가 입력이 가능한 기준 이내입니다.';
    final minimumPrice = (estimated / .8 / 10000).ceil() * 10000.0;
    return _CostResult(baseCost, specCost, optionCost, estimated, ratio,
        minimumPrice, color, message);
  }

  Future<void> _registerPipeline() async {
    final result = await showDialog<_PipelineLead>(
      context: context,
      builder: (context) => _PipelineRegistrationDialog(
          number: 'RB-2608-${(_leads.length + 22).toString().padLeft(3, '0')}'),
    );
    if (result == null || !mounted) return;
    setState(() {
      _leads.insert(0, result);
      _activeStage = 0;
      _selected = result;
    });
    _message('${result.number} 물동/Assess가 등록되었습니다.');
  }

  Future<void> _showStageChangeDialog(_PipelineLead lead) async {
    final stage = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('${lead.number} 단계 변경'),
        children: [
          for (var index = 0; index < _stageNames.length; index++)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, index),
              child: ListTile(
                leading: Icon(
                    index == lead.stage
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: _stageColors[index]),
                title: Text(_stageNames[index]),
                subtitle: index == 5 ? const Text('ERP 수주 중단과 동기화') : null,
              ),
            ),
        ],
      ),
    );
    if (stage != null && stage != lead.stage) await _changeStage(lead, stage);
  }

  Future<void> _changeStage(_PipelineLead lead, int nextStage,
      {bool fromErp = false}) async {
    String? dropNote;
    if (nextStage == 4 && !fromErp) {
      final drop = await showDialog<_DropInfo>(
        context: context,
        builder: (context) => _DropInfoDialog(lead: lead),
      );
      if (drop == null || !mounted) return;
      dropNote =
          'Drop 사유: ${drop.reason} · 경쟁사: ${drop.competitor} · 경쟁제품: ${drop.product}';
    }
    final noteController = TextEditingController();
    final note = dropNote ??
        await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('${lead.number} · ${_stageNames[nextStage]}'),
            content: SizedBox(
              width: 470,
              child: TextField(
                controller: noteController,
                autofocus: true,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '변경 사유/사양 수정사항',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소')),
              FilledButton(
                  onPressed: () => Navigator.pop(
                      context,
                      noteController.text.trim().isEmpty
                          ? '단계 이동 승인'
                          : noteController.text.trim()),
                  child: const Text('변경')),
            ],
          ),
        );
    noteController.dispose();
    if (note == null || !mounted) return;

    if (lead.stage == 3 && nextStage < 3) {
      final newLead = lead.copyWith(
        number: 'RB-2608-R${(_leads.length + 1).toString().padLeft(2, '0')}',
        stage: nextStage,
        erpLinked: false,
        orderChanges: lead.orderChanges + 1,
      );
      setState(() {
        _leads.insert(0, newLead);
        _selected = newLead;
        _activeStage = nextStage;
        _histories.insert(
          0,
          _PipelineHistory(
            number: newLead.number,
            at: _now(),
            user: robinUserProfile.value.name,
            from: '${lead.number} 정보 불러오기',
            to: _stageNames[nextStage],
            note: '수주 성공 후 이전단계 이동으로 신규 수주번호 자동부여 · $note',
          ),
        );
      });
      _message('${newLead.number}가 자동 부여되고 이전 수주 정보를 불러왔습니다.');
      return;
    }

    final updated = lead.copyWith(
      stage: fromErp ? 4 : nextStage,
      erpLinked: nextStage == 3,
      dropReason: fromErp
          ? 'ERP 수주 중단 자동 연동'
          : nextStage == 4
              ? dropNote
              : lead.dropReason,
    );
    setState(() {
      final index = _leads.indexOf(lead);
      _leads[index] = updated;
      _selected = updated;
      _activeStage = updated.stage;
      _histories.insert(
        0,
        _PipelineHistory(
          number: updated.number,
          at: _now(),
          user: fromErp ? 'ERP Interface' : robinUserProfile.value.name,
          from: _stageNames[lead.stage],
          to: fromErp ? 'Closed Lost' : _stageNames[nextStage],
          note: fromErp ? 'ERP 수주중단 수신 · ROBIN 수주실패 자동반영' : note,
        ),
      );
    });
    if (nextStage == 3) {
      final go = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Closed Won 처리 완료'),
          content: const Text('ERP 수주 연계가 완료되었습니다. 수주관리로 이동할까요?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('머무르기')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('수주관리로 이동')),
          ],
        ),
      );
      if (go == true) widget.onNavigate?.call(2);
    }
  }

  Future<void> _receiveErpStop() async {
    final candidates = _leads.where((lead) => lead.stage < 3).toList();
    final lead = await showDialog<_PipelineLead>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('ERP 수주 중단 수신 선택'),
        children: candidates
            .map((lead) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, lead),
                  child: Text('${lead.number} · ${lead.project}'),
                ))
            .toList(),
      ),
    );
    if (lead != null) await _changeStage(lead, 5, fromErp: true);
  }

  void _addHistoryNote() {
    final selected = _selected;
    final note = _historyController.text.trim();
    if (selected == null || note.isEmpty) return;
    setState(() {
      _histories.insert(
        0,
        _PipelineHistory(
          number: selected.number,
          at: _now(),
          user: robinUserProfile.value.name,
          from: _stageNames[selected.stage],
          to: '비고 추가',
          note: note,
        ),
      );
      _historyController.clear();
    });
  }

  Future<void> _showPriceTableAdmin() async {
    final isAdmin = robinUserProfile.value.isAdmin;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('단가 테이블 관리 · 구매팀장 권한'),
        content: SizedBox(
          width: 660,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isAdmin) const Text('현재 계정은 조회만 가능합니다.'),
              const SizedBox(height: 8),
              const _SimpleCostTable(),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('닫기')),
          if (isAdmin)
            FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('단가표 저장')),
        ],
      ),
    );
  }

  Widget _ratioBadge(double ratio) {
    final color = ratio > 80
        ? RobinTheme.signalRed
        : ratio >= 75
            ? RobinTheme.signalYellow
            : RobinTheme.signalGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(99)),
      child: Text('${ratio.toStringAsFixed(1)}%',
          style: RobinTheme.labelXs
              .copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }

  Widget _evidenceBadge(bool attached) {
    final color = attached ? RobinTheme.signalGreen : RobinTheme.signalRed;
    return Chip(
      avatar: Icon(attached ? Icons.check_circle : Icons.error_outline,
          color: color, size: 16),
      label: Text(attached ? '증빙 GREEN' : '증빙 RED'),
      side: BorderSide(color: color.withValues(alpha: .35)),
      backgroundColor: color.withValues(alpha: .06),
    );
  }

  Widget _approvalStep(String title, String subtitle, bool completed) =>
      Container(
        width: 205,
        padding: const EdgeInsets.all(9),
        decoration: _softPanel(),
        child: Row(
          children: [
            Icon(completed ? Icons.check_circle : Icons.schedule,
                size: 18,
                color: completed
                    ? RobinTheme.signalGreen
                    : RobinTheme.signalYellow),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: RobinTheme.headingSm),
                  Text(subtitle, softWrap: true, style: RobinTheme.labelXs),
                ],
              ),
            ),
          ],
        ),
      );

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static int _digits(String value) =>
      int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  static String _money(num value) {
    final text = value.round().toString();
    return text.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }

  static String _compactMoney(double value) => value >= 10000
      ? '${(value / 10000).toStringAsFixed(1)}억'
      : '${value.toStringAsFixed(0)}만';

  static String _now() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)} '
        '${two(now.hour)}:${two(now.minute)}';
  }
}

Widget _pipelineTableText(
  double width,
  String value, {
  TextStyle? style,
}) =>
    SizedBox(
      width: width,
      child: Text(
        value,
        softWrap: true,
        style: style,
      ),
    );

class _PipelineRegistrationDialog extends StatefulWidget {
  final String number;
  const _PipelineRegistrationDialog({required this.number});

  @override
  State<_PipelineRegistrationDialog> createState() =>
      _PipelineRegistrationDialogState();
}

class _PipelineRegistrationDialogState
    extends State<_PipelineRegistrationDialog> {
  final _key = GlobalKey<FormState>();
  final _project = TextEditingController();
  final _amount = TextEditingController();
  final _material = TextEditingController();
  String _customer = '현대자동차';
  String _dealer = '본사 직판';

  @override
  void dispose() {
    _project.dispose();
    _amount.dispose();
    _material.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('신규 파이프라인 · Assess'),
        content: SizedBox(
          width: 540,
          child: Form(
            key: _key,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  InputDecorator(
                    decoration: const InputDecoration(
                        labelText: '가수주번호', border: OutlineInputBorder()),
                    child: Text(widget.number),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _customer,
                    decoration: const InputDecoration(
                        labelText: '고객사 · ERP 등록 데이터',
                        border: OutlineInputBorder()),
                    items: const ['현대자동차', 'LG전자', 'LG에너지솔루션', '엘지디스플레이']
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) => _customer = value ?? _customer,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _dealer,
                    decoration: const InputDecoration(
                        labelText: '대리점/직판 · ERP 거래처',
                        border: OutlineInputBorder()),
                    items: const ['본사 직판', '서울 대리점', '영신에프에이']
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) => _dealer = value ?? _dealer,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _project,
                    decoration: const InputDecoration(
                        labelText: 'PJT명', border: OutlineInputBorder()),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'PJT명을 입력해주세요.'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: TextFormField(
                        controller: _amount,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: '예상 매출액(만원)',
                            border: OutlineInputBorder()),
                      )),
                      const SizedBox(width: 8),
                      Expanded(
                          child: TextFormField(
                        controller: _material,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: '예상 재료비(만원)',
                            border: OutlineInputBorder()),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () {
              if (!_key.currentState!.validate()) return;
              Navigator.pop(
                context,
                _PipelineLead(
                  number: widget.number,
                  project: _project.text.trim(),
                  customer: _customer,
                  dealer: _dealer,
                  owner: robinUserProfile.value.name,
                  stage: 0,
                  amount: double.tryParse(_amount.text) ?? 0,
                  materialCost: double.tryParse(_material.text) ?? 0,
                  quantity: 1,
                  orderMonth: '2026-08',
                  arrivalMonth: '2026-09',
                  productType: '기구부',
                  destination: '기타',
                  endUser: _customer,
                  orderChanges: 0,
                  specChanges: 0,
                ),
              );
            },
            child: const Text('등록'),
          ),
        ],
      );
}

class _DropInfoDialog extends StatefulWidget {
  final _PipelineLead lead;
  const _DropInfoDialog({required this.lead});

  @override
  State<_DropInfoDialog> createState() => _DropInfoDialogState();
}

class _DropInfoDialogState extends State<_DropInfoDialog> {
  final _key = GlobalKey<FormState>();
  final _competitor = TextEditingController();
  final _product = TextEditingController();
  String _reason = '가격 경쟁력';

  @override
  void dispose() {
    _competitor.dispose();
    _product.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Closed Lost · Drop 정보'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.lead.number} · ${widget.lead.project}',
                    style: RobinTheme.headingSm),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _reason,
                  decoration: const InputDecoration(
                      labelText: 'Drop 사유', border: OutlineInputBorder()),
                  items: const [
                    '가격 경쟁력',
                    '납기 조건',
                    '사양 미충족',
                    '경쟁사 선정',
                    '고객 투자 취소',
                    '기타',
                  ]
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _reason = value ?? _reason),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _competitor,
                  decoration: const InputDecoration(
                      labelText: '경쟁사', border: OutlineInputBorder()),
                  validator: (value) =>
                      (value?.trim().isEmpty ?? true) ? '경쟁사를 입력해주세요.' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _product,
                  decoration: const InputDecoration(
                      labelText: '경쟁 제품/사양', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: RobinTheme.signalRed),
            onPressed: () {
              if (!_key.currentState!.validate()) return;
              Navigator.pop(
                context,
                _DropInfo(
                    _reason, _competitor.text.trim(), _product.text.trim()),
              );
            },
            child: const Text('수주 실패 저장'),
          ),
        ],
      );
}

class _DropInfo {
  final String reason;
  final String competitor;
  final String product;
  const _DropInfo(this.reason, this.competitor, this.product);
}

class _PipelineLead {
  final String number;
  final String project;
  final String customer;
  final String dealer;
  final String owner;
  final int stage;
  final double amount;
  final double materialCost;
  final int quantity;
  final String orderMonth;
  final String arrivalMonth;
  final String productType;
  final String destination;
  final String endUser;
  final int orderChanges;
  final int specChanges;
  final bool erpLinked;
  final String? dropReason;

  const _PipelineLead({
    required this.number,
    required this.project,
    required this.customer,
    required this.dealer,
    required this.owner,
    required this.stage,
    required this.amount,
    required this.materialCost,
    required this.quantity,
    required this.orderMonth,
    required this.arrivalMonth,
    required this.productType,
    required this.destination,
    required this.endUser,
    required this.orderChanges,
    required this.specChanges,
    this.erpLinked = false,
    this.dropReason,
  });

  double get materialRatio => amount == 0 ? 0 : materialCost / amount * 100;

  _PipelineLead copyWith({
    String? number,
    int? stage,
    bool? erpLinked,
    int? orderChanges,
    String? dropReason,
  }) =>
      _PipelineLead(
        number: number ?? this.number,
        project: project,
        customer: customer,
        dealer: dealer,
        owner: owner,
        stage: stage ?? this.stage,
        amount: amount,
        materialCost: materialCost,
        quantity: quantity,
        orderMonth: orderMonth,
        arrivalMonth: arrivalMonth,
        productType: productType,
        destination: destination,
        endUser: endUser,
        orderChanges: orderChanges ?? this.orderChanges,
        specChanges: specChanges,
        erpLinked: erpLinked ?? this.erpLinked,
        dropReason: dropReason ?? this.dropReason,
      );
}

class _PipelineHistory {
  final String number;
  final String at;
  final String user;
  final String from;
  final String to;
  final String note;
  const _PipelineHistory({
    required this.number,
    required this.at,
    required this.user,
    required this.from,
    required this.to,
    required this.note,
  });
}

class _CostModel {
  final String name;
  final int cost;
  final int stroke;
  const _CostModel(this.name, this.cost, this.stroke);
}

class _CostResult {
  final double baseCost;
  final double specCost;
  final double optionCost;
  final double estimated;
  final double ratio;
  final double minimumPrice;
  final Color color;
  final String message;
  const _CostResult(this.baseCost, this.specCost, this.optionCost,
      this.estimated, this.ratio, this.minimumPrice, this.color, this.message);
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  const _InfoBox(this.label, this.value);

  @override
  Widget build(BuildContext context) => Container(
        width: 180,
        padding: const EdgeInsets.all(10),
        decoration: _softPanel(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: RobinTheme.labelXs),
            const SizedBox(height: 4),
            Text(value, style: RobinTheme.headingSm),
          ],
        ),
      );
}

class _DocumentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String file;
  final String status;
  const _DocumentRow(this.icon, this.label, this.file, this.status);

  @override
  Widget build(BuildContext context) => ListTile(
        dense: true,
        leading: Icon(icon, color: RobinTheme.primary),
        title: Text(label),
        subtitle: Text(file),
        trailing: Chip(label: Text(status)),
      );
}

class _ApprovalArrow extends StatelessWidget {
  const _ApprovalArrow();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 7),
        child: Icon(Icons.arrow_forward, size: 17, color: RobinTheme.textMuted),
      );
}

class _SimpleCostTable extends StatelessWidget {
  const _SimpleCostTable();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('제품코드')),
            DataColumn(label: Text('구분')),
            DataColumn(label: Text('표준단가')),
            DataColumn(label: Text('옵션 기준')),
            DataColumn(label: Text('수정일')),
          ],
          rows: const [
            DataRow(cells: [
              DataCell(Text('LM-1200')),
              DataCell(Text('기성품')),
              DataCell(Text('6,900,000원')),
              DataCell(Text('스트로크·홀 수')),
              DataCell(Text('2026-08-12')),
            ]),
            DataRow(cells: [
              DataCell(Text('RC-1500')),
              DataCell(Text('가공품')),
              DataCell(Text('9,800,000원')),
              DataCell(Text('유사실적 3건')),
              DataCell(Text('2026-08-15')),
            ]),
          ],
        ),
      );
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: RobinTheme.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: RobinTheme.border),
    );

BoxDecoration _softPanel() => BoxDecoration(
      color: RobinTheme.background,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: RobinTheme.border),
    );
