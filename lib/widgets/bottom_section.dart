import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_project.dart';
import '../theme/robin_theme.dart';

class BottomSection extends StatelessWidget {
  final ValueChanged<int>? onNavigate;

  const BottomSection({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 5
            : constraints.maxWidth >= 680
                ? 2
                : 1;
        final cards = <Widget>[
          _CategoryChart(),
          _StatusChart(),
          _NoticeCard(onMore: () => onNavigate?.call(6)),
          _UpdateCard(onMore: () => onNavigate?.call(7)),
          _FaqCard(onMore: () => onNavigate?.call(8)),
        ];
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 250,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) => cards[index],
        );
      },
    );
  }
}

class _CategoryChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '프로젝트 구분별 현황',
      child: Column(
        children: [
          const SizedBox(height: 8),
          // 간단한 도넛 표현 (fl_chart 없이)
          SizedBox(
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: 0.571,
                    backgroundColor: const Color(0xFFE8F0FE),
                    valueColor: const AlwaysStoppedAnimation(RobinTheme.accent),
                    strokeWidth: 18,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('28', style: RobinTheme.numericMd),
                    Text('전체', style: RobinTheme.labelXs),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _LegendItem(
              color: RobinTheme.accent,
              label: '로봇 (Robot)',
              value: '16건 (57.1%)'),
          const SizedBox(height: 6),
          _LegendItem(
              color: const Color(0xFF7C3AED),
              label: '플랫폼 (Platform)',
              value: '12건 (42.9%)'),
        ],
      ),
    );
  }
}

class _StatusChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bars = [
      _BarData('진행 중 (Ing)', 18, 0.643, RobinTheme.accent),
      _BarData('완료 (Success)', 7, 0.25, RobinTheme.success),
      _BarData('중단/Drop', 3, 0.107, RobinTheme.error),
    ];

    return _SectionCard(
      title: '프로젝트 상태 현황',
      child: Column(
        children: bars
            .map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(b.label,
                                  style: RobinTheme.bodySm
                                      .copyWith(fontSize: 11))),
                          Text('${(b.ratio * 100).toStringAsFixed(1)}%',
                              style: RobinTheme.bodySm.copyWith(
                                  fontSize: 11,
                                  color: b.color,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: b.ratio,
                          backgroundColor: RobinTheme.divider,
                          valueColor: AlwaysStoppedAnimation(b.color),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final VoidCallback onMore;
  const _NoticeCard({required this.onMore});

  @override
  Widget build(BuildContext context) {
    final notices = SampleData.notices;
    final fmt = DateFormat('yyyy-MM-dd');

    return _SectionCard(
      title: '공지사항',
      trailing: _MoreBtn(onPressed: onMore),
      child: Column(
        children: notices
            .map((n) => _ListRow(
                  title: n.title,
                  date: fmt.format(n.date),
                ))
            .toList(),
      ),
    );
  }
}

class _UpdateCard extends StatelessWidget {
  final VoidCallback onMore;
  const _UpdateCard({required this.onMore});

  @override
  Widget build(BuildContext context) {
    final updates = [...SampleData.updates]
      ..sort((a, b) => b.datetime.compareTo(a.datetime));
    final recentUpdates = updates.take(4);
    final fmt = DateFormat('MM-dd HH:mm');

    return _SectionCard(
      title: '로그 및 이슈 조회',
      trailing: _MoreBtn(onPressed: onMore),
      child: Column(
        children: recentUpdates
            .map((u) => _ListRow(
                  title: u.description,
                  label: u.orderNo,
                  date: fmt.format(u.datetime),
                ))
            .toList(),
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  final VoidCallback onMore;
  const _FaqCard({required this.onMore});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      '수주 등록은 어떻게 하나요?',
      '진행 단계는 어떻게 구분되나요?',
      '납기일 일정 변경은 어떻게 요청하나요?',
      '담당자 연락처를 확인하고 싶어요.',
    ];

    return _SectionCard(
      title: '자주 묻는 질문',
      trailing: _MoreBtn(onPressed: onMore),
      child: Column(
        children: faqs.map((q) => _FaqRow(question: q)).toList(),
      ),
    );
  }
}

// ── 작은 컴포넌트들 ─────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RobinTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: RobinTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: RobinTheme.headingSm.copyWith(fontSize: 13)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _LegendItem(
      {required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Text(label, style: RobinTheme.bodySm.copyWith(fontSize: 11))),
          Text(value,
              style: RobinTheme.bodySm
                  .copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      );
}

class _BarData {
  final String label;
  final int count;
  final double ratio;
  final Color color;
  const _BarData(this.label, this.count, this.ratio, this.color);
}

class _ListRow extends StatelessWidget {
  final String title;
  final String? label;
  final String date;
  const _ListRow({required this.title, this.label, required this.date});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(label!,
                        style: RobinTheme.labelXs.copyWith(
                          color: RobinTheme.accent,
                          fontWeight: FontWeight.w600,
                        )),
                  Text(title,
                      style: RobinTheme.bodySm.copyWith(
                        fontSize: 11,
                        color: RobinTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(date, style: RobinTheme.labelXs),
          ],
        ),
      );
}

class _FaqRow extends StatelessWidget {
  final String question;
  const _FaqRow({required this.question});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            const Text('Q. ',
                style: TextStyle(
                  fontSize: 11,
                  color: RobinTheme.accent,
                  fontWeight: FontWeight.w700,
                )),
            Expanded(
                child: Text(question,
                    style: RobinTheme.bodySm.copyWith(fontSize: 11))),
            const Icon(Icons.chevron_right,
                size: 14, color: RobinTheme.textMuted),
          ],
        ),
      );
}

class _MoreBtn extends StatelessWidget {
  final VoidCallback onPressed;
  const _MoreBtn({required this.onPressed});

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('더보기',
                style: RobinTheme.bodySm.copyWith(
                  color: RobinTheme.accent,
                  fontSize: 11,
                )),
            const Icon(Icons.chevron_right, size: 13, color: RobinTheme.accent),
          ],
        ),
      );
}
