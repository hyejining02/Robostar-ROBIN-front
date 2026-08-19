import 'package:flutter/material.dart';
import '../models/order_project.dart';
import '../theme/robin_theme.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String? sub1Label;
  final String? sub1Value;
  final String? sub2Label;
  final String? sub2Value;
  final bool isSelected;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    this.sub1Label,
    this.sub1Value,
    this.sub2Label,
    this.sub2Value,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RobinTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? RobinTheme.accent : RobinTheme.border,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                    color: RobinTheme.accent.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1))
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(label,
              style: RobinTheme.bodySm
                  .copyWith(fontSize: 11, color: RobinTheme.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: RobinTheme.numericMd),
          if (sub1Label != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _SubStat(label: sub1Label!, value: sub1Value ?? ''),
                const SizedBox(width: 12),
                if (sub2Label != null)
                  _SubStat(label: sub2Label!, value: sub2Value ?? ''),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SubStat extends StatelessWidget {
  final String label;
  final String value;
  const _SubStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: RobinTheme.labelXs),
        const SizedBox(width: 3),
        Text(value,
            style: RobinTheme.labelXs.copyWith(
              color: RobinTheme.textSecondary,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}

// ── 카드 그룹 ─────────────────────────────────────────────
class StatCardsRow extends StatelessWidget {
  const StatCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final added = SampleData.projects.length - SampleData.initialProjectCount;
    final registered = added < 0 ? 0 : added;
    return Row(
      children: [
        Expanded(
            child: StatCard(
          icon: Icons.receipt_long_outlined,
          iconColor: RobinTheme.primaryLight,
          iconBg: RobinTheme.accentLight,
          label: '전체 수주',
          value: '${28 + registered} 건',
          sub1Label: '로봇',
          sub1Value: '${16 + registered}건',
          sub2Label: '플랫폼',
          sub2Value: '12건',
        )),
        const SizedBox(width: 12),
        Expanded(
            child: StatCard(
          icon: Icons.play_circle_outline,
          iconColor: RobinTheme.accent,
          iconBg: RobinTheme.accentLight,
          label: '진행 중',
          value: '${18 + registered} 건',
          sub1Label: '로봇',
          sub1Value: '${11 + registered}건',
          sub2Label: '플랫폼',
          sub2Value: '7건',
        )),
        const SizedBox(width: 12),
        Expanded(
            child: StatCard(
          icon: Icons.check_circle_outline,
          iconColor: RobinTheme.success,
          iconBg: RobinTheme.successLight,
          label: '완료 (Success)',
          value: '7 건',
          sub1Label: '로봇',
          sub1Value: '4건',
          sub2Label: '플랫폼',
          sub2Value: '3건',
        )),
        const SizedBox(width: 12),
        Expanded(
            child: StatCard(
          icon: Icons.cancel_outlined,
          iconColor: RobinTheme.error,
          iconBg: RobinTheme.errorLight,
          label: '중단/Drop',
          value: '3 건',
          sub1Label: '로봇',
          sub1Value: '1건',
          sub2Label: '플랫폼',
          sub2Value: '2건',
        )),
        const SizedBox(width: 12),
        Expanded(
            child: StatCard(
          icon: Icons.fiber_new_outlined,
          iconColor: RobinTheme.pending,
          iconBg: RobinTheme.pendingLight,
          label: '금월 신규 수주',
          value: '${5 + registered} 건',
          sub1Label: '로봇',
          sub1Value: '${3 + registered}건',
          sub2Label: '플랫폼',
          sub2Value: '2건',
        )),
      ],
    );
  }
}
