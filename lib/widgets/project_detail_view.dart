import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order_project.dart';
import '../theme/robin_theme.dart';

class ProjectDetailView extends StatelessWidget {
  final OrderProject project;
  final VoidCallback onBack;

  const ProjectDetailView({
    super.key,
    required this.project,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final amountFormat = NumberFormat('#,###');
    final daysLeft = project.dueDate.difference(DateTime.now()).inDays;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SummaryCard(
                label: '고객사',
                value: project.customer,
                icon: Icons.business_outlined,
                color: RobinTheme.primary,
              ),
              _SummaryCard(
                label: '수주금액',
                value: '${amountFormat.format(project.amount)} 만원',
                icon: Icons.payments_outlined,
                color: RobinTheme.signalGreen,
              ),
              _SummaryCard(
                label: '납기일',
                value: dateFormat.format(project.dueDate),
                sub: daysLeft >= 0 ? 'D-$daysLeft' : 'D+${daysLeft.abs()}',
                icon: Icons.event_outlined,
                color: daysLeft < 30
                    ? RobinTheme.signalRed
                    : RobinTheme.signalYellow,
              ),
              _SummaryCard(
                label: '전체 진행률',
                value: '${project.progress}%',
                icon: Icons.donut_large_outlined,
                color: RobinTheme.accent,
                progress: project.progress / 100,
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 900;
              final information = _InformationCard(project: project);
              final schedule = _ScheduleCard(project: project);
              if (compact) {
                return Column(children: [
                  information,
                  const SizedBox(height: 14),
                  schedule,
                ]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: information),
                  const SizedBox(width: 14),
                  Expanded(child: schedule),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          _ProgressTimeline(project: project),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 900;
              final product = _ProductSpecificationCard(project: project);
              final history = _ChangeHistoryCard(project: project);
              if (compact) {
                return Column(children: [
                  product,
                  const SizedBox(height: 14),
                  history,
                ]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: product),
                  const SizedBox(width: 14),
                  Expanded(child: history),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Center(
            child: Text('© 2027 ROBOSTAR Co., Ltd. All Rights Reserved.',
                style: RobinTheme.labelXs),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 17),
            label: const Text('목록으로'),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(project.orderNo,
                      style: RobinTheme.headingSm
                          .copyWith(color: RobinTheme.accent)),
                  const SizedBox(width: 8),
                  _StatusBadge(status: project.status),
                  const SizedBox(width: 6),
                  _CategoryBadge(category: project.category),
                ]),
                const SizedBox(height: 7),
                Text(project.projectName, style: RobinTheme.headingLg),
                const SizedBox(height: 4),
                Text('수주 및 프로젝트 상세정보와 단계별 진행 현황입니다.', style: RobinTheme.bodySm),
              ],
            ),
          ),
        ],
      );
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final IconData icon;
  final Color color;
  final double? progress;

  const _SummaryCard({
    required this.label,
    required this.value,
    this.sub,
    required this.icon,
    required this.color,
    this.progress,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: 218,
        height: 112,
        padding: const EdgeInsets.all(15),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: 9),
              Text(label, style: RobinTheme.labelXs),
              if (sub != null) ...[
                const Spacer(),
                Text(sub!,
                    style: RobinTheme.labelXs
                        .copyWith(color: color, fontWeight: FontWeight.w700)),
              ],
            ]),
            const Spacer(),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: RobinTheme.headingSm.copyWith(fontSize: 16)),
            if (progress != null) ...[
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: RobinTheme.divider,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      );
}

class _InformationCard extends StatelessWidget {
  final OrderProject project;
  const _InformationCard({required this.project});

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: '기본 정보',
        icon: Icons.description_outlined,
        child: Column(children: [
          _InfoRow(label: '수주번호', value: project.orderNo),
          _InfoRow(label: '프로젝트명', value: project.projectName),
          _InfoRow(label: '프로젝트 구분', value: project.category),
          _InfoRow(label: '프로젝트 종류', value: project.projectType),
          _InfoRow(label: '고객사', value: project.customer),
          const _InfoRow(label: '영업 담당자', value: '김영업 과장'),
          const _InfoRow(label: '프로젝트 담당자', value: '박로빈 사원'),
        ]),
      );
}

class _ScheduleCard extends StatelessWidget {
  final OrderProject project;
  const _ScheduleCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('yyyy-MM-dd');
    final registered = project.lastUpdated.subtract(const Duration(days: 40));
    return _SectionCard(
      title: '일정·납기 정보',
      icon: Icons.calendar_month_outlined,
      child: Column(children: [
        _InfoRow(label: '수주 등록일', value: format.format(registered)),
        _InfoRow(
            label: '설계 완료 예정',
            value: format.format(registered.add(const Duration(days: 14)))),
        _InfoRow(
            label: '구매 완료 예정',
            value: format.format(registered.add(const Duration(days: 25)))),
        _InfoRow(
            label: '생산 완료 예정',
            value: format
                .format(project.dueDate.subtract(const Duration(days: 10)))),
        _InfoRow(
            label: '출하 예정일',
            value: format
                .format(project.dueDate.subtract(const Duration(days: 3)))),
        _InfoRow(
            label: '납기 예정일',
            value: format.format(project.dueDate),
            valueColor: project.dueDate.isBefore(DateTime.now())
                ? RobinTheme.error
                : RobinTheme.textPrimary),
        _InfoRow(label: '최종 업데이트', value: format.format(project.lastUpdated)),
      ]),
    );
  }
}

class _ProgressTimeline extends StatelessWidget {
  final OrderProject project;
  const _ProgressTimeline({required this.project});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('수주', project.stepOrder),
      ('설계', project.stepDesign),
      ('구매', project.stepPurchase),
      ('생산', project.stepProduction),
      ('납품/설치', project.stepDelivery),
      ('운전/검수', project.stepOperation),
    ];
    final firstPending = steps.indexWhere((step) => !step.$2);
    final format = DateFormat('MM-dd');

    return _SectionCard(
      title: '단계별 진행 현황',
      icon: Icons.account_tree_outlined,
      trailing: Text('전체 ${project.progress}%',
          style: RobinTheme.headingSm.copyWith(color: RobinTheme.primary)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < steps.length; index++) ...[
            Expanded(
              child: _StageItem(
                label: steps[index].$1,
                done: steps[index].$2,
                current: index == firstPending,
                date: steps[index].$2
                    ? format.format(project.lastUpdated
                        .subtract(Duration(days: (steps.length - index) * 3)))
                    : null,
              ),
            ),
            if (index < steps.length - 1)
              Container(
                height: 2,
                margin: const EdgeInsets.only(top: 17),
                width: 28,
                color: steps[index].$2
                    ? RobinTheme.success.withValues(alpha: .4)
                    : RobinTheme.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _StageItem extends StatelessWidget {
  final String label;
  final bool done;
  final bool current;
  final String? date;

  const _StageItem({
    required this.label,
    required this.done,
    required this.current,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final color = done
        ? RobinTheme.success
        : current
            ? RobinTheme.signalYellow
            : RobinTheme.textMuted;
    return Column(children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: done ? color : RobinTheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: done
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : Icon(current ? Icons.more_horiz : Icons.circle_outlined,
                size: 16, color: color),
      ),
      const SizedBox(height: 8),
      Text(label,
          textAlign: TextAlign.center,
          style: RobinTheme.bodySm
              .copyWith(color: color, fontWeight: FontWeight.w700)),
      const SizedBox(height: 3),
      Text(
          done
              ? date ?? '완료'
              : current
                  ? '진행 중'
                  : '대기',
          style: RobinTheme.labelXs),
    ]);
  }
}

class _ProductSpecificationCard extends StatelessWidget {
  final OrderProject project;
  const _ProductSpecificationCard({required this.project});

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: '제품·사양',
        icon: Icons.precision_manufacturing_outlined,
        child: Column(children: [
          _InfoRow(label: '제품 군', value: project.projectType),
          _InfoRow(
              label: '제품 모델',
              value: project.category == '로봇' ? 'RSN-080' : 'RBN-CTRL-01'),
          const _InfoRow(label: '수량', value: '1 세트'),
          const _InfoRow(label: '주요 사양', value: '고객 요청 자동화 공정 적용'),
          const _InfoRow(label: '선택 옵션', value: '표준 안전 패키지'),
          const _InfoRow(label: '첨부 문서', value: '견적서.pdf, 제품사양서.pdf'),
        ]),
      );
}

class _ChangeHistoryCard extends StatelessWidget {
  final OrderProject project;
  const _ChangeHistoryCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('yyyy-MM-dd HH:mm');
    final history = [
      (
        format.format(project.lastUpdated),
        '김영업 과장',
        '진행률 ${project.progress}% 업데이트'
      ),
      (
        format.format(project.lastUpdated.subtract(const Duration(days: 3))),
        '김로빈 책임',
        '프로젝트 담당자 배정'
      ),
      (
        format.format(project.lastUpdated.subtract(const Duration(days: 10))),
        '시스템',
        '수주 등록 및 ERP 연계'
      ),
    ];
    return _SectionCard(
      title: '최근 변경 이력',
      icon: Icons.history,
      child: Column(
        children: history
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 5),
                        decoration: const BoxDecoration(
                            color: RobinTheme.primary, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.$3, style: RobinTheme.bodyMd),
                            const SizedBox(height: 2),
                            Text('${item.$1} · ${item.$2}',
                                style: RobinTheme.labelXs),
                          ],
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

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 19, color: RobinTheme.primary),
              const SizedBox(width: 8),
              Text(title, style: RobinTheme.headingSm),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ]),
            const SizedBox(height: 16),
            child,
          ],
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 125, child: Text(label, style: RobinTheme.labelXs)),
            Expanded(
              child: Text(value,
                  style: RobinTheme.bodyMd.copyWith(
                      color: valueColor, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: RobinTheme.statusBg(status),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(status,
            style: RobinTheme.labelXs.copyWith(
                color: RobinTheme.statusFg(status),
                fontWeight: FontWeight.w700)),
      );
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: RobinTheme.accentLight,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(category,
            style: RobinTheme.labelXs.copyWith(
                color: RobinTheme.accent, fontWeight: FontWeight.w700)),
      );
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: RobinTheme.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: RobinTheme.border),
    );
