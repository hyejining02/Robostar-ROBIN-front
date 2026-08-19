import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order_project.dart';
import '../theme/robin_theme.dart';
import '../widgets/app_bar.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: RobinTheme.background,
        appBar: const RobinAppBar(title: 'ROBIN Home'),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 1050;
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
                      _todoSummary(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (compact) ...[
                    _TodoPanel(onNavigate: onNavigate),
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
                            child: _TodoPanel(onNavigate: onNavigate),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 3,
                            child: _RightHomePanel(onNavigate: onNavigate),
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

  static Widget _todoSummary() => Container(
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
            Text('오늘 처리할 To-Do  6건',
                style: RobinTheme.headingSm.copyWith(color: Colors.white)),
          ],
        ),
      );
}

class _TodoPanel extends StatefulWidget {
  final ValueChanged<int> onNavigate;

  const _TodoPanel({required this.onNavigate});

  @override
  State<_TodoPanel> createState() => _TodoPanelState();
}

class _TodoPanelState extends State<_TodoPanel> {
  String _filter = '전체';

  static const _items = [
    _TodoData(
        '긴급',
        'SO-2405-003',
        '물류 자동화 프로젝트',
        '구매',
        '생산',
        'BOM 장기재고 2건 확인 및 생산 예정일 입력',
        '수주 Spec. 변경: 컨베이어 길이 12m → 15m',
        '오늘 14:00'),
    _TodoData('신규', 'SO-2405-001', '자동화 라인 구축 프로젝트', '설계', '구매',
        '설계 완료 승인 후 BOM 구매 구분 등록', '도면 Rev.03 / 안전펜스 사양 추가', '오늘 16:00'),
    _TodoData('지연', 'SO-2405-005', '검사 장비 개선', '생산', '품질',
        '생산완료 수량 확인 후 IQC/LQC/OQC 검사계획 등록', '카메라 모델 변경 및 검사 기준 업데이트', 'D+1'),
    _TodoData('신규', 'SO-2405-007', 'AGV 공급 건', '품질', '물류',
        '출하검사 완료 확인 및 납품처 정보 입력', '배터리 사양 48V 100Ah 확정', '08-20'),
    _TodoData('대기', 'SO-2405-002', '스마트 팩토리 구축', '물류', '마감', '배차 생성 및 상차 완료 처리',
        '납품처: 창원 2공장으로 변경', '08-21'),
    _TodoData('대기', 'SO-2405-006', '로봇 시스템 공급 건', '마감', '완료',
        'ERP 거래명세서 발행 여부 확인', '변경사항 없음', '08-22'),
  ];

  @override
  Widget build(BuildContext context) {
    final visible = _filter == '전체'
        ? _items
        : _items.where((item) => item.nextStage == _filter).toList();
    return Container(
      height: 660,
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
                DropdownButton<String>(
                  value: _filter,
                  items: const ['전체', '설계', '구매', '생산', '품질', '물류', '마감']
                      .map((value) =>
                          DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _filter = value);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('해당 단계의 To-Do가 없습니다.'))
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

  const _TodoData(this.priority, this.orderNo, this.projectName,
      this.previousStage, this.nextStage, this.task, this.specChange, this.due);
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: RobinTheme.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: RobinTheme.border),
    );
