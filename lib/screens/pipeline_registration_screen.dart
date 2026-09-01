import 'package:flutter/material.dart';

import '../services/desktop_file_service.dart';
import '../theme/robin_theme.dart';
import '../utils/search_query.dart';
import '../widgets/robin_dialog.dart';
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
  ];
  static const _stageDescriptions = [
    '물동 · 등록가능',
    '컨셉설계 · 등록가능',
    '원가/결재 · 전환',
    '수주 성공 · 조회',
    '수주 실패 · 조회',
  ];
  static const _stageColors = [
    Color(0xFF2E7D32),
    Color(0xFF2563EB),
    Color(0xFFF57C00),
    Color(0xFF64748B),
    Color(0xFFC62828),
  ];

  final _searchController = TextEditingController();
  final _historyController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _strokeController = TextEditingController(text: '1000');
  final _orderPriceController = TextEditingController(text: '15,000,000');
  final _proposalMessageController = TextEditingController();
  final _lostDetailController = TextEditingController();
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
      dealer: '서울 대리점',
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
      number: 'RB-2608-004',
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
      erpOrderNumber: 'SO-2608-004',
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
  String _overviewStageFilter = '전체 단계';
  String _customerFilter = '고객사';
  String _productGroup = 'linear';
  int _modelIndex = 0;
  int _payloadCost = 0;
  int _axisCost = 0;
  bool _evidenceAttached = false;
  String _lostReason = '경쟁사 선점';
  final Set<String> _selectedOptions = {};
  final Map<String, _ProposalCollaborationData> _proposalCollaborations = {};

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
    _proposalMessageController.dispose();
    _lostDetailController.dispose();
    _assessTableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (robinUserProfile.value.isDealer) return _buildDealerWorkspace();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIntro(),
          const SizedBox(height: 10),
          _buildStageStrip(),
          const SizedBox(height: 8),
          _buildFilters(),
          const SizedBox(height: 8),
          _buildPipelineOverview(),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final activeWorkspace = _activeStage == 0
                  ? SizedBox(height: 560, child: _buildActiveWorkspace())
                  : _buildActiveWorkspace();
              final workspace = Container(
                decoration: _cardDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildWorkspaceTabs(),
                    const Divider(height: 1),
                    activeWorkspace,
                  ],
                ),
              );
              if (constraints.maxWidth < 1380) return workspace;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: workspace),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 292,
                    height: 720,
                    child: _buildHistoryPanel(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDealerWorkspace() {
    final department = robinUserProfile.value.department;
    final rows = _leads
        .where((lead) => lead.stage == 1 && lead.dealer == department)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('컨셉도면 송수신', style: RobinTheme.headingLg),
        const SizedBox(height: 4),
        Text(
          '내 대리점의 Proposal 건만 조회하며 설계팀과 도면·파일·댓글을 주고받을 수 있습니다.',
          style: RobinTheme.bodySm,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: _cardDecoration(),
            child: rows.isEmpty
                ? const Center(child: Text('진행 중인 컨셉도면 협업 건이 없습니다.'))
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      for (final lead in rows)
                        Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  child: Icon(Icons.architecture_outlined),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${lead.number} · ${lead.project}',
                                          style: RobinTheme.headingSm),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${lead.customer} · Proposal · 첨부 ${_proposalCollaborationFor(lead).documents.length}건 · 댓글 ${_proposalCollaborationFor(lead).comments.length}건',
                                        style: RobinTheme.bodySm,
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  key: ValueKey(
                                      'dealer-proposal-collaboration-${lead.number}'),
                                  onPressed: () =>
                                      _showProposalCollaboration(lead),
                                  icon: const Icon(Icons.swap_horiz, size: 18),
                                  label: const Text('도면·댓글 송수신'),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
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
                '전체 수주를 선택한 뒤 Assess → Proposal → Negotiation → Closed Won/Lost 흐름으로 등록·전환합니다.',
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
              FilledButton.icon(
                onPressed: _activeStage <= 1
                    ? _registerPipeline
                    : () =>
                        _message('신규 수주는 Assess 또는 Proposal에서만 등록할 수 있습니다.'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('신규 수주 등록'),
              ),
            ],
          );
          final header = constraints.maxWidth < 1050
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 10), actions],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: title),
                    const SizedBox(width: 12),
                    actions,
                  ],
                );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: RobinTheme.primary.withValues(alpha: .055),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: RobinTheme.primary.withValues(alpha: .24)),
                ),
                child: Text(
                  '등록 원칙 · 신규 수주는 Assess 또는 Proposal에서만 생성합니다. Negotiation과 Closed Won/Lost는 기존 수주의 단계 전환·조회·이력 관리 화면입니다.',
                  style: RobinTheme.labelXs.copyWith(
                    color: RobinTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );

  Widget _buildStageStrip() => SizedBox(
        height: 88,
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
                width: 206,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(_stageDescriptions[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: RobinTheme.labelXs),
                        ),
                        Text(
                          '${_compactMoney(amount)} · 변경 ${orders + specs}',
                          style: RobinTheme.labelXs
                              .copyWith(color: RobinTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

  Widget _buildPipelineOverview() {
    final rows = _filteredLeads;
    final selectedHistory = _selected == null
        ? const <_PipelineHistory>[]
        : _histories
            .where((history) => history.number == _selected!.number)
            .take(4)
            .toList();
    return SizedBox(
      height: 152,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    color: RobinTheme.background,
                    child: Row(
                      children: [
                        SizedBox(
                            width: 104,
                            child: Text('가수주번호', style: RobinTheme.labelXs)),
                        Expanded(
                            flex: 3,
                            child:
                                Text('프로젝트 / 고객사', style: RobinTheme.labelXs)),
                        SizedBox(
                            width: 96,
                            child: Text('단계', style: RobinTheme.labelXs)),
                        SizedBox(
                            width: 86,
                            child: Text('예상금액', style: RobinTheme.labelXs)),
                        SizedBox(
                            width: 86,
                            child: Text('변경', style: RobinTheme.labelXs)),
                        SizedBox(
                            width: 92,
                            child: Text('담당자', style: RobinTheme.labelXs)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: rows.length,
                      itemBuilder: (context, index) {
                        final lead = rows[index];
                        final selected = _selected?.number == lead.number;
                        return InkWell(
                          key: ValueKey('pipeline-overview-${lead.number}'),
                          onTap: () => setState(() {
                            _selected = lead;
                            _activeStage = lead.stage;
                          }),
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            color: selected
                                ? RobinTheme.primary.withValues(alpha: .06)
                                : null,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 104,
                                  child: Text(lead.number,
                                      style: RobinTheme.labelXs.copyWith(
                                          color: RobinTheme.primary,
                                          fontWeight: FontWeight.w700)),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                      '${lead.project} · ${lead.customer}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: RobinTheme.bodySm),
                                ),
                                SizedBox(
                                    width: 96,
                                    child: _stageBadgeCompact(lead.stage)),
                                SizedBox(
                                    width: 86,
                                    child: Text(_compactMoney(lead.amount),
                                        style: RobinTheme.bodySm)),
                                SizedBox(
                                    width: 86,
                                    child: Text(
                                        '주문 ${lead.orderChanges} · 사양 ${lead.specChanges}',
                                        style: RobinTheme.labelXs)),
                                SizedBox(
                                    width: 92,
                                    child: Text(lead.owner,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: RobinTheme.bodySm)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 290,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('선택 수주 단계 변경 이력', style: RobinTheme.headingSm),
                  const SizedBox(height: 5),
                  if (_selected == null)
                    Expanded(
                      child: Center(
                        child: Text('수주 건을 선택하세요.', style: RobinTheme.labelXs),
                      ),
                    )
                  else if (selectedHistory.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text('${_selected!.number} · 저장된 이력 없음',
                            style: RobinTheme.labelXs),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView(
                        children: [
                          for (final history in selectedHistory)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                '${history.from} → ${history.to} · ${history.at.substring(5, 16)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: RobinTheme.labelXs,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stageBadgeCompact(int stage) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: _stageColors[stage].withValues(alpha: .09),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(_stageNames[stage],
              style: RobinTheme.labelXs.copyWith(color: _stageColors[stage])),
        ),
      );

  Widget _probabilityDot(bool active) => Center(
        child: Icon(
          active ? Icons.circle : Icons.radio_button_unchecked,
          size: 12,
          color: active ? RobinTheme.signalGreen : RobinTheme.textMuted,
        ),
      );

  Widget _buildFilters() {
    final customers = _leads.map((lead) => lead.customer).toSet().toList()
      ..sort();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: _cardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 650;
          final searchWidth = compact
              ? constraints.maxWidth
              : (constraints.maxWidth - 274).clamp(220.0, double.infinity);
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: compact ? (constraints.maxWidth - 8) / 2 : 120,
                child: DropdownButtonFormField<String>(
                  key: const ValueKey('pipeline-search-stage'),
                  isExpanded: true,
                  initialValue: _overviewStageFilter,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: ['전체 단계', ..._stageNames]
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _overviewStageFilter = value;
                      final stage = _stageNames.indexOf(value);
                      if (stage >= 0) _activeStage = stage;
                    });
                  },
                ),
              ),
              SizedBox(
                width: compact ? (constraints.maxWidth - 8) / 2 : 130,
                child: DropdownButtonFormField<String>(
                  key: const ValueKey('pipeline-search-customer'),
                  isExpanded: true,
                  initialValue: _customerFilter,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: ['고객사', ...customers]
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _customerFilter = value ?? '고객사'),
                ),
              ),
              SizedBox(
                width: searchWidth,
                child: TextField(
                  key: const ValueKey('pipeline-search-query'),
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: '가수주번호 / 프로젝트명 / % 조건 검색',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

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
                      ? 'Assess · 물동 · 등록가능'
                      : index == 1
                          ? 'Proposal · 컨셉설계 · 등록가능'
                          : index == 2
                              ? 'Negotiation · 원가/결재 · 전환'
                              : '${_stageNames[index]} · 조회'),
                ),
              ),
          ],
        ),
      );

  Widget _buildActiveWorkspace() => switch (_activeStage) {
        0 => _buildAssessWorkspace(),
        1 => _buildProposalWorkspace(),
        2 => _buildNegotiationWorkspace(),
        3 => _buildClosedWonWorkspace(),
        _ => _buildClosedLostWorkspace(),
      };

  Widget _buildAssessWorkspace() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '월 단위 물동 Excel을 업로드하면 가번호가 자동 발행됩니다. B0~M 가능성을 확인하고 Proposal로 연결합니다.',
                    style: RobinTheme.bodySm,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _downloadTrafficTemplate,
                  icon: const Icon(Icons.download_outlined, size: 17),
                  label: const Text('양식 다운로드'),
                ),
                const SizedBox(width: 7),
                OutlinedButton.icon(
                  onPressed: _showExcelImportDialog,
                  icon: const Icon(Icons.upload_file_outlined, size: 17),
                  label: const Text('물동 Excel 불러오기'),
                ),
                const SizedBox(width: 7),
                OutlinedButton.icon(
                  key: const ValueKey('open-erp-order-match'),
                  onPressed: _showErpOrderMatchDialog,
                  icon: const Icon(Icons.link, size: 17),
                  label: const Text('ERP 번호 매칭'),
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
                        columnSpacing: 5,
                        headingTextStyle: RobinTheme.bodySm
                            .copyWith(fontWeight: FontWeight.w700),
                        dataTextStyle: RobinTheme.bodySm,
                        headingRowHeight: 38,
                        dataRowMinHeight: 38,
                        dataRowMaxHeight: 48,
                        columns: [
                          DataColumn(
                              label:
                                  _pipelineTableText(112, '가수주번호 / ERP 수주번호')),
                          DataColumn(label: _pipelineTableText(68, '고객사')),
                          DataColumn(label: _pipelineTableText(76, '대리점')),
                          DataColumn(
                              label: _pipelineTableText(130, '프로젝트명(예상)')),
                          DataColumn(label: _pipelineTableText(24, 'B0')),
                          DataColumn(label: _pipelineTableText(24, 'B1')),
                          DataColumn(label: _pipelineTableText(24, 'B2')),
                          DataColumn(label: _pipelineTableText(24, 'B3')),
                          DataColumn(label: _pipelineTableText(24, 'M')),
                          DataColumn(label: _pipelineTableText(70, '예상금액')),
                          DataColumn(label: _pipelineTableText(58, '업로드월')),
                          DataColumn(label: _pipelineTableText(62, '상태')),
                          DataColumn(label: _pipelineTableText(48, '상세')),
                        ],
                        rows: _filteredForStage.map((lead) {
                          final selected = _selected?.number == lead.number;
                          return DataRow(
                            key: ValueKey('assess-row-${lead.number}'),
                            selected: selected,
                            onSelectChanged: (_) =>
                                setState(() => _selected = lead),
                            cells: [
                              DataCell(
                                SizedBox(
                                  key: ValueKey(
                                      'assess-detail-number-${lead.number}'),
                                  child: _pipelineTableText(
                                    112,
                                    '${lead.number}\n${lead.erpOrderNumber ?? 'ERP 미매칭'}',
                                    style: TextStyle(
                                      color: lead.erpOrderNumber == null
                                          ? RobinTheme.primary
                                          : RobinTheme.signalGreen,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(_pipelineTableText(68, lead.customer)),
                              DataCell(_pipelineTableText(76, lead.dealer)),
                              DataCell(_pipelineTableText(130, lead.project)),
                              DataCell(_probabilityDot(true)),
                              DataCell(_probabilityDot(true)),
                              DataCell(_probabilityDot(lead.quantity > 10)),
                              DataCell(_probabilityDot(false)),
                              DataCell(_probabilityDot(false)),
                              DataCell(_pipelineTableText(
                                  70, '${_money(lead.amount)}만원')),
                              DataCell(_pipelineTableText(58, lead.orderMonth)),
                              DataCell(SizedBox(
                                  width: 62,
                                  child: _stageBadgeCompact(lead.stage))),
                              DataCell(
                                IconButton(
                                  key: ValueKey(
                                      'assess-detail-button-${lead.number}'),
                                  tooltip: '47개 전체 항목 보기',
                                  onPressed: () {
                                    setState(() => _selected = lead);
                                    _showAssessDetail(lead);
                                  },
                                  icon: const Icon(Icons.open_in_new, size: 18),
                                ),
                              ),
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
          const Divider(height: 1),
          _buildAssessPainPointPanel(),
        ],
      );

  Widget _buildAssessPainPointPanel() => Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('개별 등록 / Pain Point 수집', style: RobinTheme.headingSm),
            const SizedBox(height: 7),
            Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '고객사명',
                      hintText: 'ERP 고객사 검색',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '대리점 / 담당자',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                const Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Pain Point 요약',
                      hintText: '현장 Pain Point 및 요구사항',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                OutlinedButton(
                  onPressed: () => _message('Pain Point를 임시 저장했습니다.'),
                  child: const Text('임시 저장'),
                ),
                const SizedBox(width: 7),
                FilledButton(
                  onPressed: _registerPipeline,
                  child: const Text('가번호 발행 후 저장'),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildProposalWorkspace() {
    final rows = _filteredForStage;
    final lead = rows.contains(_selected)
        ? _selected
        : (rows.isEmpty ? null : rows.first);
    if (lead == null) {
      return const Center(child: Text('Proposal 단계의 수주가 없습니다.'));
    }
    final collaboration = _proposalCollaborationFor(lead);
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<_PipelineLead>(
                key: const ValueKey('proposal-order-selector'),
                initialValue: lead,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Proposal 수주 선택',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: rows
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text('${item.number} · ${item.project}'),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selected = value),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _message('SmartOrder 고객 기초정보를 불러왔습니다.'),
              icon: const Icon(Icons.sync, size: 17),
              label: const Text('SmartOrder 연계'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final editor = _buildProposalEditor(lead, collaboration);
            final channel = _buildProposalChannel(lead, collaboration);
            if (constraints.maxWidth < 1050) {
              return Column(
                children: [editor, const SizedBox(height: 10), channel],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: editor),
                const SizedBox(width: 12),
                SizedBox(width: 380, child: channel),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _activeStage = 0),
              child: const Text('← 이전'),
            ),
            const SizedBox(width: 7),
            OutlinedButton(
              onPressed: () => _message('Proposal 입력 내용을 임시 저장했습니다.'),
              child: const Text('임시 저장'),
            ),
            const SizedBox(width: 7),
            FilledButton.icon(
              onPressed: () => _changeStage(lead, 2),
              icon: const Icon(Icons.arrow_forward, size: 17),
              label: const Text('도면 확정 · Negotiation으로'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProposalEditor(
      _PipelineLead lead, _ProposalCollaborationData collaboration) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: _softPanel(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Proposal · 컨셉도면 대응 · 제안서 전달', style: RobinTheme.headingSm),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _proposalField('고객사명', lead.customer),
                  _proposalField('프로젝트명', lead.project),
                  _proposalField('제품 구분', lead.productType),
                  _proposalField('예상 금액(만원)', _money(lead.amount)),
                  _proposalField('희망 납기일', lead.arrivalMonth),
                  _proposalField('설치 장소', lead.destination),
                ],
              ),
              const SizedBox(height: 10),
              const TextField(
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: '제안 내용 요약',
                  hintText: '솔루션 제안 요점과 고객 요구사항을 입력하세요.',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: RobinTheme.signalGreen.withValues(alpha: .045),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: RobinTheme.signalGreen.withValues(alpha: .38)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('컨셉도면 사양 입력',
                              style: RobinTheme.headingSm
                                  .copyWith(color: RobinTheme.signalGreen)),
                        ),
                        const Chip(label: Text('Proposal 필수')),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _proposalField('모델명', 'GRP-VAC-40', compact: true),
                        _proposalField('축 수', '6축', compact: true),
                        _proposalField('가반하중', '120 kg', compact: true),
                        _proposalField('최대 Reach', '2,650 mm', compact: true),
                        _proposalField('설치 방식', '바닥 설치', compact: true),
                        _proposalField('반복정밀도', '±0.05 mm', compact: true),
                        _proposalField('그리퍼 타입', '진공 그리퍼', compact: true),
                        _proposalField('제품 중량', '38 kg', compact: true),
                        _proposalField('제품 크기', '850×620×420', compact: true),
                        _proposalField('케이블 방향', '우측', compact: true),
                        _proposalField('안전 옵션', '라이트커튼', compact: true),
                        _proposalField('컨트롤러/통신', 'RCX-500', compact: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: _softPanel(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child:
                        Text('컨셉도면 업로드 · 버전 이력', style: RobinTheme.headingSm),
                  ),
                  OutlinedButton.icon(
                    key: ValueKey('proposal-collaboration-${lead.number}'),
                    onPressed: () => _showProposalCollaboration(lead),
                    icon: const Icon(Icons.upload_file_outlined, size: 17),
                    label: const Text('도면·파일 관리'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (var index = collaboration.documents.length - 1;
                  index >= 0;
                  index--)
                _proposalDocumentRow(
                  collaboration.documents[index],
                  latest: index == collaboration.documents.length - 1,
                ),
              const SizedBox(height: 6),
              Text('최신 확정 사양은 Negotiation 단계로 자동 승계됩니다.',
                  style: RobinTheme.labelXs),
            ],
          ),
        ),
      ],
    );
  }

  Widget _proposalField(String label, String value, {bool compact = false}) =>
      SizedBox(
        width: compact ? 150 : 210,
        child: TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      );

  Widget _proposalDocumentRow(_ProposalDocument document,
          {required bool latest}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: latest
              ? RobinTheme.signalGreen.withValues(alpha: .055)
              : RobinTheme.surface,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
              color: latest
                  ? RobinTheme.signalGreen.withValues(alpha: .5)
                  : RobinTheme.border),
        ),
        child: Row(
          children: [
            Icon(Icons.description_outlined,
                size: 18,
                color: latest ? RobinTheme.signalGreen : RobinTheme.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${document.fileName} · ${document.revision}',
                      style: RobinTheme.bodySm
                          .copyWith(fontWeight: FontWeight.w700)),
                  Text('${document.at} · ${document.uploader}',
                      style: RobinTheme.labelXs),
                ],
              ),
            ),
            if (latest) const Chip(label: Text('최신')),
          ],
        ),
      );

  Widget _buildProposalChannel(
      _PipelineLead lead, _ProposalCollaborationData collaboration) {
    return Container(
      height: 590,
      decoration: _softPanel(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('도면 협의 채널', style: RobinTheme.headingSm),
                      Text('대리점 ↔ 설계팀 도면 검토 의견', style: RobinTheme.labelXs),
                    ],
                  ),
                ),
                Chip(label: Text('${collaboration.comments.length}건')),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                for (final comment in collaboration.comments)
                  Align(
                    alignment: comment.team == '설계팀'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      margin: EdgeInsets.only(
                        bottom: 8,
                        left: comment.parentId == null ? 0 : 24,
                      ),
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: comment.team == '설계팀'
                            ? RobinTheme.primary.withValues(alpha: .07)
                            : RobinTheme.signalGreen.withValues(alpha: .07),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: RobinTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${comment.author} · ${comment.team}',
                              style: RobinTheme.labelXs
                                  .copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Text(comment.message, style: RobinTheme.bodySm),
                          const SizedBox(height: 3),
                          Text(comment.at, style: RobinTheme.labelXs),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const ValueKey('proposal-inline-message'),
                    controller: _proposalMessageController,
                    onSubmitted: (_) => _sendProposalMessage(lead),
                    decoration: const InputDecoration(
                      hintText: '도면 검토 의견 입력',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                FilledButton(
                  onPressed: () => _sendProposalMessage(lead),
                  child: const Text('전송'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendProposalMessage(_PipelineLead lead) {
    final message = _proposalMessageController.text.trim();
    if (message.isEmpty) return;
    final current = _proposalCollaborationFor(lead);
    setState(() {
      _proposalCollaborations[lead.number] = _ProposalCollaborationData(
        documents: current.documents,
        comments: [
          ...current.comments,
          _ProposalComment(
            'inline-${DateTime.now().microsecondsSinceEpoch}',
            null,
            robinUserProfile.value.name,
            '설계팀',
            message,
            _now(),
          ),
        ],
        specCopied: current.specCopied,
      );
      _proposalMessageController.clear();
    });
  }

  Widget _buildNegotiationWorkspace() {
    final negotiationRows = _filteredForStage;
    final selectedLead = negotiationRows.contains(_selected)
        ? _selected
        : (negotiationRows.isEmpty ? null : negotiationRows.first);
    final calc = _calculateCost();
    final dealerView = robinUserProfile.value.isDealer;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
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
              if (!dealerView) ...[
                OutlinedButton.icon(
                  onPressed: _showPriceTableAdmin,
                  icon: const Icon(Icons.price_change_outlined, size: 17),
                  label: const Text('ROBIN 단가표 관리'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: RobinTheme.warningLight,
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: RobinTheme.warning.withValues(alpha: .35)),
            ),
            child: Text(
              selectedLead == null
                  ? '신규 등록 불가 · Assess 또는 Proposal에서 생성된 기존 수주를 선택하세요.'
                  : 'Proposal 도면 스펙 자동 연동 · 가수주번호 ${selectedLead.number}',
              style: RobinTheme.labelXs.copyWith(color: RobinTheme.warning),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final costArea = Column(
                children: [
                  _buildCostInputs(dealerView),
                  const SizedBox(height: 10),
                  _buildCostResult(calc, dealerView),
                ],
              );
              final approvalArea = _buildApprovalArea(calc, dealerView);
              if (constraints.maxWidth < 1050) {
                return Column(
                  children: [
                    costArea,
                    const SizedBox(height: 10),
                    approvalArea,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: costArea),
                  const SizedBox(width: 12),
                  SizedBox(width: 350, child: approvalArea),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => setState(() => _activeStage = 1),
                child: const Text('← 이전'),
              ),
              const SizedBox(width: 7),
              OutlinedButton(
                onPressed: () => _message('Negotiation 입력 내용을 임시 저장했습니다.'),
                child: const Text('임시 저장'),
              ),
              const SizedBox(width: 7),
              FilledButton(
                onPressed: selectedLead == null
                    ? null
                    : () => _changeStage(selectedLead, 3),
                child: const Text('Closed Won으로'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostInputs(bool dealerView) => Container(
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
                        label: Text(dealerView
                            ? entry.key
                            : '${entry.key} (+${_money(entry.value / 10000)}만)'),
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
            if (dealerView)
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: RobinTheme.background,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.visibility_off_outlined, size: 17),
                    SizedBox(width: 7),
                    Expanded(
                        child: Text('ROBIN 단가표와 유사 모델 원가 근거는 사내 계정에만 표시됩니다.')),
                  ],
                ),
              )
            else ...[
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
                            'ROBIN 단가표에서 스트로크·가반하중·축 조합이 가까운 유사 모델 3건을 찾아 예상 재료비를 계산합니다.')),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _SimilarModelEvidence(group: _productGroup),
            ],
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
                    Expanded(child: Text('대리점에는 입력 판가와 사내 검증 상태만 표시합니다.')),
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
            if (dealerView)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: RobinTheme.signalGreen.withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                      color: RobinTheme.signalGreen.withValues(alpha: .25)),
                ),
                child: const Text(
                    '입력 판가는 사내 ROBIN 단가표로 검증됩니다. 재료비·재료비율·유사 모델 단가는 표시되지 않습니다.'),
              )
            else ...[
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
            ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.approval_outlined, color: calc.color),
              const SizedBox(width: 7),
              Expanded(
                child: Text('ROBIN 결재시스템', style: RobinTheme.headingSm),
              ),
              const SizedBox(width: 6),
              _evidenceBadge(_evidenceAttached),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dealerView ? '결재선은 사내 재료비 검증 결과에 따라 자동 지정됩니다.' : '재료비율 결재선 · 임시 기준',
            style: RobinTheme.labelXs.copyWith(fontWeight: FontWeight.w700),
          ),
          if (!dealerView) ...[
            const SizedBox(height: 6),
            const Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                Chip(label: Text('75% 미만 · 참조')),
                Chip(label: Text('75~80% · 팀장')),
                Chip(label: Text('80% 초과 · 사업부장')),
              ],
            ),
          ],
          const SizedBox(height: 10),
          _approvalStageCard('1단계 · 기안자',
              dealerView ? '대리점/영업담당자' : robinUserProfile.value.name,
              status: '자동 설정', completed: true),
          const SizedBox(height: 7),
          _approvalStageCard('2단계 · 영업팀장', isWarning ? '승인 필요' : '참조',
              status: isWarning ? '승인 대기' : '자동 통과', completed: !isWarning),
          if (needsDivisionApproval) ...[
            const SizedBox(height: 7),
            _approvalStageCard(
                '3단계 · 사업부장', dealerView ? '추가 승인' : '80% 초과 자동 지정',
                status: '예정', completed: false),
          ],
          const SizedBox(height: 12),
          Text('증빙 상태', style: RobinTheme.headingSm),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _evidenceAttached = true),
              icon: const Icon(Icons.attach_file, size: 17),
              label: Text(dealerView ? '인보이스 발행 요청' : '발주서/증빙 첨부'),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: RobinTheme.primary.withValues(alpha: .055),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Text(
              '결재 완료 시 Closed Won으로 전환하고 ERP 수주번호를 연계합니다. 반려 시 Negotiation을 유지합니다.',
              style: TextStyle(fontSize: 11),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
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
                      note: dealerView
                          ? '대리점 판가 사내 검증 · ${_evidenceAttached ? '인보이스 요청' : '인보이스 미요청'}'
                          : '재료비율 ${calc.ratio.toStringAsFixed(1)}% · ${_evidenceAttached ? '증빙 첨부' : '증빙 미첨부'}',
                    ),
                  );
                }
                setState(() {});
                _message(needsDivisionApproval
                    ? '영업팀장 → 사업부장 결재를 상신했습니다.'
                    : '영업팀장 결재를 상신했습니다.');
              },
              icon: const Icon(Icons.send_outlined, size: 17),
              label: const Text('결재 요청 전송'),
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

  Widget _approvalStageCard(String title, String assignee,
          {required String status, required bool completed}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: (completed ? RobinTheme.signalGreen : RobinTheme.warning)
              .withValues(alpha: .06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (completed ? RobinTheme.signalGreen : RobinTheme.warning)
                .withValues(alpha: .35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: RobinTheme.labelXs),
            const SizedBox(height: 3),
            Text(assignee, style: RobinTheme.headingSm),
            const SizedBox(height: 2),
            Text(status,
                style: RobinTheme.labelXs.copyWith(
                    color: completed
                        ? RobinTheme.signalGreen
                        : RobinTheme.warning)),
          ],
        ),
      );

  Widget _buildClosedWonWorkspace() {
    final rows = _filteredForStage;
    final lead = rows.contains(_selected)
        ? _selected
        : (rows.isEmpty ? null : rows.first);
    if (lead == null) {
      return const Center(child: Text('Closed Won 수주가 없습니다.'));
    }
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      children: [
        _terminalOrderSelector(rows, lead, 'Closed Won 수주 선택'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: RobinTheme.signalGreen.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
                color: RobinTheme.signalGreen.withValues(alpha: .55)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✓ Closed Won · 수주 확정',
                  style: RobinTheme.headingLg
                      .copyWith(color: RobinTheme.signalGreen)),
              const SizedBox(height: 5),
              Text('최종 계약과 결재가 완료된 수주를 ERP와 프로젝트 관리로 연결합니다.',
                  style: RobinTheme.bodySm),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'ROBIN 가수주번호',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      child: Text(lead.number),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'ERP 공식 수주번호',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      child: Text(lead.erpOrderNumber ?? 'ERP 연계 대기'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '확정 수주금액',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      child: Text('${_money(lead.amount)}만원'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _message('계약서 첨부 영역을 열었습니다.'),
                icon: const Icon(Icons.attach_file, size: 17),
                label: const Text('계약서 첨부'),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                      color: RobinTheme.signalGreen.withValues(alpha: .4)),
                ),
                child: const Text('ERP 연동 완료 시 프로젝트 관리 화면에 설계 단계부터 자동 등록됩니다.'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => _showStageChangeDialog(lead),
              child: const Text('단계 변경'),
            ),
            const SizedBox(width: 7),
            FilledButton.icon(
              onPressed: () {
                _message('수주 확정 처리가 완료되었습니다. 프로젝트 관리에 반영했습니다.');
                widget.onNavigate?.call(3);
              },
              icon: const Icon(Icons.check_circle_outline, size: 17),
              label: const Text('수주 확정 완료'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClosedLostWorkspace() {
    final rows = _filteredForStage;
    final lead = rows.contains(_selected)
        ? _selected
        : (rows.isEmpty ? null : rows.first);
    if (lead == null) {
      return const Center(child: Text('Closed Lost 수주가 없습니다.'));
    }
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      children: [
        _terminalOrderSelector(rows, lead, 'Closed Lost 수주 선택'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: RobinTheme.signalRed.withValues(alpha: .055),
            borderRadius: BorderRadius.circular(9),
            border:
                Border.all(color: RobinTheme.signalRed.withValues(alpha: .55)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✕ Closed Lost · 수주 실패',
                  style: RobinTheme.headingLg
                      .copyWith(color: RobinTheme.signalRed)),
              const SizedBox(height: 5),
              Text('${lead.number} · ${lead.customer} · ${lead.project}',
                  style: RobinTheme.bodySm),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _lostReason,
                decoration: const InputDecoration(
                  labelText: '실패 사유 · 필수',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  '경쟁사 선점',
                  '예산 취소',
                  '고객 변심',
                  '가격 협의 실패',
                  '사양 불일치',
                  '기타',
                ]
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _lostReason = value ?? _lostReason),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _lostDetailController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: '상세 사유',
                  hintText:
                      lead.dropReason ?? '구체적인 실패 경위와 경쟁사·경쟁제품 정보를 입력하세요.',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Closed Lost는 유지되며 별도의 “수주 중단” 단계는 사용하지 않습니다. 어느 단계에서든 Drop 처리한 결과가 이 화면에 누적됩니다.',
                style: TextStyle(fontSize: 11, color: RobinTheme.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => _showStageChangeDialog(lead),
              child: const Text('단계 변경'),
            ),
            const SizedBox(width: 7),
            FilledButton.icon(
              onPressed: () => _saveClosedLost(lead),
              style:
                  FilledButton.styleFrom(backgroundColor: RobinTheme.signalRed),
              icon: const Icon(Icons.cancel_outlined, size: 17),
              label: const Text('실패 사유 저장'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _terminalOrderSelector(
          List<_PipelineLead> rows, _PipelineLead selected, String label) =>
      DropdownButtonFormField<_PipelineLead>(
        initialValue: selected,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: rows
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text('${item.number} · ${item.project}'),
                ))
            .toList(),
        onChanged: (value) => setState(() => _selected = value),
      );

  void _saveClosedLost(_PipelineLead lead) {
    final detail = _lostDetailController.text.trim();
    final reason = detail.isEmpty ? _lostReason : '$_lostReason · $detail';
    final index = _leads.indexWhere((item) => item.number == lead.number);
    if (index < 0) return;
    final updated = lead.copyWith(dropReason: reason);
    setState(() {
      _leads[index] = updated;
      _selected = updated;
      _histories.insert(
        0,
        _PipelineHistory(
          number: lead.number,
          at: _now(),
          user: robinUserProfile.value.name,
          from: 'Closed Lost',
          to: '실패 사유 저장',
          note: reason,
        ),
      );
      _lostDetailController.clear();
    });
    _message('${lead.number} 실패 사유를 저장했습니다.');
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

  List<_PipelineLead> get _filteredForStage {
    final query = _searchController.text;
    return _leads.where((lead) {
      if (lead.stage != _activeStage) return false;
      if (_customerFilter != '고객사' && lead.customer != _customerFilter) {
        return false;
      }
      return matchesSearchQuery([
        lead.number,
        lead.project,
        lead.customer,
        lead.dealer,
        lead.owner,
        '${lead.materialRatio.toStringAsFixed(1)}%',
      ], query);
    }).toList();
  }

  List<_PipelineLead> get _filteredLeads {
    final query = _searchController.text;
    return _leads.where((lead) {
      if (_overviewStageFilter != '전체 단계' &&
          _stageNames[lead.stage] != _overviewStageFilter) {
        return false;
      }
      if (_customerFilter != '고객사' && lead.customer != _customerFilter) {
        return false;
      }
      return matchesSearchQuery([
        lead.number,
        lead.project,
        lead.customer,
        lead.dealer,
        lead.owner,
        '${lead.materialRatio.toStringAsFixed(1)}%',
      ], query);
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
    final number = _nextRobinNumber();
    final result = await showDialog<_PipelineLead>(
      context: context,
      builder: (context) => _PipelineRegistrationDialog(
        number: number,
        initialStage: _activeStage == 1 ? 1 : 0,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _leads.insert(0, result);
      _activeStage = 0;
      _selected = result;
    });
    _message('${result.number} ${_stageNames[result.stage]} 신규 수주가 등록되었습니다.');
  }

  String _nextRobinNumber([Set<String> reserved = const {}]) {
    final now = DateTime.now();
    final year = (now.year % 100).toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final prefix = 'RB-$year$month-';
    var highest = 0;
    for (final number in [
      ..._leads.map((lead) => lead.number),
      ...reserved,
    ]) {
      if (!number.startsWith(prefix)) continue;
      final sequence = int.tryParse(number.substring(prefix.length));
      if (sequence != null && sequence > highest) highest = sequence;
    }
    return '$prefix${(highest + 1).toString().padLeft(3, '0')}';
  }

  Future<void> _downloadTrafficTemplate() async {
    final sample = _selected ?? _leads.first;
    final fields = _assessDetailFields(sample);
    final path = await DesktopFileService.saveWorkbook(
      suggestedName: '수주물동관리_양식.xlsx',
      sheetName: '수주물동관리',
      headers: fields.map((field) => field.label).toList(),
      rows: [fields.map((field) => field.value).toList()],
    );
    if (path != null && mounted) _message('Excel 양식 저장 완료: $path');
  }

  Future<void> _showExcelImportDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _ExcelImportPreviewDialog(),
    );
    if (confirmed != true || !mounted) return;

    final reserved = <String>{};
    String reserveNumber() {
      final number = _nextRobinNumber(reserved);
      reserved.add(number);
      return number;
    }

    final imported = [
      _PipelineLead(
        number: reserveNumber(),
        project: '2차전지 조립라인 로봇 자동화',
        customer: 'LG에너지솔루션',
        dealer: '시스템알앤디',
        owner: robinUserProfile.value.name,
        stage: 0,
        amount: 32300,
        materialCost: 23983,
        quantity: 4,
        orderMonth: '2026-10',
        arrivalMonth: '2026-11',
        productType: '기구부',
        destination: 'LG향',
        endUser: 'LG에너지솔루션',
        orderChanges: 0,
        specChanges: 0,
      ),
      _PipelineLead(
        number: reserveNumber(),
        project: '디스플레이 물류 이송 로봇',
        customer: 'LG디스플레이',
        dealer: '본사 직판',
        owner: robinUserProfile.value.name,
        stage: 0,
        amount: 344900,
        materialCost: 249926,
        quantity: 10,
        orderMonth: '2026-11',
        arrivalMonth: '2026-12',
        productType: '로봇',
        destination: 'LG향',
        endUser: 'LG디스플레이',
        orderChanges: 0,
        specChanges: 0,
      ),
    ];
    setState(() {
      _leads.insertAll(0, imported);
      _activeStage = 0;
      _selected = imported.first;
      for (final lead in imported.reversed) {
        _histories.insert(
          0,
          _PipelineHistory(
            number: lead.number,
            at: _now(),
            user: robinUserProfile.value.name,
            from: 'Excel 업로드',
            to: 'Assess',
            note: '수주물동관리 양식.xlsx 신규 행 · ROBIN 가수주번호 자동 채번',
          ),
        );
      }
    });
    _message(
        '${imported.length}건을 등록했습니다. ${imported.map((lead) => lead.number).join(', ')} 자동 채번 완료');
  }

  Future<void> _showErpOrderMatchDialog() async {
    final selected = _selected;
    if (selected == null) {
      _message('ERP 공식 수주번호를 매칭할 물동 행을 먼저 선택해주세요.');
      return;
    }
    final erpNumber = await showDialog<String>(
      context: context,
      builder: (context) => _ErpOrderMatchDialog(lead: selected),
    );
    if (erpNumber == null || !mounted) return;
    final duplicate = _leads.any((lead) =>
        !identical(lead, selected) && lead.erpOrderNumber == erpNumber);
    if (duplicate) {
      _message('$erpNumber는 이미 다른 가수주 건에 매칭된 ERP 번호입니다.');
      return;
    }
    final updated = selected.copyWith(
      erpLinked: true,
      erpOrderNumber: erpNumber,
    );
    setState(() {
      final index = _leads.indexOf(selected);
      if (index >= 0) _leads[index] = updated;
      _selected = updated;
      _histories.insert(
        0,
        _PipelineHistory(
          number: updated.number,
          at: _now(),
          user: robinUserProfile.value.name,
          from: '가수주번호 ${updated.number}',
          to: 'ERP 수주번호 $erpNumber',
          note: 'ERP 공식 수주번호 매칭',
        ),
      );
    });
    _message('${updated.number} ↔ $erpNumber 매칭을 완료했습니다.');
  }

  Future<void> _showAssessDetail(_PipelineLead lead) => showDialog<void>(
        context: context,
        builder: (context) => _AssessDetailDialog(
          lead: lead,
          fields: _assessDetailFields(lead),
        ),
      );

  List<_AssessField> _assessDetailFields(_PipelineLead lead) {
    final unitPrice = lead.quantity == 0 ? 0 : lead.amount / lead.quantity;
    final grade = lead.materialRatio > 80
        ? 'WORST'
        : lead.materialRatio >= 75
            ? 'B-'
            : 'BEST';
    final channel = lead.dealer.contains('본사') ? '직판' : '대리점';
    final orderYear = lead.orderMonth.split('-').first;
    final arrivalYear = lead.arrivalMonth.split('-').first;
    String decimal(num value, [int digits = 2]) =>
        value.toStringAsFixed(digits).replaceFirst(RegExp(r'\.?0+$'), '');
    return [
      const _AssessField('기본·조직', '주차', '2026-W32'),
      _AssessField('기본·조직', '수주월', lead.orderMonth),
      _AssessField('기본·조직', '입고월', lead.arrivalMonth),
      _AssessField('기본·조직', 'ERP 수주번호',
          lead.erpOrderNumber ?? '미매칭 (가수주 ${lead.number})'),
      const _AssessField('기본·조직', '제품코드', '미등록'),
      _AssessField('기본·조직', '담당자', lead.owner),
      const _AssessField('기본·조직', '사업부', '로봇사업부'),
      const _AssessField('기본·조직', 'Item', '단품'),
      const _AssessField('기본·조직', '내수/수출', '내수'),
      const _AssessField('기본·조직', '제조구분', '내작'),
      _AssessField('제품·매출 분류', '제품류', lead.productType),
      const _AssessField('제품·매출 분류', '수익성구분', 'ROBOT'),
      const _AssessField('제품·매출 분류', '매출구분', '제품매출'),
      const _AssessField('제품·매출 분류', '생기원구분', '생기원'),
      _AssessField('제품·매출 분류', '향지', lead.destination),
      const _AssessField('제품·매출 분류', '향지구분', '국내'),
      _AssessField('제품·매출 분류', '채널', channel),
      _AssessField('제품·매출 분류', '채널구분', lead.dealer),
      _AssessField('고객·프로젝트', '거래처', lead.customer),
      _AssessField('고객·프로젝트', 'End User', lead.endUser),
      _AssessField('고객·프로젝트', 'PJT명', lead.project),
      _AssessField('고객·프로젝트', '단계', _stageNames[lead.stage]),
      _AssessField('고객·프로젝트', '전주등급', grade),
      _AssessField('고객·프로젝트', '등급', grade),
      const _AssessField('금액·원가', '통화', 'WON'),
      const _AssessField('금액·원가', '환율', '1'),
      const _AssessField('금액·원가', '외화단가', '-'),
      const _AssessField('금액·원가', '외화매출액', '-'),
      _AssessField('금액·원가', '수량', '${lead.quantity}'),
      _AssessField('금액·원가', '판가', decimal(unitPrice / 10000)),
      _AssessField('금액·원가', '매출액(백만원)', decimal(lead.amount / 10000)),
      _AssessField('금액·원가', '재료비(백만원)', decimal(lead.materialCost / 10000, 4)),
      _AssessField(
          '금액·원가', '재료비율', '${lead.materialRatio.toStringAsFixed(1)}%'),
      const _AssessField('금액·원가', '지급수수료(백만원)', '-'),
      const _AssessField('금액·원가', '커미션(백만원)', '-'),
      _AssessField('금액·원가', '비고', lead.dropReason ?? '-'),
      _AssessField('등급·반영', 'ITEM구분', lead.productType),
      _AssessField('등급·반영', 'BEST', grade == 'BEST' ? '○' : '-'),
      _AssessField('등급·반영', '반영등급', grade),
      _AssessField('등급·반영', 'WORST', grade == 'WORST' ? '○' : '-'),
      _AssessField('등급·반영', '수주', orderYear),
      _AssessField('등급·반영', '입고', arrivalYear),
      _AssessField('등급·반영', '조정 매출액(억원)', _money(lead.amount * 10)),
      _AssessField('등급·반영', '조정 재료비(억원)', _money(lead.materialCost * 10)),
      const _AssessField('원본 계산 보조열', 'AS (헤더 없음)', '빈 열'),
      const _AssessField('원본 계산 보조열', 'AT (헤더 없음)', '빈 열'),
      const _AssessField('원본 계산 보조열', 'AU (헤더 없음)', '100,000,000'),
    ];
  }

  Future<void> _showStageChangeDialog(_PipelineLead lead) async {
    final stage = await showDialog<int>(
      context: context,
      builder: (context) => RobinSimpleDialog(
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
              ),
            ),
        ],
      ),
    );
    if (stage != null && stage != lead.stage) await _changeStage(lead, stage);
  }

  Future<void> _changeStage(_PipelineLead lead, int nextStage) async {
    String? dropNote;
    if (nextStage == 4) {
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
          builder: (context) => RobinAlertDialog(
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
      stage: nextStage,
      erpLinked: lead.erpOrderNumber != null,
      dropReason: nextStage == 4 ? dropNote : lead.dropReason,
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
          user: robinUserProfile.value.name,
          from: _stageNames[lead.stage],
          to: _stageNames[nextStage],
          note: note,
        ),
      );
    });
    if (nextStage == 3) {
      final go = await showDialog<bool>(
        context: context,
        builder: (context) => RobinAlertDialog(
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

  _ProposalCollaborationData _proposalCollaborationFor(_PipelineLead lead) =>
      _proposalCollaborations.putIfAbsent(
        lead.number,
        () => const _ProposalCollaborationData(
          documents: [
            _ProposalDocument('고객 Spec.', '고객요구사양서.xlsx', 'Rev.01', '대리점',
                '2026-08-18 09:20', '접수'),
            _ProposalDocument('컨셉 도면', 'Layout_Concept_Rev02.pdf', 'Rev.02',
                '이설계 책임', '2026-08-19 15:10', '검토 요청'),
            _ProposalDocument('컨셉 도면', 'Layout_Concept_Rev03.pdf', 'Rev.03',
                '이설계 책임', '2026-08-21 11:30', '최종 합의'),
          ],
          comments: [
            _ProposalComment('c1', null, '박대리점', '대리점',
                '고객 요청에 따라 안전펜스 간격을 150mm 늘려주세요.', '2026-08-20 10:05'),
            _ProposalComment('c2', 'c1', '이설계 책임', '설계팀',
                'Rev.03에 반영했습니다. 간섭 여부도 함께 확인했습니다.', '2026-08-21 11:32'),
          ],
          specCopied: false,
        ),
      );

  Future<void> _showProposalCollaboration(_PipelineLead lead) async {
    final current = _proposalCollaborationFor(lead);
    final result = await showDialog<_ProposalCollaborationData>(
      context: context,
      builder: (context) => _ProposalCollaborationDialog(
        lead: lead,
        initial: current,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _proposalCollaborations[lead.number] = result;
      _selected = lead;
      _histories.insert(
        0,
        _PipelineHistory(
          number: lead.number,
          at: _now(),
          user: robinUserProfile.value.name,
          from: 'Proposal',
          to: '도면 협업 저장',
          note:
              '첨부 ${result.documents.length}건 · 댓글 ${result.comments.length}건 · ${result.specCopied ? '스펙 복사 완료' : '스펙 복사 전'}',
        ),
      );
    });
    _message('${lead.number} Proposal 협업 내용을 저장했습니다.');
  }

  Future<void> _showPriceTableAdmin() async {
    final isAdmin = robinUserProfile.value.isAdmin;
    await showDialog<void>(
      context: context,
      builder: (context) => RobinAlertDialog(
        title: const Text('단가 테이블 관리 · 구매팀장 권한'),
        content: SizedBox(
          width: 760,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isAdmin) const Text('현재 계정은 조회만 가능합니다.'),
                const Text('ROBIN 표준 단가표',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const _SimpleCostTable(),
                const SizedBox(height: 14),
                const Text('단가 변경 이력',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const ListTile(
                  dense: true,
                  leading: Icon(Icons.history, size: 18),
                  title: Text('RC-1500 · 9,500,000원 → 9,800,000원'),
                  subtitle: Text('2026-08-15 · 김구매 팀장 · 가공비 상승 반영'),
                ),
                const ListTile(
                  dense: true,
                  leading: Icon(Icons.history, size: 18),
                  title: Text('LM-1200 · 옵션 산식 개정'),
                  subtitle: Text('2026-08-12 · 이원가 책임 · 스트로크 100mm 단위 적용'),
                ),
              ],
            ),
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

class _ProposalCollaborationDialog extends StatefulWidget {
  final _PipelineLead lead;
  final _ProposalCollaborationData initial;

  const _ProposalCollaborationDialog({
    required this.lead,
    required this.initial,
  });

  @override
  State<_ProposalCollaborationDialog> createState() =>
      _ProposalCollaborationDialogState();
}

class _ProposalCollaborationDialogState
    extends State<_ProposalCollaborationDialog> {
  late final List<_ProposalDocument> _documents;
  late final List<_ProposalComment> _comments;
  late bool _specCopied;
  final _comment = TextEditingController();
  String? _replyTo;

  @override
  void initState() {
    super.initState();
    _documents = [...widget.initial.documents];
    _comments = [...widget.initial.comments];
    _specCopied = widget.initial.specCopied;
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _attachFile() async {
    final nextRevision =
        'Rev.${(_documents.length + 1).toString().padLeft(2, '0')}';
    final document = await showDialog<_ProposalDocument>(
      context: context,
      builder: (context) => _ProposalFileAttachDialog(
        nextRevision: nextRevision,
      ),
    );
    if (document == null || !mounted) return;
    setState(() => _documents.add(document));
  }

  void _postComment() {
    final message = _comment.text.trim();
    if (message.isEmpty) return;
    final profile = robinUserProfile.value;
    setState(() {
      _comments.add(
        _ProposalComment(
          'c${DateTime.now().microsecondsSinceEpoch}',
          _replyTo,
          profile.name,
          profile.isDealer ? '대리점' : '설계/영업',
          message,
          '방금',
        ),
      );
      _comment.clear();
      _replyTo = null;
    });
  }

  @override
  Widget build(BuildContext context) => Dialog(
        insetPadding: const EdgeInsets.all(22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080, maxHeight: 820),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 10, 12),
                child: Row(
                  children: [
                    const Icon(Icons.hub_outlined, color: RobinTheme.primary),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Proposal 도면·댓글 협업',
                              style: RobinTheme.headingLg),
                          Text('${widget.lead.number} · ${widget.lead.project}',
                              style: RobinTheme.bodySm),
                        ],
                      ),
                    ),
                    Chip(label: Text('첨부 ${_documents.length}')),
                    const SizedBox(width: 6),
                    Chip(label: Text('댓글 ${_comments.length}')),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('합의 스펙', style: RobinTheme.headingSm),
                          ),
                          FilledButton.tonalIcon(
                            key: const ValueKey('copy-proposal-spec'),
                            onPressed: () => setState(() => _specCopied = true),
                            icon: const Icon(Icons.content_copy, size: 17),
                            label: Text(_specCopied ? '스펙 복사 완료' : '스펙 복사 입력'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          const _InfoBox('제품 크기', '1,200 × 800 × 900 mm'),
                          const _InfoBox('이송 Capa', '350.0 kg/회'),
                          const _InfoBox('운영시간', '20 hr/일'),
                          _InfoBox('입력 상태',
                              _specCopied ? 'Negotiation 복사됨' : '복사 전'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                              child: Text('첨부·버전 이력',
                                  style: RobinTheme.headingSm)),
                          OutlinedButton.icon(
                            key: const ValueKey('attach-proposal-file'),
                            onPressed: _attachFile,
                            icon: const Icon(Icons.attach_file, size: 17),
                            label: const Text('파일 첨부'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: _cardDecoration(),
                        child: Column(
                          children: [
                            for (var index = 0;
                                index < _documents.length;
                                index++) ...[
                              ListTile(
                                dense: true,
                                leading: const Icon(
                                    Icons.insert_drive_file_outlined,
                                    color: RobinTheme.primary),
                                title: Text(_documents[index].fileName),
                                subtitle: Text(
                                    '${_documents[index].type} · ${_documents[index].revision} · ${_documents[index].uploader} · ${_documents[index].at}'),
                                trailing:
                                    Chip(label: Text(_documents[index].status)),
                              ),
                              if (index != _documents.length - 1)
                                const Divider(height: 1),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text('댓글·피드백', style: RobinTheme.headingSm),
                      const SizedBox(height: 6),
                      Container(
                        decoration: _cardDecoration(),
                        child: Column(
                          children: [
                            for (final comment in _comments) ...[
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    comment.parentId == null ? 12 : 42,
                                    10,
                                    12,
                                    8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      comment.parentId == null
                                          ? Icons.chat_bubble_outline
                                          : Icons.subdirectory_arrow_right,
                                      size: 17,
                                      color: RobinTheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              '${comment.author} · ${comment.team} · ${comment.at}',
                                              style: RobinTheme.labelXs),
                                          const SizedBox(height: 3),
                                          Text(comment.message),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          setState(() => _replyTo = comment.id),
                                      child: const Text('답글'),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                            ],
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      key: const ValueKey(
                                          'proposal-comment-input'),
                                      controller: _comment,
                                      minLines: 1,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        labelText: _replyTo == null
                                            ? '댓글 입력'
                                            : '선택한 댓글에 답글 입력',
                                        border: const OutlineInputBorder(),
                                        suffixIcon: _replyTo == null
                                            ? null
                                            : IconButton(
                                                tooltip: '답글 취소',
                                                onPressed: () => setState(
                                                    () => _replyTo = null),
                                                icon: const Icon(Icons.close),
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  IconButton.filled(
                                    key:
                                        const ValueKey('post-proposal-comment'),
                                    tooltip: '등록',
                                    onPressed: _postComment,
                                    icon: const Icon(Icons.send),
                                  ),
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
              const Divider(height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Text('대리점 ↔ 설계팀 협업 이력', style: RobinTheme.labelXs),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    const SizedBox(width: 6),
                    FilledButton(
                      key: const ValueKey('save-proposal-collaboration'),
                      onPressed: () => Navigator.pop(
                        context,
                        _ProposalCollaborationData(
                          documents: _documents,
                          comments: _comments,
                          specCopied: _specCopied,
                        ),
                      ),
                      child: const Text('협업 내용 저장'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _ProposalFileAttachDialog extends StatefulWidget {
  final String nextRevision;

  const _ProposalFileAttachDialog({required this.nextRevision});

  @override
  State<_ProposalFileAttachDialog> createState() =>
      _ProposalFileAttachDialogState();
}

class _ProposalFileAttachDialogState extends State<_ProposalFileAttachDialog> {
  final _key = GlobalKey<FormState>();
  final _fileName = TextEditingController();
  String _type = '컨셉 도면';

  @override
  void dispose() {
    _fileName.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    try {
      final file = await DesktopFileService.pickDocument(
        extensions: const ['pdf', 'xlsx', 'xls', 'dwg', 'step'],
      );
      if (file == null || !mounted) return;
      setState(() => _fileName.text = file.name);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('파일 선택 실패: $error')));
    }
  }

  @override
  Widget build(BuildContext context) => RobinAlertDialog(
        title: const Text('Proposal 파일 첨부'),
        content: SizedBox(
          width: 480,
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                      labelText: '문서 구분', border: OutlineInputBorder()),
                  items: const ['컨셉 도면', '고객 Spec.', '제안서', '검토 자료']
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) => _type = value ?? _type,
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: const ValueKey('proposal-file-name-input'),
                        controller: _fileName,
                        decoration: InputDecoration(
                          labelText: '파일명',
                          hintText:
                              '예: Layout_Concept_${widget.nextRevision}.pdf',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? '파일을 선택하거나 파일명을 입력해주세요.'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 7),
                    OutlinedButton.icon(
                      key: const ValueKey('select-proposal-file'),
                      onPressed: _selectFile,
                      icon: const Icon(Icons.folder_open_outlined, size: 16),
                      label: const Text('파일 선택'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                InputDecorator(
                  decoration: const InputDecoration(
                      labelText: '자동 버전', border: OutlineInputBorder()),
                  child: Text(widget.nextRevision),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            key: const ValueKey('confirm-proposal-file'),
            onPressed: () {
              if (!_key.currentState!.validate()) return;
              final profile = robinUserProfile.value;
              Navigator.pop(
                context,
                _ProposalDocument(
                  _type,
                  _fileName.text.trim(),
                  widget.nextRevision,
                  profile.name,
                  '방금',
                  '검토 요청',
                ),
              );
            },
            child: const Text('첨부'),
          ),
        ],
      );
}

class _SimilarModelEvidence extends StatelessWidget {
  final String group;

  const _SimilarModelEvidence({required this.group});

  @override
  Widget build(BuildContext context) {
    final rows = group == 'linear'
        ? const [
            ['LM-1200-S02', '1,000mm · 20kg', '6,780,000원', '96%'],
            ['LM-1200-S05', '1,100mm · 20kg', '7,020,000원', '93%'],
            ['LM-1600-S01', '1,200mm · 30kg', '8,310,000원', '87%'],
          ]
        : const [
            ['RC-1000-S03', '단축 · 1,000mm', '7,540,000원', '95%'],
            ['RC-1500-S02', '2축 · 1,200mm', '9,650,000원', '92%'],
            ['RC-1500-S04', '2축 · 1,300mm', '9,920,000원', '89%'],
          ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(9),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('유사 모델 단가 근거 TOP 3',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(width: 105, child: Text(row[0])),
                  Expanded(child: Text(row[1])),
                  SizedBox(width: 100, child: Text(row[2])),
                  Chip(label: Text('유사도 ${row[3]}')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ErpOrderMatchDialog extends StatefulWidget {
  final _PipelineLead lead;

  const _ErpOrderMatchDialog({required this.lead});

  @override
  State<_ErpOrderMatchDialog> createState() => _ErpOrderMatchDialogState();
}

class _ErpOrderMatchDialogState extends State<_ErpOrderMatchDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _erpNumber;

  @override
  void initState() {
    super.initState();
    _erpNumber = TextEditingController(text: widget.lead.erpOrderNumber ?? '');
  }

  @override
  void dispose() {
    _erpNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RobinAlertDialog(
        title: const Text('ERP 공식 수주번호 매칭'),
        content: SizedBox(
          width: 510,
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'ROBIN 가수주번호',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(widget.lead.number,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const ValueKey('erp-order-number-input'),
                  controller: _erpNumber,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'ERP 공식 수주번호',
                    hintText: '예: SO-2608-025',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final number = value?.trim().toUpperCase() ?? '';
                    if (number.isEmpty) return 'ERP 수주번호를 입력해주세요.';
                    if (!RegExp(r'^SO-[0-9]{4}-[0-9]{3,}$').hasMatch(number)) {
                      return 'SO-YYMM-일련번호 형식으로 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.lead.customer} · ${widget.lead.project}',
                  style: RobinTheme.bodySm,
                ),
                const SizedBox(height: 5),
                const Text('매칭 결과는 단계 변경 이력에 등록자와 함께 저장됩니다.'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton.icon(
            key: const ValueKey('confirm-erp-order-match'),
            onPressed: () {
              if (!_key.currentState!.validate()) return;
              Navigator.pop(context, _erpNumber.text.trim().toUpperCase());
            },
            icon: const Icon(Icons.link, size: 18),
            label: const Text('매칭 저장'),
          ),
        ],
      );
}

class _ExcelImportPreviewDialog extends StatelessWidget {
  const _ExcelImportPreviewDialog();

  @override
  Widget build(BuildContext context) => RobinAlertDialog(
        title: const Row(
          children: [
            Icon(Icons.upload_file_outlined, color: RobinTheme.primary),
            SizedBox(width: 9),
            Text('물동 Excel 업로드 검증'),
          ],
        ),
        content: SizedBox(
          width: 860,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: RobinTheme.surface,
                    border: Border.all(color: RobinTheme.border),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.description_outlined,
                          color: RobinTheme.signalGreen),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('수주물동관리 양식.xlsx',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            SizedBox(height: 3),
                            Text('물동 입력 · 데이터 3건 미리보기'),
                          ],
                        ),
                      ),
                      Chip(label: Text('양식 검증 완료')),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    Chip(label: Text('전체 47열')),
                    Chip(label: Text('업무 항목 44개')),
                    Chip(label: Text('계산 보조열 3개')),
                    Chip(label: Text('신규 2건')),
                    Chip(label: Text('중복 검토 1건')),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: RobinTheme.warningLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '반복 업로드의 수정·중복 판정 기준은 협의 전이므로, 현재는 기존 PJT명·거래처·수주월이 모두 같은 행을 중복 검토로 분리하고 자동 반영하지 않습니다.',
                  ),
                ),
                const SizedBox(height: 12),
                const Text('등록 미리보기',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 42,
                    dataRowMinHeight: 48,
                    dataRowMaxHeight: 60,
                    columns: const [
                      DataColumn(label: Text('판정')),
                      DataColumn(label: Text('PJT명')),
                      DataColumn(label: Text('거래처')),
                      DataColumn(label: Text('수주/입고월')),
                      DataColumn(label: Text('가수주번호')),
                    ],
                    rows: const [
                      DataRow(cells: [
                        DataCell(Chip(label: Text('신규'))),
                        DataCell(Text('2차전지 조립라인 로봇 자동화')),
                        DataCell(Text('LG에너지솔루션')),
                        DataCell(Text('2026-10 / 2026-11')),
                        DataCell(Text('등록 시 자동 채번')),
                      ]),
                      DataRow(cells: [
                        DataCell(Chip(label: Text('신규'))),
                        DataCell(Text('디스플레이 물류 이송 로봇')),
                        DataCell(Text('LG디스플레이')),
                        DataCell(Text('2026-11 / 2026-12')),
                        DataCell(Text('등록 시 자동 채번')),
                      ]),
                      DataRow(cells: [
                        DataCell(Chip(label: Text('중복 검토'))),
                        DataCell(Text('LGD 베트남 EGL 3D wafer 세정기')),
                        DataCell(Text('엘지디스플레이')),
                        DataCell(Text('2026-10 / 2026-11')),
                        DataCell(Text('기존 RB-2608-021')),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton.icon(
            key: const ValueKey('confirm-excel-import'),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.playlist_add_check, size: 18),
            label: const Text('신규 2건 등록'),
          ),
        ],
      );
}

class _PipelineRegistrationDialog extends StatefulWidget {
  final String number;
  final int initialStage;
  const _PipelineRegistrationDialog({
    required this.number,
    required this.initialStage,
  });

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
  Widget build(BuildContext context) => RobinAlertDialog(
        title: Text(
            '신규 파이프라인 · ${widget.initialStage == 1 ? 'Proposal' : 'Assess'}'),
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
                  stage: widget.initialStage,
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

class _AssessDetailDialog extends StatelessWidget {
  final _PipelineLead lead;
  final List<_AssessField> fields;

  const _AssessDetailDialog({required this.lead, required this.fields});

  @override
  Widget build(BuildContext context) {
    final sections = <String, List<_AssessField>>{};
    for (final field in fields) {
      sections.putIfAbsent(field.section, () => []).add(field);
    }
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120, maxHeight: 820),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 14, 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: RobinTheme.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.fact_check_outlined,
                        color: RobinTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assess 수주물동 전체 상세', style: RobinTheme.headingLg),
                        Text('${lead.number} · ${lead.project}',
                            style: RobinTheme.bodySm),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: RobinTheme.primary.withValues(alpha: .09),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '전체 ${fields.length}열 · 업무 44개',
                      key: const ValueKey('assess-detail-field-count'),
                      style: RobinTheme.labelXs.copyWith(
                        color: RobinTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
              child: SelectionArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: RobinTheme.warningLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '수주물동관리 양식의 A~AU 47열 순서입니다. 업무 항목은 44개이며, 원본에서 제목이 없는 AS~AU 3열은 계산 보조열로 구분했습니다.',
                            style: RobinTheme.bodySm,
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final entry in sections.entries) ...[
                          _AssessDetailSection(
                              title: entry.key, fields: entry.value),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text('읽기 전용 상세 보기', style: RobinTheme.labelXs),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check, size: 17),
                    label: const Text('확인'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessDetailSection extends StatelessWidget {
  final String title;
  final List<_AssessField> fields;

  const _AssessDetailSection({required this.title, required this.fields});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: RobinTheme.surface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: RobinTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: RobinTheme.headingSm),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 3
                    : constraints.maxWidth >= 560
                        ? 2
                        : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 8) / columns;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final field in fields)
                      Container(
                        width: width,
                        constraints: const BoxConstraints(minHeight: 66),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: RobinTheme.background,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: RobinTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(field.label, style: RobinTheme.labelXs),
                            const SizedBox(height: 4),
                            Text(field.value, style: RobinTheme.bodySm),
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
}

class _AssessField {
  final String section;
  final String label;
  final String value;

  const _AssessField(this.section, this.label, this.value);
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
  Widget build(BuildContext context) => RobinAlertDialog(
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
  final String? erpOrderNumber;
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
    this.erpOrderNumber,
    this.dropReason,
  });

  double get materialRatio => amount == 0 ? 0 : materialCost / amount * 100;

  _PipelineLead copyWith({
    String? number,
    int? stage,
    bool? erpLinked,
    String? erpOrderNumber,
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
        erpOrderNumber: erpOrderNumber ?? this.erpOrderNumber,
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

class _ProposalCollaborationData {
  final List<_ProposalDocument> documents;
  final List<_ProposalComment> comments;
  final bool specCopied;

  const _ProposalCollaborationData({
    required this.documents,
    required this.comments,
    required this.specCopied,
  });
}

class _ProposalDocument {
  final String type;
  final String fileName;
  final String revision;
  final String uploader;
  final String at;
  final String status;

  const _ProposalDocument(this.type, this.fileName, this.revision,
      this.uploader, this.at, this.status);
}

class _ProposalComment {
  final String id;
  final String? parentId;
  final String author;
  final String team;
  final String message;
  final String at;

  const _ProposalComment(
      this.id, this.parentId, this.author, this.team, this.message, this.at);
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
