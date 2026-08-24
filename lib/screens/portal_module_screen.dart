import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/access_control.dart';
import '../models/order_project.dart';
import '../theme/robin_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/notification_center.dart';
import '../widgets/user_profile.dart';
import 'pipeline_registration_screen.dart';

enum PortalModule {
  pipeline,
  orderRegistration,
  organizationApps,
  aiAssistant,
  notice,
  updateHistory,
  faq,
  integration,
  permission,
  myPage,
}

_OrderDraft? _pendingOrderDraft;

class PortalModuleScreen extends StatelessWidget {
  final PortalModule type;
  final ValueChanged<int>? onNavigate;

  const PortalModuleScreen({
    super.key,
    required this.type,
    this.onNavigate,
  });

  String get _title => switch (type) {
        PortalModule.pipeline => '파이프라인 등록',
        PortalModule.orderRegistration => '신규 수주 등록',
        PortalModule.organizationApps => 'AX Board',
        PortalModule.aiAssistant => 'AI Assistant',
        PortalModule.notice => '공지사항',
        PortalModule.updateHistory => '로그 및 이슈 조회',
        PortalModule.faq => '자주 묻는 질문',
        PortalModule.integration => '연계 모니터링',
        PortalModule.permission => '권한 관리',
        PortalModule.myPage => '마이페이지',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RobinTheme.background,
      appBar: RobinAppBar(title: _title),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: switch (type) {
          PortalModule.pipeline =>
            PipelineRegistrationView(onNavigate: onNavigate),
          PortalModule.orderRegistration =>
            _OrderRegistrationView(onNavigate: onNavigate),
          PortalModule.organizationApps => const _OrganizationAppsView(),
          PortalModule.aiAssistant => const _AssistantView(),
          PortalModule.integration => const _IntegrationView(),
          PortalModule.permission => const _PermissionView(),
          PortalModule.notice => const _SimpleListView(
              title: '공지사항',
              description: '대리점과 사내 사용자를 위한 주요 공지입니다.',
              items: ['ROBIN 베타 오픈 안내', '수주 등록 기준 변경 안내', 'ERP 정기 점검 안내'],
            ),
          PortalModule.updateHistory => const _UpdatesView(),
          PortalModule.faq => const _FaqView(),
          PortalModule.myPage => const _MyPageView(),
        },
      ),
    );
  }
}

class _PageIntro extends StatelessWidget {
  final String title;
  final String description;
  final Widget? action;

  const _PageIntro(this.title, this.description, {this.action});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RobinTheme.headingLg),
                const SizedBox(height: 5),
                Text(description, style: RobinTheme.bodySm),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      );
}

class _PipelineView extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  // Legacy prototype retained while the redesigned pipeline view is stabilized.
  // ignore: unused_element_parameter
  const _PipelineView({this.onNavigate});

  @override
  State<_PipelineView> createState() => _PipelineViewState();
}

class _PipelineViewState extends State<_PipelineView> {
  final List<_LeadData> _leads = [
    const _LeadData(
        number: 'RB-2607-001',
        projectName: 'A사 자동화라인',
        customer: 'A사',
        amount: 85000,
        owner: '김로빈 책임',
        stageIndex: 0,
        dealer: '서울 대리점',
        expectedDate: '2026-07-31'),
    const _LeadData(
        number: 'RB-2607-002',
        projectName: 'B사 로봇 증설',
        customer: 'B사',
        amount: 42000,
        owner: '이영업 선임',
        stageIndex: 0,
        dealer: '경기 대리점',
        expectedDate: '2026-08-05'),
    const _LeadData(
        number: 'RB-2607-003',
        projectName: 'C사 물류 시스템',
        customer: 'C사',
        amount: 126000,
        owner: '김로빈 책임',
        stageIndex: 1,
        dealer: '본사',
        expectedDate: '2026-08-12'),
    const _LeadData(
        number: 'RB-2607-004',
        projectName: 'D사 제어 시스템',
        customer: 'D사',
        amount: 67000,
        owner: '박영업 책임',
        stageIndex: 1,
        dealer: '부산 대리점',
        expectedDate: '2026-08-20'),
    const _LeadData(
        number: 'RB-2607-005',
        projectName: 'E사 생산라인',
        customer: 'E사',
        amount: 193000,
        owner: '이영업 선임',
        stageIndex: 2,
        dealer: '본사',
        expectedDate: '2026-09-03'),
    const _LeadData(
        number: 'RB-2607-006',
        projectName: 'F사 협동로봇',
        customer: 'F사',
        amount: 38000,
        owner: '김로빈 책임',
        stageIndex: 2,
        dealer: '대구 대리점',
        expectedDate: '2026-07-29'),
    const _LeadData(
        number: 'RB-2607-007',
        projectName: 'G사 검사장비',
        customer: 'G사',
        amount: 78000,
        owner: '박영업 책임',
        stageIndex: 3,
        dealer: '서울 대리점',
        expectedDate: '2026-07-22',
        erpLinked: true),
    const _LeadData(
        number: 'RB-2607-008',
        projectName: 'H사 물류 자동화',
        customer: 'H사',
        amount: 99000,
        owner: '이영업 선임',
        stageIndex: 3,
        dealer: '경기 대리점',
        expectedDate: '2026-07-18',
        erpLinked: true),
    const _LeadData(
        number: 'RB-2607-009',
        projectName: 'I사 로봇 교체',
        customer: 'I사',
        amount: 51000,
        owner: '김로빈 책임',
        stageIndex: 4,
        dealer: '본사',
        expectedDate: '2026-07-15',
        dropReason: '가격 경쟁력',
        dropDate: '2026-07-14',
        competitor: 'K로봇'),
  ];
  String _periodFilter = '전체 기간';
  String _customerFilter = '전체 고객사';
  String _dealerFilter = '전체 대리점';
  String _ownerFilter = '전체 담당자';
  String _progressFilter = '전체 진행';
  String _stageFilter = '전체 단계';
  final List<_StageHistory> _histories = [
    const _StageHistory(
      id: 'H-003',
      projectNo: 'RB-2607-006',
      projectName: 'D사 제어 시스템',
      changedAt: '2026-07-29 09:42',
      changedBy: '김로빈 책임',
      fromStage: 'Proposal',
      toStage: 'Negotiation',
      note: '고객사 기술 미팅 완료 후 제안 사양 확정',
    ),
    const _StageHistory(
      id: 'H-002',
      projectNo: 'RB-2607-009',
      projectName: 'C사 물류 시스템',
      changedAt: '2026-07-28 16:20',
      changedBy: '김로빈 책임',
      fromStage: 'Assess',
      toStage: 'Proposal',
      note: '제안서 작성 요청 접수',
    ),
    const _StageHistory(
      id: 'H-001',
      projectNo: 'RB-2607-014',
      projectName: 'A사 자동화라인 증설',
      changedAt: '2026-07-28 10:32',
      changedBy: '김로빈 책임',
      fromStage: 'Negotiation',
      toStage: 'Closed Won',
      note: '최종 계약 조건 협의 완료',
    ),
  ];

  static const _stageNames = [
    'Assess',
    'Proposal',
    'Negotiation',
    'Closed Won',
    'Closed Lost',
  ];

  @override
  Widget build(BuildContext context) {
    const stages = [
      ('Assess', Color(0xFF667085)),
      ('Proposal', Color(0xFF4F46E5)),
      ('Negotiation', Color(0xFFF59E0B)),
      ('Closed Won', RobinTheme.signalGreen),
      ('Closed Lost', RobinTheme.signalRed),
    ];
    final filteredLeads = _leads.where(_matchesFilters).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageIntro(
          '파이프라인 등록',
          'Assess → Proposal → Negotiation → Closed Won / Closed Lost 단계별 정보를 관리합니다.',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: _showStageWorkspace,
                icon: const Icon(Icons.dashboard_customize_outlined, size: 18),
                label: const Text('단계별 입력'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _registerLead,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('파이프라인 등록'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _PipelineFilterBar(
          period: _periodFilter,
          customer: _customerFilter,
          dealer: _dealerFilter,
          owner: _ownerFilter,
          progress: _progressFilter,
          stage: _stageFilter,
          customers: _options(_leads.map((lead) => lead.customer), '전체 고객사'),
          dealers: _options(_leads.map((lead) => lead.dealer), '전체 대리점'),
          owners: _options(_leads.map((lead) => lead.owner), '전체 담당자'),
          onPeriodChanged: (value) => setState(() => _periodFilter = value),
          onCustomerChanged: (value) => setState(() => _customerFilter = value),
          onDealerChanged: (value) => setState(() => _dealerFilter = value),
          onOwnerChanged: (value) => setState(() => _ownerFilter = value),
          onProgressChanged: (value) => setState(() => _progressFilter = value),
          onStageChanged: (value) => setState(() => _stageFilter = value),
          onReset: _resetFilters,
          resultCount: filteredLeads.length,
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 3,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final stage = stages[index];
              final stageLeads = filteredLeads
                  .where((lead) => lead.stageIndex == index)
                  .toList();
              final count = stageLeads.length;
              final amount =
                  stageLeads.fold<double>(0, (sum, lead) => sum + lead.amount);
              return SizedBox(
                width: 220,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 11),
                      decoration: BoxDecoration(
                        color: RobinTheme.surface,
                        borderRadius: BorderRadius.circular(9),
                        border:
                            Border(top: BorderSide(color: stage.$2, width: 3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                                child: Text(stage.$1,
                                    style: RobinTheme.headingSm)),
                            _badge('$count', stage.$2),
                          ]),
                          const SizedBox(height: 5),
                          Text(
                            '매출 ${amount.toStringAsFixed(0)}만원 · 주문변경 ${count ~/ 2} · 사양변경 ${count == 0 ? 0 : count}',
                            style: RobinTheme.labelXs,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    Expanded(
                      child: ListView(
                        children: [
                          ...stageLeads.map((lead) => _dealCard(
                                lead.number,
                                lead.projectName,
                                stage.$2,
                                amount: lead.amount,
                                owner: lead.owner,
                                customer: lead.customer,
                                statusNote: lead.erpLinked
                                    ? 'ERP 연계 완료 · 수주 등록 연계'
                                    : lead.dropReason != null
                                        ? 'Drop: ${lead.dropReason} · 경쟁사: ${lead.competitor}'
                                        : null,
                                onTap: () => _changeLeadStage(lead),
                              )),
                          if (stageLeads.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Center(
                                child:
                                    Text('조회 결과 없음', style: RobinTheme.labelXs),
                              ),
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
        const SizedBox(height: 14),
        SizedBox(
          height: 235,
          child: _StageHistoryBoard(
            histories: _histories,
            onEditNote: _editHistoryNote,
          ),
        ),
      ],
    );
  }

  Future<void> _registerLead() async {
    final result = await showDialog<_LeadData>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _LeadRegistrationDialog(
        number: 'RB-2607-${(_leads.length + 1).toString().padLeft(3, '0')}',
      ),
    );

    if (result == null || !mounted) return;
    setState(() => _leads.insert(0, result));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${result.number} Lead가 등록되었습니다.')),
    );
  }

  Future<void> _showStageWorkspace() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => DefaultTabController(
        length: 3,
        child: AlertDialog(
          title: const Text('파이프라인 단계별 입력'),
          content: const SizedBox(
            width: 900,
            height: 530,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'Assess · 물동'),
                    Tab(text: 'Proposal · 컨셉설계'),
                    Tab(text: 'Negotiation · 원가/결재'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _AssessWorkspace(),
                      _ProposalWorkspace(),
                      _NegotiationWorkspace(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('단계 정보 저장'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeLeadStage(_LeadData lead) async {
    final selectedStage = await showDialog<int>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text('${lead.number} 단계 변경'),
        children: [
          for (var index = 0; index < _stageNames.length; index++)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, index),
              child: Row(
                children: [
                  Icon(
                    index == lead.stageIndex
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: index == lead.stageIndex
                        ? RobinTheme.primary
                        : RobinTheme.textMuted,
                  ),
                  const SizedBox(width: 10),
                  Text(_stageNames[index]),
                ],
              ),
            ),
        ],
      ),
    );

    if (selectedStage == null || selectedStage == lead.stageIndex || !mounted) {
      return;
    }
    if (selectedStage == 3) {
      await _processSuccess(lead);
      return;
    }
    if (selectedStage == 4) {
      await _processDrop(lead);
      return;
    }

    final note = await showDialog<String>(
      context: context,
      builder: (_) => const _HistoryNoteDialog(
        title: '단계 변경 비고',
        hint: '단계 변경 사유나 특이사항을 입력하세요.',
      ),
    );
    if (note == null || !mounted) return;

    _replaceLead(lead, lead.moveTo(selectedStage));
    _addHistory(lead, selectedStage, note);
    _showStageChanged(lead.number, _stageNames[selectedStage]);
  }

  Future<void> _processSuccess(_LeadData lead) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('수주 성공 처리'),
        content: SizedBox(
          width: 470,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${lead.number} · ${lead.projectName}',
                  style: RobinTheme.headingSm),
              const SizedBox(height: 14),
              const _ProcessRow(
                icon: Icons.cloud_upload_outlined,
                title: 'ERP 연계',
                description: '확정 수주정보를 ERP로 실시간 전송합니다.',
              ),
              const SizedBox(height: 10),
              const _ProcessRow(
                icon: Icons.post_add_outlined,
                title: '수주관리 연계',
                description:
                    'Closed Won 처리 후 수주관리에서 ROBIN 제안가와 ERP 확정 정보를 확인합니다.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('수주 성공 확정'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    _pendingOrderDraft = _OrderDraft.fromLead(lead);
    _replaceLead(lead, lead.markSuccess());
    _addHistory(lead, 3, 'ERP 연계 완료 · 수주관리 연계');
    final goToOrderRegistration = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: RobinTheme.signalGreen),
            SizedBox(width: 9),
            Text('수주 성공 처리 완료'),
          ],
        ),
        content: SizedBox(
          width: 470,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${lead.number} 수주가 성공 처리되었습니다.', style: RobinTheme.bodyMd),
              const SizedBox(height: 14),
              const _ResultRow(label: 'ERP 연계', value: '전송 완료'),
              const _ResultRow(label: '수주관리', value: 'ROBIN/ERP 확정 정보 확인'),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('파이프라인에 머물기'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.arrow_forward, size: 17),
            label: const Text('수주관리로 이동'),
          ),
        ],
      ),
    );
    if (goToOrderRegistration == true && mounted) {
      widget.onNavigate?.call(2);
    }
  }

  Future<void> _processDrop(_LeadData lead) async {
    final dropData = await showDialog<_DropData>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DropRegistrationDialog(lead: lead),
    );
    if (dropData == null || !mounted) return;

    _replaceLead(lead, lead.markDropped(dropData));
    _addHistory(
      lead,
      4,
      'Drop 사유: ${dropData.reason} · 경쟁사: ${dropData.competitor}',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${lead.number} 수주 실패 정보가 저장되었습니다.')),
    );
  }

  void _replaceLead(_LeadData previous, _LeadData updated) {
    setState(() {
      final index = _leads.indexOf(previous);
      _leads[index] = updated;
    });
  }

  void _addHistory(_LeadData lead, int nextStage, String note) {
    setState(() {
      _histories.insert(
        0,
        _StageHistory(
          id: 'H-${(_histories.length + 1).toString().padLeft(3, '0')}',
          projectNo: lead.number,
          projectName: lead.projectName,
          changedAt: _formatNow(),
          changedBy: '김로빈 책임',
          fromStage: _stageNames[lead.stageIndex],
          toStage: _stageNames[nextStage],
          note: note,
        ),
      );
    });
  }

  Future<void> _editHistoryNote(_StageHistory history) async {
    final note = await showDialog<String>(
      context: context,
      builder: (_) => _HistoryNoteDialog(
        title: '변경 이력 비고 수정',
        hint: '특이사항을 입력하세요.',
        initialValue: history.note,
      ),
    );
    if (note == null || !mounted) return;
    setState(() {
      final index = _histories.indexOf(history);
      _histories[index] = history.copyWith(note: note);
    });
  }

  String _formatNow() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)} '
        '${two(now.hour)}:${two(now.minute)}';
  }

  bool _matchesFilters(_LeadData lead) {
    if (_customerFilter != '전체 고객사' && lead.customer != _customerFilter) {
      return false;
    }
    if (_dealerFilter != '전체 대리점' && lead.dealer != _dealerFilter) {
      return false;
    }
    if (_ownerFilter != '전체 담당자' && lead.owner != _ownerFilter) {
      return false;
    }
    if (_progressFilter == '진행 중' && lead.stageIndex >= 3) return false;
    if (_progressFilter == '종료' && lead.stageIndex < 3) return false;
    if (_stageFilter != '전체 단계' &&
        _stageNames[lead.stageIndex] != _stageFilter) {
      return false;
    }
    if (_periodFilter == '2026년 7월' &&
        !lead.expectedDate.startsWith('2026-07')) {
      return false;
    }
    if (_periodFilter == '2026년 8월' &&
        !lead.expectedDate.startsWith('2026-08')) {
      return false;
    }
    if (_periodFilter == '2026년 3분기') {
      final month = DateTime.parse(lead.expectedDate).month;
      if (month < 7 || month > 9) return false;
    }
    return true;
  }

  List<String> _options(Iterable<String> source, String allLabel) {
    final values = source.toSet().toList()..sort();
    return [allLabel, ...values];
  }

  void _resetFilters() {
    setState(() {
      _periodFilter = '전체 기간';
      _customerFilter = '전체 고객사';
      _dealerFilter = '전체 대리점';
      _ownerFilter = '전체 담당자';
      _progressFilter = '전체 진행';
      _stageFilter = '전체 단계';
    });
  }

  void _showStageChanged(String number, String stageName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$number 단계가 $stageName(으)로 변경되었습니다.')),
    );
  }

  static Widget _dealCard(
    String number,
    String title,
    Color color, {
    double amount = 850,
    String owner = '김로빈 책임',
    String? customer,
    String? statusNote,
    VoidCallback? onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: RobinTheme.surface,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: RobinTheme.border),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(number,
                    style: RobinTheme.labelXs.copyWith(color: color)),
              ),
              if (onTap != null)
                const Icon(Icons.swap_horiz,
                    size: 16, color: RobinTheme.textMuted),
            ]),
            const SizedBox(height: 7),
            Text(title, style: RobinTheme.headingSm),
            if (customer != null) ...[
              const SizedBox(height: 4),
              Text(customer, style: RobinTheme.labelXs),
            ],
            const SizedBox(height: 10),
            Text('예상금액  ${amount.toStringAsFixed(0)}만원',
                style: RobinTheme.bodySm),
            if (statusNote != null) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(statusNote,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: RobinTheme.labelXs.copyWith(color: color)),
              ),
            ],
            const SizedBox(height: 5),
            Row(children: [
              const CircleAvatar(
                  radius: 8, child: Text('김', style: TextStyle(fontSize: 8))),
              const SizedBox(width: 5),
              Text(owner, style: RobinTheme.labelXs),
            ]),
          ]),
        ),
      );
}

class _StageHistoryBoard extends StatelessWidget {
  final List<_StageHistory> histories;
  final ValueChanged<_StageHistory> onEditNote;

  const _StageHistoryBoard({
    required this.histories,
    required this.onEditNote,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 11, 12, 9),
              child: Row(
                children: [
                  const Icon(Icons.history,
                      size: 18, color: RobinTheme.primary),
                  const SizedBox(width: 7),
                  Text('단계 변경 이력', style: RobinTheme.headingSm),
                  const SizedBox(width: 8),
                  _badge('${histories.length}', RobinTheme.primary),
                  const Spacer(),
                  Text('프로젝트 · 변경시각 · 변경자 · 비고', style: RobinTheme.labelXs),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: histories.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 15, endIndent: 15),
                itemBuilder: (context, index) {
                  final history = histories[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 205,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(history.projectNo,
                                  style: RobinTheme.labelXs.copyWith(
                                      color: RobinTheme.primary,
                                      fontWeight: FontWeight.w700)),
                              Text(history.projectName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: RobinTheme.bodySm
                                      .copyWith(color: RobinTheme.textPrimary)),
                            ],
                          ),
                        ),
                        SizedBox(
                            width: 125,
                            child: Text(history.changedAt,
                                style: RobinTheme.labelXs)),
                        SizedBox(
                            width: 95,
                            child: Text(history.changedBy,
                                style: RobinTheme.bodySm)),
                        SizedBox(
                          width: 180,
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(history.fromStage,
                                    overflow: TextOverflow.ellipsis,
                                    style: RobinTheme.labelXs),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Icon(Icons.arrow_forward,
                                    size: 13, color: RobinTheme.textMuted),
                              ),
                              Flexible(
                                child: Text(history.toStage,
                                    overflow: TextOverflow.ellipsis,
                                    style: RobinTheme.labelXs.copyWith(
                                        color: RobinTheme.primary,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            history.note.isEmpty ? '비고 없음' : history.note,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: RobinTheme.bodySm.copyWith(
                              color: history.note.isEmpty
                                  ? RobinTheme.textMuted
                                  : RobinTheme.textSecondary,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: '비고 수정',
                          onPressed: () => onEditNote(history),
                          icon: const Icon(Icons.edit_note_outlined, size: 19),
                          color: RobinTheme.textSecondary,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
}

class _HistoryNoteDialog extends StatefulWidget {
  final String title;
  final String hint;
  final String initialValue;

  const _HistoryNoteDialog({
    required this.title,
    required this.hint,
    this.initialValue = '',
  });

  @override
  State<_HistoryNoteDialog> createState() => _HistoryNoteDialogState();
}

class _HistoryNoteDialogState extends State<_HistoryNoteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: SizedBox(
          width: 470,
          child: TextField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: widget.hint,
              border: const OutlineInputBorder(),
              helperText: '비고는 추후 변경 이력 게시판에서 수정할 수 있습니다.',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _controller.text.trim()),
            child: const Text('저장'),
          ),
        ],
      );
}

class _StageHistory {
  final String id;
  final String projectNo;
  final String projectName;
  final String changedAt;
  final String changedBy;
  final String fromStage;
  final String toStage;
  final String note;

  const _StageHistory({
    required this.id,
    required this.projectNo,
    required this.projectName,
    required this.changedAt,
    required this.changedBy,
    required this.fromStage,
    required this.toStage,
    required this.note,
  });

  _StageHistory copyWith({String? note}) => _StageHistory(
        id: id,
        projectNo: projectNo,
        projectName: projectName,
        changedAt: changedAt,
        changedBy: changedBy,
        fromStage: fromStage,
        toStage: toStage,
        note: note ?? this.note,
      );
}

class _ProcessRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ProcessRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: RobinTheme.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 21, color: RobinTheme.primary),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: RobinTheme.headingSm),
                  const SizedBox(height: 3),
                  Text(description, style: RobinTheme.bodySm),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(width: 100, child: Text(label, style: RobinTheme.labelXs)),
            const Icon(Icons.check_circle,
                size: 16, color: RobinTheme.signalGreen),
            const SizedBox(width: 6),
            Text(value, style: RobinTheme.bodySm),
          ],
        ),
      );
}

class _DropRegistrationDialog extends StatefulWidget {
  final _LeadData lead;

  const _DropRegistrationDialog({required this.lead});

  @override
  State<_DropRegistrationDialog> createState() =>
      _DropRegistrationDialogState();
}

class _DropRegistrationDialogState extends State<_DropRegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _competitorController = TextEditingController();
  final _productController = TextEditingController();
  final _amountController = TextEditingController();
  String? _reason;

  static const _reasons = [
    '가격 경쟁력',
    '납기 조건',
    '사양 미충족',
    '경쟁사 선정',
    '고객 투자 취소',
    '기타',
  ];

  @override
  void dispose() {
    _competitorController.dispose();
    _productController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('수주 실패 정보 입력'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.lead.number} · ${widget.lead.projectName}',
                      style: RobinTheme.headingSm),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _reason,
                    decoration: const InputDecoration(
                      labelText: 'Drop 사유',
                      border: OutlineInputBorder(),
                    ),
                    items: _reasons
                        .map((reason) => DropdownMenuItem(
                              value: reason,
                              child: Text(reason),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _reason = value),
                    validator: (value) =>
                        value == null ? 'Drop 사유를 선택해주세요.' : null,
                  ),
                  const SizedBox(height: 13),
                  const _ReadOnlyLeadField(
                      label: 'Drop 일자', value: '2026-07-29'),
                  const SizedBox(height: 13),
                  TextFormField(
                    controller: _competitorController,
                    decoration: const InputDecoration(
                      labelText: '경쟁사',
                      hintText: '경쟁사명을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? '경쟁사 정보를 입력해주세요.'
                        : null,
                  ),
                  const SizedBox(height: 13),
                  TextFormField(
                    controller: _productController,
                    decoration: const InputDecoration(
                      labelText: '경쟁 제품/사양',
                      hintText: '선택된 경쟁 제품 또는 사양',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '경쟁 금액 (만원)',
                      hintText: '예: 78000',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isNotEmpty && double.tryParse(text) == null) {
                        return '숫자로 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: _submit,
            style:
                FilledButton.styleFrom(backgroundColor: RobinTheme.signalRed),
            child: const Text('수주 실패 저장'),
          ),
        ],
      );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _DropData(
        reason: _reason!,
        date: '2026-07-29',
        competitor: _competitorController.text.trim(),
        competitorProduct: _productController.text.trim(),
        competitorAmount: double.tryParse(_amountController.text.trim()),
      ),
    );
  }
}

class _DropData {
  final String reason;
  final String date;
  final String competitor;
  final String competitorProduct;
  final double? competitorAmount;

  const _DropData({
    required this.reason,
    required this.date,
    required this.competitor,
    required this.competitorProduct,
    this.competitorAmount,
  });
}

class _LeadRegistrationDialog extends StatefulWidget {
  final String number;

  const _LeadRegistrationDialog({required this.number});

  @override
  State<_LeadRegistrationDialog> createState() =>
      _LeadRegistrationDialogState();
}

class _LeadRegistrationDialogState extends State<_LeadRegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _projectController = TextEditingController();
  final _customerController = TextEditingController();
  final _amountController = TextEditingController();
  final _ownerController = TextEditingController(text: '김로빈 책임');

  @override
  void dispose() {
    _projectController.dispose();
    _customerController.dispose();
    _amountController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('파이프라인 등록'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(
                  controller: _projectController,
                  label: '프로젝트명',
                  hint: '예: A사 자동화라인 증설',
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _customerController,
                  label: '고객사',
                  hint: '고객사명을 입력하세요',
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _amountController,
                  label: '예상 수주금액 (만원)',
                  hint: '예: 85000',
                  number: true,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _ownerController,
                  label: '담당자',
                  hint: '담당자명을 입력하세요',
                ),
                const SizedBox(height: 14),
                const _ReadOnlyLeadField(
                  label: '현재 단계',
                  value: 'Assess',
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('등록'),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool number = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return '$label 항목을 입력해주세요.';
        if (number && (double.tryParse(text) ?? 0) <= 0) {
          return '0보다 큰 숫자를 입력해주세요.';
        }
        return null;
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _LeadData(
        number: widget.number,
        projectName: _projectController.text.trim(),
        customer: _customerController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        owner: _ownerController.text.trim(),
        stageIndex: 0,
      ),
    );
  }
}

class _ReadOnlyLeadField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyLeadField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: RobinTheme.background,
        ),
        child: Text(value, style: RobinTheme.bodyMd),
      );
}

class _AssessWorkspace extends StatelessWidget {
  const _AssessWorkspace();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('물동 관리', style: RobinTheme.headingSm),
            const SizedBox(height: 4),
            Text('ERP 고객사·대리점 정보와 물동 Excel을 연결해 예상 수요를 등록합니다.',
                style: RobinTheme.bodySm),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(child: _StageInput(label: '고객사', hint: 'ERP 고객사 검색')),
                SizedBox(width: 10),
                Expanded(
                    child: _StageInput(label: '대리점/직판', hint: 'ERP 거래처 검색')),
                SizedBox(width: 10),
                Expanded(child: _StageInput(label: '담당자', hint: '영업 담당자')),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: RobinTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: RobinTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.table_view_outlined,
                      color: RobinTheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('물동 Excel 업로드'),
                        Text('월별 모델·수량·예상 발주시점 데이터', style: RobinTheme.labelXs),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('물동 Excel 파일 선택을 준비했습니다.')),
                    ),
                    child: const Text('파일 선택'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _StageMiniTable(
              headers: ['모델', '1Q', '2Q', '3Q', '4Q', '연간 물동', '변경률'],
              rows: [
                ['RSN-080', '4', '6', '8', '7', '25', '+12%'],
                ['RBN-CTRL', '2', '3', '5', '5', '15', '+5%'],
                ['AGV-500', '0', '2', '4', '6', '12', '신규'],
              ],
            ),
          ],
        ),
      );
}

class _ProposalWorkspace extends StatelessWidget {
  const _ProposalWorkspace();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
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
                      Text('컨셉설계 및 제안', style: RobinTheme.headingSm),
                      Text(
                          'SmartOrder 연계 정보보다 상세한 고객 요구사항과 컨셉 도면 Spec.을 입력합니다.',
                          style: RobinTheme.bodySm),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.sync, size: 16),
                    label: const Text('SmartOrder 불러오기')),
              ],
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(
                    child: _StageInput(label: '공정/적용처', hint: '자동화 대상 공정')),
                SizedBox(width: 10),
                Expanded(
                    child: _StageInput(label: 'Cycle Time', hint: '예: 45 sec')),
                SizedBox(width: 10),
                Expanded(child: _StageInput(label: '설치 환경', hint: '온도·분진·공간')),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Expanded(child: _StageInput(label: '로봇 모델', hint: '컨셉 모델')),
                SizedBox(width: 10),
                Expanded(
                    child: _StageInput(
                        label: '가반하중/Reach', hint: '80kg / 2,100mm')),
                SizedBox(width: 10),
                Expanded(child: _StageInput(label: '안전/옵션', hint: '펜스·센서·비전')),
              ],
            ),
            const SizedBox(height: 12),
            const _FileRows(
              rows: [
                ['컨셉 배치도', 'A사_LINE_CONCEPT_Rev03.dwg', 'PDM 연계'],
                ['제안서', 'A사_자동화라인_제안서_v2.pdf', '업로드 완료'],
                ['고객 요구사항', 'URS_2608_014.xlsx', '변경 3건'],
              ],
            ),
          ],
        ),
      );
}

class _NegotiationWorkspace extends StatelessWidget {
  const _NegotiationWorkspace();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
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
                      Text('상세 Spec. · 가격 · 결재', style: RobinTheme.headingSm),
                      Text('Proposal 도면 Spec.을 불러와 상세 원가와 판가를 확정합니다.',
                          style: RobinTheme.bodySm),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: const Text('Proposal Spec. 불러오기')),
              ],
            ),
            const SizedBox(height: 12),
            const _StageMiniTable(
              headers: ['구분', '입력 기준', '금액', '근거'],
              rows: [
                ['가공품', '과거 유사 실적가', '31,200만원', '유사 프로젝트 3건'],
                ['기성품', '표준단가+옵션', '42,500만원', '홀 수·길이 반영'],
                ['외주/기타', '구매견적', '8,400만원', '증빙 첨부'],
                ['수주 제안가', 'Negotiation 판가', '98,000만원', '재료비율 83.8%'],
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RobinTheme.signalRed.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: RobinTheme.signalRed),
                  SizedBox(width: 9),
                  Expanded(child: Text('재료비율 83.8% · 사업부장 추가 결재 대상')),
                  Text('기안자 → 영업팀장 → 사업부장',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _StageInput extends StatelessWidget {
  final String label;
  final String hint;
  const _StageInput({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) => TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      );
}

class _StageMiniTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  const _StageMiniTable({required this.headers, required this.rows});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowHeight: 38,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 42,
          columns:
              headers.map((item) => DataColumn(label: Text(item))).toList(),
          rows: rows
              .map((row) => DataRow(
                  cells: row.map((item) => DataCell(Text(item))).toList()))
              .toList(),
        ),
      );
}

class _FileRows extends StatelessWidget {
  final List<List<String>> rows;
  const _FileRows({required this.rows});

  @override
  Widget build(BuildContext context) => Column(
        children: rows
            .map((row) => ListTile(
                  leading: const Icon(Icons.insert_drive_file_outlined,
                      color: RobinTheme.primary),
                  title: Text(row[0]),
                  subtitle: Text(row[1]),
                  trailing: Text(row[2], style: RobinTheme.labelXs),
                ))
            .toList(),
      );
}

class _LeadData {
  final String number;
  final String projectName;
  final String customer;
  final double amount;
  final String owner;
  final int stageIndex;
  final String dealer;
  final String expectedDate;
  final bool erpLinked;
  final String? dropReason;
  final String? dropDate;
  final String? competitor;
  final String? competitorProduct;
  final double? competitorAmount;

  const _LeadData({
    required this.number,
    required this.projectName,
    required this.customer,
    required this.amount,
    required this.owner,
    required this.stageIndex,
    this.dealer = '본사',
    this.expectedDate = '2026-08-31',
    this.erpLinked = false,
    this.dropReason,
    this.dropDate,
    this.competitor,
    this.competitorProduct,
    this.competitorAmount,
  });

  _LeadData moveTo(int nextStageIndex) => _LeadData(
        number: number,
        projectName: projectName,
        customer: customer,
        amount: amount,
        owner: owner,
        stageIndex: nextStageIndex,
        dealer: dealer,
        expectedDate: expectedDate,
      );

  _LeadData markSuccess() => _LeadData(
        number: number,
        projectName: projectName,
        customer: customer,
        amount: amount,
        owner: owner,
        stageIndex: 3,
        dealer: dealer,
        expectedDate: expectedDate,
        erpLinked: true,
      );

  _LeadData markDropped(_DropData drop) => _LeadData(
        number: number,
        projectName: projectName,
        customer: customer,
        amount: amount,
        owner: owner,
        stageIndex: 4,
        dealer: dealer,
        expectedDate: expectedDate,
        dropReason: drop.reason,
        dropDate: drop.date,
        competitor: drop.competitor,
        competitorProduct: drop.competitorProduct,
        competitorAmount: drop.competitorAmount,
      );
}

class _OrderRegistrationView extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const _OrderRegistrationView({this.onNavigate});

  @override
  State<_OrderRegistrationView> createState() => _OrderRegistrationViewState();
}

class _OrderRegistrationViewState extends State<_OrderRegistrationView> {
  static const _steps = ['기본정보', '제품·사양', '일정·납기', '검토·제출'];
  final _basicFormKey = GlobalKey<FormState>();
  final _productFormKey = GlobalKey<FormState>();
  final _scheduleFormKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _confirmed = false;

  late final TextEditingController _numberController;
  late final TextEditingController _projectController;
  late final TextEditingController _customerController;
  late final TextEditingController _ownerController;
  late final TextEditingController _amountController;
  final _businessController = TextEditingController(text: '로봇사업부');
  final _modelController = TextEditingController();
  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _optionController = TextEditingController();
  final _specController = TextEditingController();
  final _contractDateController = TextEditingController(text: '2026-07-29');
  final _dueDateController = TextEditingController();
  final _designDateController = TextEditingController();
  final _purchaseDateController = TextEditingController();
  final _productionDateController = TextEditingController();
  final _shippingDateController = TextEditingController();
  final List<_SelectedProduct> _products = [];
  final List<String> _attachments = [];

  @override
  void initState() {
    super.initState();
    final draft = _pendingOrderDraft;
    _numberController = TextEditingController(text: draft?.number ?? '');
    _projectController = TextEditingController(text: draft?.projectName ?? '');
    _customerController = TextEditingController(text: draft?.customer ?? '');
    _ownerController = TextEditingController(text: draft?.owner ?? '');
    _amountController =
        TextEditingController(text: draft?.amount.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    for (final controller in [
      _numberController,
      _projectController,
      _customerController,
      _ownerController,
      _amountController,
      _businessController,
      _modelController,
      _productNameController,
      _quantityController,
      _optionController,
      _specController,
      _contractDateController,
      _dueDateController,
      _designDateController,
      _purchaseDateController,
      _productionDateController,
      _shippingDateController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _PageIntro(
            '신규 수주 등록', '수주정보는 ROBIN에서 최초 생성되며 확정 시 ERP로 실시간 전송됩니다.'),
        const SizedBox(height: 18),
        _stepHeader(),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: _cardDecoration(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: KeyedSubtree(
              key: ValueKey(_currentStep),
              child: _buildStepContent(),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _navigationButtons(),
      ]),
    );
  }

  Widget _stepHeader() => Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            for (var index = 0; index < _steps.length; index++) ...[
              InkWell(
                onTap: () => setState(() => _currentStep = index),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: index <= _currentStep
                          ? RobinTheme.primary
                          : RobinTheme.divider,
                      child: index < _currentStep
                          ? const Icon(Icons.check,
                              size: 15, color: Colors.white)
                          : Text('${index + 1}',
                              style: TextStyle(
                                  color: index == _currentStep
                                      ? Colors.white
                                      : RobinTheme.textMuted,
                                  fontSize: 11)),
                    ),
                    const SizedBox(width: 7),
                    Text(_steps[index],
                        style: RobinTheme.bodySm.copyWith(
                            color: index == _currentStep
                                ? RobinTheme.primary
                                : null,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
              if (index < _steps.length - 1)
                const Expanded(child: Divider(indent: 10, endIndent: 10)),
            ],
          ],
        ),
      );

  Widget _buildStepContent() => switch (_currentStep) {
        0 => _basicStep(),
        1 => _productStep(),
        2 => _scheduleStep(),
        _ => _reviewStep(),
      };

  Widget _basicStep() => Form(
        key: _basicFormKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle('기본 정보', '수주와 고객의 기본 정보를 입력합니다.'),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
                child: _RegistrationField(
                    controller: _numberController,
                    label: 'ROBIN 수주번호',
                    hint: '확정 시 자동 생성',
                    readOnly: _numberController.text.isNotEmpty,
                    required: false)),
            const SizedBox(width: 16),
            Expanded(
                child: _RegistrationField(
                    controller: _businessController,
                    label: '사업조직',
                    hint: '',
                    readOnly: true,
                    required: false)),
          ]),
          const SizedBox(height: 15),
          Row(children: [
            Expanded(
                child: _RegistrationField(
                    controller: _projectController,
                    label: '프로젝트명',
                    hint: '프로젝트명을 입력하세요')),
            const SizedBox(width: 16),
            Expanded(
                child: _RegistrationField(
                    controller: _customerController,
                    label: '고객사',
                    hint: '고객사를 입력하세요')),
          ]),
          const SizedBox(height: 15),
          Row(children: [
            Expanded(
                child: _RegistrationField(
                    controller: _ownerController,
                    label: '대리점 영업담당자',
                    hint: '담당자를 입력하세요')),
            const SizedBox(width: 16),
            Expanded(
                child: _RegistrationField(
                    controller: _amountController,
                    label: '예상 수주금액 (만원)',
                    hint: '금액을 입력하세요',
                    number: true)),
          ]),
        ]),
      );

  Widget _productStep() => Form(
        key: _productFormKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle('제품·사양', '수주 대상 제품과 옵션 및 상세 사양을 등록합니다.'),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
                child: _RegistrationField(
                    controller: _modelController,
                    label: '제품 모델',
                    hint: '예: RSN-080')),
            const SizedBox(width: 16),
            Expanded(
                child: _RegistrationField(
                    controller: _productNameController,
                    label: '제품명',
                    hint: '제품명을 입력하세요')),
            const SizedBox(width: 16),
            SizedBox(
                width: 150,
                child: _RegistrationField(
                    controller: _quantityController,
                    label: '수량',
                    hint: '1',
                    number: true)),
          ]),
          const SizedBox(height: 15),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
                child: _RegistrationField(
                    controller: _optionController,
                    label: '옵션',
                    hint: '선택 옵션을 입력하세요',
                    required: false)),
            const SizedBox(width: 16),
            Expanded(
                child: _RegistrationField(
                    controller: _specController,
                    label: '상세 사양',
                    hint: '고객 요청 사양을 입력하세요',
                    required: false)),
            const SizedBox(width: 16),
            FilledButton.icon(
                onPressed: _addProduct,
                icon: const Icon(Icons.add, size: 17),
                label: const Text('제품 추가')),
          ]),
          const SizedBox(height: 20),
          Text('선택 제품 목록', style: RobinTheme.headingSm),
          const SizedBox(height: 9),
          if (_products.isEmpty)
            _emptyBox('등록된 제품이 없습니다. 제품 정보를 입력한 뒤 추가해주세요.')
          else
            ..._products.asMap().entries.map((entry) {
              final product = entry.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                    backgroundColor: RobinTheme.accentLight,
                    child: Icon(Icons.precision_manufacturing_outlined,
                        color: RobinTheme.primary, size: 19)),
                title: Text('${product.model} · ${product.name}',
                    style: RobinTheme.headingSm),
                subtitle: Text(
                    '수량 ${product.quantity} · ${product.option.isEmpty ? '옵션 없음' : product.option} · ${product.spec.isEmpty ? '기본 사양' : product.spec}',
                    style: RobinTheme.bodySm),
                trailing: IconButton(
                    onPressed: () =>
                        setState(() => _products.removeAt(entry.key)),
                    icon: const Icon(Icons.delete_outline, size: 19)),
              );
            }),
        ]),
      );

  Widget _scheduleStep() => Form(
        key: _scheduleFormKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle('일정·납기', '납기 정보와 단계별 예상 일정을 입력합니다.'),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
                child: _RegistrationField(
                    controller: _contractDateController,
                    label: '계약일',
                    hint: 'YYYY-MM-DD')),
            const SizedBox(width: 16),
            Expanded(
                child: _RegistrationField(
                    controller: _dueDateController,
                    label: '납기예정일',
                    hint: 'YYYY-MM-DD')),
          ]),
          const SizedBox(height: 20),
          Text('단계별 예상 일정', style: RobinTheme.headingSm),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _scheduleField('설계 완료', _designDateController)),
            const SizedBox(width: 12),
            Expanded(child: _scheduleField('구매 완료', _purchaseDateController)),
            const SizedBox(width: 12),
            Expanded(child: _scheduleField('생산 완료', _productionDateController)),
            const SizedBox(width: 12),
            Expanded(child: _scheduleField('출하 예정', _shippingDateController)),
          ]),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: RobinTheme.warningLight,
                borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.info_outline,
                  size: 18, color: RobinTheme.signalYellow),
              const SizedBox(width: 9),
              Expanded(
                  child: Text('입력한 일정은 프로젝트 단계별 신호등 판정 기준에 반영됩니다.',
                      style: RobinTheme.bodySm)),
            ]),
          ),
        ]),
      );

  Widget _reviewStep() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('검토·제출', '입력 내용을 확인하고 관련 문서를 첨부한 뒤 제출합니다.'),
          const SizedBox(height: 18),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: _reviewCard('기본정보', [
              '수주번호: ${_numberController.text.isEmpty ? '확정 시 자동 생성' : _numberController.text}',
              '프로젝트: ${_projectController.text}',
              '고객사: ${_customerController.text}',
              '금액: ${_amountController.text}만원',
            ])),
            const SizedBox(width: 12),
            Expanded(
                child: _reviewCard('제품·사양', [
              '등록 제품: ${_products.length}건',
              ..._products.map((p) => '${p.model} ${p.name} · ${p.quantity}대'),
            ])),
            const SizedBox(width: 12),
            Expanded(
                child: _reviewCard('일정·납기', [
              '계약일: ${_contractDateController.text}',
              '납기예정일: ${_dueDateController.text}',
              '출하예정일: ${_shippingDateController.text}',
            ])),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Text('첨부파일', style: RobinTheme.headingSm),
            const Spacer(),
            OutlinedButton.icon(
                onPressed: _addAttachment,
                icon: const Icon(Icons.attach_file, size: 17),
                label: const Text('파일 추가')),
          ]),
          const SizedBox(height: 8),
          if (_attachments.isEmpty)
            _emptyBox('견적서, 계약서, 고객 요청사항 등의 파일을 첨부할 수 있습니다.')
          else
            Wrap(
                spacing: 8,
                children: _attachments
                    .map((file) => Chip(
                        avatar:
                            const Icon(Icons.description_outlined, size: 16),
                        label: Text(file),
                        onDeleted: () =>
                            setState(() => _attachments.remove(file))))
                    .toList()),
          const SizedBox(height: 14),
          CheckboxListTile(
            value: _confirmed,
            onChanged: (value) => setState(() => _confirmed = value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text('입력한 수주정보와 첨부파일을 확인했습니다.', style: RobinTheme.bodyMd),
            subtitle: Text('제출 시 로보스타 영업팀 검토 및 ERP 연계 절차가 진행됩니다.',
                style: RobinTheme.bodySm),
          ),
        ],
      );

  Widget _navigationButtons() => Row(
        children: [
          OutlinedButton(onPressed: _saveDraft, child: const Text('임시 저장')),
          const Spacer(),
          if (_currentStep > 0)
            OutlinedButton.icon(
                onPressed: () => setState(() => _currentStep--),
                icon: const Icon(Icons.arrow_back, size: 17),
                label: const Text('이전')),
          const SizedBox(width: 8),
          if (_currentStep < _steps.length - 1)
            FilledButton.icon(
                onPressed: _nextStep,
                icon: const Icon(Icons.arrow_forward, size: 17),
                label: const Text('다음 단계'))
          else
            FilledButton.icon(
                onPressed: _confirmed ? _submitOrder : null,
                icon: const Icon(Icons.send_outlined, size: 17),
                label: const Text('수주 등록 제출')),
        ],
      );

  Widget _sectionTitle(String title, String description) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: RobinTheme.headingSm),
          const SizedBox(height: 4),
          Text(description, style: RobinTheme.bodySm),
        ],
      );

  Widget _scheduleField(String label, TextEditingController controller) =>
      _RegistrationField(
          controller: controller, label: label, hint: 'YYYY-MM-DD');

  Widget _reviewCard(String title, List<String> lines) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: RobinTheme.background,
            borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: RobinTheme.headingSm),
          const SizedBox(height: 9),
          ...lines.map((line) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(line, style: RobinTheme.bodySm))),
        ]),
      );

  Widget _emptyBox(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: RobinTheme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: RobinTheme.border)),
        child:
            Text(text, textAlign: TextAlign.center, style: RobinTheme.bodySm),
      );

  void _addProduct() {
    if (!_productFormKey.currentState!.validate()) return;
    setState(() {
      _products.add(_SelectedProduct(
          model: _modelController.text.trim(),
          name: _productNameController.text.trim(),
          quantity: int.parse(_quantityController.text.trim()),
          option: _optionController.text.trim(),
          spec: _specController.text.trim()));
      _modelController.clear();
      _productNameController.clear();
      _quantityController.text = '1';
      _optionController.clear();
      _specController.clear();
    });
  }

  void _nextStep() {
    if (_currentStep == 0 && !_basicFormKey.currentState!.validate()) return;
    if (_currentStep == 1 && _products.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('제품을 한 개 이상 추가해주세요.')));
      return;
    }
    if (_currentStep == 2 && !_scheduleFormKey.currentState!.validate()) return;
    setState(() => _currentStep++);
  }

  void _addAttachment() {
    setState(() => _attachments.add('첨부문서_${_attachments.length + 1}.pdf'));
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('수주정보가 임시 저장되었습니다.')));
  }

  Future<void> _submitOrder() async {
    final now = DateTime.now();
    final orderNo = _createOrderNumber(now);
    final dueDate = DateTime.tryParse(_dueDateController.text.trim()) ??
        now.add(const Duration(days: 30));
    final product = _products.first;
    final project = OrderProject(
      orderNo: orderNo,
      projectName: _projectController.text.trim(),
      category: '로봇',
      projectType: product.name,
      customer: _customerController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      status: '진행 중 (Ing)',
      progress: 5,
      stepOrder: true,
      stepDesign: false,
      stepPurchase: false,
      stepProduction: false,
      stepDelivery: false,
      stepOperation: false,
      dueDate: dueDate,
      lastUpdated: now,
    );

    SampleData.projects.insert(0, project);
    SampleData.updates.insert(
      0,
      UpdateItem(
        orderNo: orderNo,
        description: '신규 수주 등록 완료',
        datetime: now,
      ),
    );
    SampleData.recentlyRegisteredOrderNo = orderNo;
    _numberController.text = orderNo;

    await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
              title: const Row(children: [
                Icon(Icons.check_circle, color: RobinTheme.signalGreen),
                SizedBox(width: 9),
                Text('수주 등록 완료'),
              ]),
              content: Text('$orderNo · ${_projectController.text}\n'
                  '수주정보가 현황에 등록되었습니다.\n'
                  '확인을 누르면 수주·프로젝트 현황으로 이동합니다.'),
              actions: [
                FilledButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('확인'))
              ],
            ));
    _pendingOrderDraft = null;
    if (mounted) widget.onNavigate?.call(3);
  }

  String _createOrderNumber(DateTime now) {
    final entered = _numberController.text.trim();
    if (entered.startsWith('SO-')) return entered;

    final year = (now.year % 100).toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final prefix = 'SO-$year$month-';
    var sequence = 1;
    for (final project in SampleData.projects) {
      if (!project.orderNo.startsWith(prefix)) continue;
      final value = int.tryParse(project.orderNo.substring(prefix.length));
      if (value != null && value >= sequence) sequence = value + 1;
    }
    return '$prefix${sequence.toString().padLeft(3, '0')}';
  }
}

class _RegistrationField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool readOnly;
  final bool required;
  final bool number;

  const _RegistrationField({
    required this.controller,
    required this.label,
    required this.hint,
    this.readOnly = false,
    this.required = true,
    this.number = false,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: RobinTheme.headingSm.copyWith(fontSize: 12)),
          const SizedBox(height: 7),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: number ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
              isDense: true,
              filled: readOnly,
              fillColor: readOnly ? RobinTheme.background : null,
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (required && text.isEmpty) return '$label 항목을 입력해주세요.';
              if (number && text.isNotEmpty && (num.tryParse(text) ?? 0) <= 0) {
                return '0보다 큰 숫자를 입력해주세요.';
              }
              return null;
            },
          ),
        ],
      );
}

class _SelectedProduct {
  final String model;
  final String name;
  final int quantity;
  final String option;
  final String spec;

  const _SelectedProduct({
    required this.model,
    required this.name,
    required this.quantity,
    required this.option,
    required this.spec,
  });
}

class _OrderDraft {
  final String number;
  final String projectName;
  final String customer;
  final double amount;
  final String owner;

  const _OrderDraft({
    required this.number,
    required this.projectName,
    required this.customer,
    required this.amount,
    required this.owner,
  });

  factory _OrderDraft.fromLead(_LeadData lead) => _OrderDraft(
        number: lead.number,
        projectName: lead.projectName,
        customer: lead.customer,
        amount: lead.amount,
        owner: lead.owner,
      );
}

class _OrganizationAppsView extends StatelessWidget {
  const _OrganizationAppsView();

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _PageIntro(
          'AX Board',
          '권한 그룹을 통해 접근 기능을 통제하는 사내 Python 업무 앱과 분석 화면입니다.',
        ),
        const SizedBox(height: 18),
        Expanded(
          child: ValueListenableBuilder<List<PythonAppPermission>>(
            valueListenable: pythonAppPermissions,
            builder: (context, apps, _) =>
                ValueListenableBuilder<List<PythonPermissionGroup>>(
              valueListenable: pythonPermissionGroups,
              builder: (context, groups, _) =>
                  ValueListenableBuilder<List<RobinPermissionRequest>>(
                valueListenable: robinPermissionRequests,
                builder: (context, requests, _) {
                  final profile = robinUserProfile.value;
                  RobinEmployee? employee;
                  for (final item in robinEmployees.value) {
                    if (item.id == profile.username) employee = item;
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 360,
                      mainAxisExtent: 205,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      final allowedActionIds = profile.isAdmin
                          ? app.actions.map((action) => action.id).toSet()
                          : employee == null
                              ? <String>{}
                              : effectivePythonActions(employee, app.id);
                      final availableGroups = groups
                          .where((group) =>
                              (group.appActionIds[app.id] ?? const <String>{})
                                  .isNotEmpty)
                          .toList();
                      final assignedGroupIds =
                          employee?.pythonGroupIds ?? const <String>{};
                      final requestableGroups = availableGroups
                          .where(
                              (group) => !assignedGroupIds.contains(group.id))
                          .toList();
                      final pending = requests.any((request) {
                        if (request.employeeId != profile.username ||
                            request.status != PermissionRequestStatus.pending ||
                            request.requestedPythonGroupIds.isEmpty) {
                          return false;
                        }
                        return availableGroups.any((group) =>
                            request.requestedPythonGroupIds.contains(group.id));
                      });
                      final granted = allowedActionIds.isNotEmpty;
                      final status = profile.isAdmin
                          ? '관리자 전체 권한'
                          : granted
                              ? '기능 ${allowedActionIds.length}개'
                              : pending
                                  ? '신청 중'
                                  : requestableGroups.isEmpty
                                      ? '신청 가능 그룹 없음'
                                      : '그룹 권한 신청';
                      final color = granted || profile.isAdmin
                          ? RobinTheme.signalGreen
                          : pending
                              ? RobinTheme.signalYellow
                              : RobinTheme.textMuted;
                      final allowedActions = app.actions
                          .where(
                              (action) => allowedActionIds.contains(action.id))
                          .toList();

                      return InkWell(
                        onTap: profile.isAdmin ||
                                granted ||
                                pending ||
                                requestableGroups.isEmpty
                            ? null
                            : () =>
                                _requestGroup(context, app, requestableGroups),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: _cardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(Icons.apps_outlined,
                                    color: granted || profile.isAdmin
                                        ? RobinTheme.primary
                                        : RobinTheme.textMuted),
                                const Spacer(),
                                _badge(status, color),
                              ]),
                              const SizedBox(height: 13),
                              Text(app.name, style: RobinTheme.headingSm),
                              const SizedBox(height: 4),
                              Text(app.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: RobinTheme.bodySm),
                              const Spacer(),
                              if (profile.isAdmin || granted)
                                Text(
                                  allowedActions.isEmpty
                                      ? '등록된 기능 권한 없음'
                                      : '허용 기능: ${allowedActions.map((action) => action.name).join(' · ')}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: RobinTheme.labelXs,
                                )
                              else
                                Text(
                                  availableGroups.isEmpty
                                      ? '이 앱이 포함된 권한 그룹이 없습니다.'
                                      : '사용 가능 그룹: ${availableGroups.map((group) => group.name).join(' · ')}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: RobinTheme.labelXs,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ]);

  Future<void> _requestGroup(BuildContext context, PythonAppPermission app,
      List<PythonPermissionGroup> groups) async {
    var selectedGroupId = groups.first.id;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${app.name} 권한 그룹 신청'),
          content: SizedBox(
            width: 430,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('이 앱을 사용할 수 있는 Python 권한 그룹을 선택하세요.',
                    style: RobinTheme.bodySm),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedGroupId,
                  decoration: const InputDecoration(
                    labelText: 'Python 권한 그룹',
                    border: OutlineInputBorder(),
                  ),
                  items: groups
                      .map((group) => DropdownMenuItem(
                          value: group.id, child: Text(group.name)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedGroupId = value);
                    }
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  groups
                      .firstWhere((group) => group.id == selectedGroupId)
                      .description,
                  style: RobinTheme.labelXs,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('신청'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final nextId = robinPermissionRequests.value
            .fold<int>(0, (max, item) => item.id > max ? item.id : max) +
        1;
    final profile = robinUserProfile.value;
    final now = DateTime.now();
    robinPermissionRequests.value = [
      RobinPermissionRequest(
        id: nextId,
        documentNo:
            'RBN-APR-${DateFormat('yyyyMMdd').format(now)}-${nextId.toString().padLeft(3, '0')}',
        title: '${pythonGroupName(selectedGroupId)} 권한 신청',
        employeeId: profile.username,
        requesterId: profile.username,
        requestType: 'Python 그룹 권한',
        requestedRole: profile.role,
        requestedDepartment: profile.departmentPermission,
        requestedPythonGroupIds: {selectedGroupId},
        reason: '${pythonGroupName(selectedGroupId)} 사용 신청',
        requestedAt: now,
      ),
      ...robinPermissionRequests.value,
    ];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${pythonGroupName(selectedGroupId)} 권한을 신청했습니다.')),
    );
  }
}

class _AssistantView extends StatelessWidget {
  const _AssistantView();
  @override
  Widget build(BuildContext context) => Column(children: [
        const _PageIntro(
            'AI Assistant', '초기 범위는 ROBIN 매뉴얼과 업무 절차를 안내하는 사내 챗봇입니다.'),
        const SizedBox(height: 18),
        Expanded(
          child: Container(
            decoration: _cardDecoration(),
            child: Column(children: [
              Expanded(
                child: ListView(padding: const EdgeInsets.all(22), children: [
                  _chat('ROBIN에서 신규 수주는 어떻게 등록하나요?', true),
                  _chat(
                      '파이프라인 등록에서 Assess 물동, Proposal 컨셉설계, Negotiation 상세 Spec.·가격·결재를 진행한 뒤 수주관리에서 확정 상태를 확인하세요.',
                      false),
                ]),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(14),
                child: TextField(
                    decoration: InputDecoration(
                        hintText: 'ROBIN 사용 방법을 질문하세요.',
                        suffixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.send_rounded)),
                        border: const OutlineInputBorder())),
              ),
            ]),
          ),
        ),
      ]);

  static Widget _chat(String text, bool user) => Align(
        alignment: user ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
              color: user ? RobinTheme.primary : RobinTheme.background,
              borderRadius: BorderRadius.circular(10)),
          child: Text(text,
              style: RobinTheme.bodyMd
                  .copyWith(color: user ? Colors.white : null)),
        ),
      );
}

class _IntegrationView extends StatelessWidget {
  const _IntegrationView();
  @override
  Widget build(BuildContext context) {
    const rows = [
      ('ROBIN → ERP', '확정 수주정보', '이벤트 실시간', '성공', '10:32'),
      ('ERP → ROBIN', '진척도·현황표', '1시간 단위', '성공', '10:00'),
      ('ERP → ROBIN', 'To-Do·담당자', '준실시간 협의', '점검', '09:58'),
      ('SmartOrder', '도면 검토 요청', '설계 단계', '대기', '-'),
      ('PDM', 'BOM·Revision', '별도 사업 협의', '범위 외', '-'),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _PageIntro('연계 모니터링', '방향별 동기화 정책과 처리 결과, 오류 이력을 확인합니다.'),
      const SizedBox(height: 18),
      Expanded(
        child: Container(
          decoration: _cardDecoration(),
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final row = rows[index];
              return ListTile(
                leading: CircleAvatar(
                    backgroundColor: RobinTheme.accentLight,
                    child: Icon(Icons.sync_alt,
                        color: RobinTheme.primary, size: 19)),
                title: Text(row.$1, style: RobinTheme.headingSm),
                subtitle:
                    Text('${row.$2} · ${row.$3}', style: RobinTheme.bodySm),
                trailing: SizedBox(
                    width: 150,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _badge(
                              row.$4,
                              row.$4 == '성공'
                                  ? RobinTheme.signalGreen
                                  : RobinTheme.signalYellow),
                          const SizedBox(width: 12),
                          Text(row.$5, style: RobinTheme.labelXs)
                        ])),
              );
            },
          ),
        ),
      ),
    ]);
  }
}

class _PermissionView extends StatelessWidget {
  const _PermissionView();
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _PageIntro('권한 관리', '조직·역할별 조회 범위와 Python 앱 링크 접근 권한을 관리합니다.',
            action: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('권한 신청'))),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
              child: _permissionCard(
                  '조회 권한 정책',
                  '사업조직 상호 조회 제한',
                  ['로봇사업부: 로봇 데이터', '플랫폼사업부: 플랫폼 데이터', '공통조직·경영진: 전체 조회'],
                  Icons.visibility_outlined)),
          const SizedBox(width: 14),
          Expanded(
              child: _permissionCard(
                  '권한 신청·결재',
                  '신청 → 승인 → 부여',
                  ['대기 3건', '승인 12건', '실제 권한 매칭 모니터링'],
                  Icons.approval_outlined)),
        ]),
        const SizedBox(height: 14),
        Expanded(
            child: _SimpleListView(
                title: '최근 권한 요청',
                description: '승인된 ROBIN 권한과 각 앱의 실제 권한을 비교합니다.',
                items: const [
              '구매 분석 접근 권한 · 승인 대기',
              'CS 현황 접근 권한 · 팀장 승인',
              '플랫폼 수주 조회 · 반려'
            ]))
      ]);

  static Widget _permissionCard(
          String title, String subtitle, List<String> lines, IconData icon) =>
      Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
              backgroundColor: RobinTheme.accentLight,
              child: Icon(icon, color: RobinTheme.primary)),
          const SizedBox(width: 13),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title, style: RobinTheme.headingSm),
                Text(subtitle, style: RobinTheme.bodySm),
                const SizedBox(height: 10),
                ...lines.map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $line', style: RobinTheme.bodySm))),
              ])),
        ]),
      );
}

class _MyPageView extends StatelessWidget {
  const _MyPageView();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PageIntro(
            '마이페이지',
            '내 정보와 업무 배정 알림, To-Do 및 권한 신청 내역을 확인합니다.',
          ),
          const SizedBox(height: 18),
          ValueListenableBuilder<RobinUserProfile>(
            valueListenable: robinUserProfile,
            builder: (context, profile, _) => _MyProfileCard(profile: profile),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _myStat('내 To-Do', '4건', Icons.task_alt_outlined,
                  const Color(0xFF4F46E5)),
              const SizedBox(width: 10),
              _myStat(
                '읽지 않은 알림',
                '${unreadRobinNotificationCount}건',
                Icons.notifications_active_outlined,
                RobinTheme.primary,
              ),
              const SizedBox(width: 10),
              ValueListenableBuilder<RobinUserProfile>(
                valueListenable: robinUserProfile,
                builder: (context, profile, _) =>
                    ValueListenableBuilder<List<RobinPermissionRequest>>(
                  valueListenable: robinPermissionRequests,
                  builder: (context, requests, _) {
                    final pendingCount = requests
                        .where((request) =>
                            (request.employeeId == profile.username ||
                                request.requesterId == profile.username) &&
                            request.status == PermissionRequestStatus.pending)
                        .length;
                    return _myStat(
                      '권한 신청 진행',
                      '$pendingCount건',
                      Icons.approval_outlined,
                      RobinTheme.signalYellow,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Container(
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(text: '알림 기록'),
                        Tab(
                          key: ValueKey('my-permission-history-tab'),
                          text: '내 권한 품의·결재 내역',
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: TabBarView(
                        children: [
                          RobinNotificationList(
                            onSelected: (notification) =>
                                showRobinNotificationDetail(
                                    context, notification),
                          ),
                          const _MyPermissionRequestList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

  static Widget _myStat(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 19, color: color),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: RobinTheme.labelXs),
                  const SizedBox(height: 3),
                  Text(value, style: RobinTheme.headingSm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyPermissionRequestList extends StatelessWidget {
  const _MyPermissionRequestList();

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<RobinUserProfile>(
        valueListenable: robinUserProfile,
        builder: (context, profile, _) =>
            ValueListenableBuilder<List<RobinPermissionRequest>>(
          valueListenable: robinPermissionRequests,
          builder: (context, requests, _) {
            final mine = requests
                .where((request) =>
                    request.employeeId == profile.username ||
                    request.requesterId == profile.username)
                .toList()
              ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
            if (mine.isEmpty) {
              return Center(
                child: Text('내 권한 품의 내역이 없습니다.', style: RobinTheme.bodySm),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: mine.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _myPermissionRequestCard(mine[index]),
            );
          },
        ),
      );

  static Widget _myPermissionRequestCard(RobinPermissionRequest request) {
    final color = switch (request.status) {
      PermissionRequestStatus.pending => RobinTheme.signalYellow,
      PermissionRequestStatus.approved => RobinTheme.signalGreen,
      PermissionRequestStatus.rejected => RobinTheme.error,
    };
    final groups = request.requestedPythonGroupIds
        .map(pythonGroupName)
        .where((name) => name != '-')
        .join(', ');
    final permissions = [
      if (request.requestedRole != null) request.requestedRole!.label,
      if (request.requestedDepartment != null)
        '${request.requestedDepartment!.label} 권한',
      if (groups.isNotEmpty) groups,
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.all(14),
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
              Expanded(
                child: Text('${request.documentNo} · ${request.title}',
                    style: RobinTheme.headingSm),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  request.status.label,
                  style: RobinTheme.labelXs
                      .copyWith(color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('신청 권한  $permissions', style: RobinTheme.bodySm),
          const SizedBox(height: 4),
          Text('품의 사유  ${request.reason}', style: RobinTheme.bodySm),
          const SizedBox(height: 4),
          Text(
            '신청일  ${DateFormat('yyyy-MM-dd HH:mm').format(request.requestedAt)}',
            style: RobinTheme.labelXs,
          ),
          if (request.status != PermissionRequestStatus.pending) ...[
            const Divider(height: 18),
            Text(
              '결재자  ${employeeDisplayName(request.decidedBy ?? '')} · '
              '${request.decidedAt == null ? '-' : DateFormat('yyyy-MM-dd HH:mm').format(request.decidedAt!)}',
              style: RobinTheme.bodySm,
            ),
            const SizedBox(height: 4),
            Text('결재 의견  ${request.decisionNote ?? '-'}',
                style: RobinTheme.bodySm),
          ],
        ],
      ),
    );
  }
}

class _MyProfileCard extends StatelessWidget {
  final RobinUserProfile profile;

  const _MyProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<List<RobinEmployee>>(
        valueListenable: robinEmployees,
        builder: (context, employees, _) =>
            ValueListenableBuilder<List<PythonPermissionGroup>>(
          valueListenable: pythonPermissionGroups,
          builder: (context, groups, _) {
            RobinEmployee? employee;
            for (final item in employees) {
              if (item.id == profile.username) employee = item;
            }
            final assignedGroups = employee == null
                ? <PythonPermissionGroup>[]
                : groups
                    .where(
                        (group) => employee!.pythonGroupIds.contains(group.id))
                    .toList();

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: _cardDecoration(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: RobinTheme.accentLight,
                    child: Text(
                      profile.name.isEmpty ? '?' : profile.name[0],
                      style: RobinTheme.headingLg
                          .copyWith(color: RobinTheme.primary, fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text('${profile.name} ${profile.rank}',
                              style: RobinTheme.headingLg),
                          const SizedBox(width: 8),
                          _profileBadge(
                            profile.role.label,
                            profile.isAdmin
                                ? RobinTheme.primary
                                : profile.isDealer
                                    ? RobinTheme.warning
                                    : RobinTheme.signalGreen,
                          ),
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: () => showRobinProfileEditor(context),
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('내 정보 수정'),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 22,
                          runSpacing: 10,
                          children: [
                            _profileInfo(
                                Icons.badge_outlined, '계정', profile.username),
                            _profileInfo(Icons.business_outlined, '부서',
                                profile.department),
                            _profileInfo(Icons.admin_panel_settings_outlined,
                                '부서 권한', profile.departmentPermission.label),
                            _profileInfo(
                                Icons.email_outlined, '이메일', profile.email),
                            _profileInfo(
                                Icons.phone_outlined, '연락처', profile.phone),
                          ],
                        ),
                        const SizedBox(height: 13),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 105,
                              child: Text('Python 권한 그룹',
                                  style: RobinTheme.labelXs),
                            ),
                            Expanded(
                              child: profile.isAdmin
                                  ? Wrap(children: [
                                      _profileBadge(
                                          '관리자 전체 접근', RobinTheme.primary)
                                    ])
                                  : assignedGroups.isEmpty
                                      ? Text('부여된 Python 권한 그룹이 없습니다.',
                                          style: RobinTheme.bodySm)
                                      : Wrap(
                                          spacing: 7,
                                          runSpacing: 6,
                                          children: assignedGroups
                                              .map((group) => _profileBadge(
                                                    '${group.name} · 앱 ${group.appActionIds.length}개',
                                                    RobinTheme.signalGreen,
                                                  ))
                                              .toList(),
                                        ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

  static Widget _profileInfo(IconData icon, String label, String value) =>
      SizedBox(
        width: 205,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: RobinTheme.textMuted),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: RobinTheme.labelXs),
                  const SizedBox(height: 2),
                  Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: RobinTheme.bodyMd
                          .copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );

  static Widget _profileBadge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: RobinTheme.labelXs
                .copyWith(color: color, fontWeight: FontWeight.w700)),
      );
}

class _UpdatesView extends StatelessWidget {
  const _UpdatesView();

  @override
  Widget build(BuildContext context) {
    const updates = [
      ('SO-2405-001', '구매 단계 진행률 업데이트', '2026-07-29 10:30', '프로젝트'),
      ('SO-2405-002', '생산 준비 시작', '2026-07-28 16:20', '프로젝트'),
      ('SO-2405-003', '생산 단계 완료', '2026-07-28 14:10', '프로젝트'),
      ('SO-2405-004', '구매 지연 - 부품 입고 대기', '2026-07-27 11:05', '이슈'),
      ('RB-2607-014', '수주 성공 및 ERP 연계 완료', '2026-07-26 09:45', '수주'),
      ('SYSTEM', '신호등 기준정보가 갱신되었습니다.', '2026-07-25 18:00', '시스템'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PageIntro('로그 및 이슈 조회', '수주·프로젝트 및 시스템의 최근 변경사항을 확인합니다.'),
        const SizedBox(height: 18),
        Expanded(
          child: Container(
            decoration: _cardDecoration(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: updates.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 68),
              itemBuilder: (context, index) {
                final update = updates[index];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: RobinTheme.accentLight,
                    child: Icon(
                      update.$4 == '이슈'
                          ? Icons.warning_amber_rounded
                          : Icons.update_outlined,
                      size: 19,
                      color: update.$4 == '이슈'
                          ? RobinTheme.signalYellow
                          : RobinTheme.primary,
                    ),
                  ),
                  title: Text(update.$2, style: RobinTheme.headingSm),
                  subtitle: Text('${update.$1} · ${update.$4}',
                      style: RobinTheme.bodySm),
                  trailing: Text(update.$3, style: RobinTheme.labelXs),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _FaqView extends StatelessWidget {
  const _FaqView();

  @override
  Widget build(BuildContext context) {
    const faqs = [
      (
        '수주 등록',
        '신규 수주는 어떻게 등록하나요?',
        '파이프라인 등록의 Assess → Proposal → Negotiation 단계를 완료하고 Closed Won 처리 후 수주관리에서 ERP 확정 상태를 확인하세요.'
      ),
      (
        '파이프라인',
        '수주 단계는 어떻게 변경하나요?',
        '파이프라인 등록에서 프로젝트 카드를 선택하고 Assess, Proposal, Negotiation, Closed Won/Lost를 지정하거나 어느 단계에서든 Drop 처리하세요.'
      ),
      (
        '프로젝트',
        '납기일 변경은 어떻게 요청하나요?',
        '프로젝트 상세의 일정 영역에서 변경 요청을 등록하세요. 승인 결과는 알림으로 전달됩니다.'
      ),
      (
        '알림',
        '업무 담당자 배정 알림은 어디에서 확인하나요?',
        '상단 종 버튼 또는 마이페이지의 알림 기록에서 확인할 수 있습니다.'
      ),
      (
        '권한',
        'AX Board 권한은 어떻게 신청하나요?',
        '권한 관리에서 필요한 앱의 접근 권한을 신청하면 승인 후 사용할 수 있습니다.'
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PageIntro('자주 묻는 질문', 'ROBIN 주요 기능과 업무 처리 방법을 확인합니다.'),
        const SizedBox(height: 18),
        Expanded(
          child: Container(
            decoration: _cardDecoration(),
            child: ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: faqs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final faq = faqs[index];
                return ExpansionTile(
                  leading: const CircleAvatar(
                    radius: 15,
                    backgroundColor: RobinTheme.accentLight,
                    child: Text('Q',
                        style: TextStyle(
                            color: RobinTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                  title: Text(faq.$2, style: RobinTheme.headingSm),
                  subtitle: Text(faq.$1, style: RobinTheme.labelXs),
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(58, 0, 14, 12),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: RobinTheme.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(faq.$3, style: RobinTheme.bodyMd),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SimpleListView extends StatelessWidget {
  final String title;
  final String description;
  final List<String> items;
  const _SimpleListView(
      {required this.title, required this.description, required this.items});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageIntro(title, description),
          const SizedBox(height: 18),
          Container(
            decoration: _cardDecoration(),
            child: Column(
                children: items
                    .map((item) => ListTile(
                        leading: const Icon(Icons.circle,
                            size: 7, color: RobinTheme.primary),
                        title: Text(item, style: RobinTheme.bodyMd),
                        trailing: const Icon(Icons.chevron_right,
                            color: RobinTheme.textMuted)))
                    .toList()),
          ),
        ],
      );
}

class _PipelineFilterBar extends StatelessWidget {
  final String period;
  final String customer;
  final String dealer;
  final String owner;
  final String progress;
  final String stage;
  final List<String> customers;
  final List<String> dealers;
  final List<String> owners;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<String> onCustomerChanged;
  final ValueChanged<String> onDealerChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onProgressChanged;
  final ValueChanged<String> onStageChanged;
  final VoidCallback onReset;
  final int resultCount;

  const _PipelineFilterBar({
    required this.period,
    required this.customer,
    required this.dealer,
    required this.owner,
    required this.progress,
    required this.stage,
    required this.customers,
    required this.dealers,
    required this.owners,
    required this.onPeriodChanged,
    required this.onCustomerChanged,
    required this.onDealerChanged,
    required this.onOwnerChanged,
    required this.onProgressChanged,
    required this.onStageChanged,
    required this.onReset,
    required this.resultCount,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterSelect(
                    label: '기간',
                    value: period,
                    values: const [
                      '전체 기간',
                      '2026년 7월',
                      '2026년 8월',
                      '2026년 3분기'
                    ],
                    onChanged: onPeriodChanged,
                  ),
                  _FilterSelect(
                    label: '고객사',
                    value: customer,
                    values: customers,
                    onChanged: onCustomerChanged,
                  ),
                  _FilterSelect(
                    label: '대리점',
                    value: dealer,
                    values: dealers,
                    onChanged: onDealerChanged,
                  ),
                  _FilterSelect(
                    label: '담당자',
                    value: owner,
                    values: owners,
                    onChanged: onOwnerChanged,
                  ),
                  _FilterSelect(
                    label: '진행 구분',
                    value: progress,
                    values: const ['전체 진행', '진행 중', '종료'],
                    onChanged: onProgressChanged,
                  ),
                  _FilterSelect(
                    label: '수주 단계',
                    value: stage,
                    values: const [
                      '전체 단계',
                      'Assess',
                      'Proposal',
                      'Negotiation',
                      'Closed Won',
                      'Closed Lost'
                    ],
                    onChanged: onStageChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('$resultCount건',
                style:
                    RobinTheme.headingSm.copyWith(color: RobinTheme.primary)),
            const SizedBox(width: 8),
            IconButton.outlined(
              tooltip: '필터 초기화',
              onPressed: onReset,
              icon: const Icon(Icons.refresh, size: 18),
            ),
          ],
        ),
      );
}

class _FilterSelect extends StatelessWidget {
  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  const _FilterSelect({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: RobinTheme.surface,
          border: Border.all(color: RobinTheme.border),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$label  ', style: RobinTheme.labelXs),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                style:
                    RobinTheme.bodySm.copyWith(color: RobinTheme.textPrimary),
                items: values
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
                onChanged: (selected) {
                  if (selected != null) onChanged(selected);
                },
              ),
            ),
          ],
        ),
      );
}

Widget _badge(String text, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(12)),
      child: Text(text,
          style: RobinTheme.labelXs
              .copyWith(color: color, fontWeight: FontWeight.w700)),
    );

BoxDecoration _cardDecoration() => BoxDecoration(
      color: RobinTheme.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: RobinTheme.border),
    );
