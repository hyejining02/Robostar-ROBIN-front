import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_project.dart';
import '../theme/robin_theme.dart';

class ProjectDetailPanel extends StatelessWidget {
  final OrderProject? project;
  final VoidCallback? onViewDetails;

  const ProjectDetailPanel({super.key, this.project, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    if (project == null) {
      return Container(
        width: 280,
        decoration: const BoxDecoration(
          color: RobinTheme.surface,
          border: Border(left: BorderSide(color: RobinTheme.border)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app_outlined,
                  size: 40, color: RobinTheme.textMuted),
              const SizedBox(height: 12),
              Text('프로젝트를 선택하세요', style: RobinTheme.bodySm),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: RobinTheme.surface,
        border: Border(left: BorderSide(color: RobinTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(),
                  const SizedBox(height: 20),
                  _buildDetailButton(),
                  const SizedBox(height: 20),
                  _buildTimeline(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: RobinTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('선택 프로젝트 상세', style: RobinTheme.labelXs),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(project!.orderNo,
                  style: RobinTheme.headingSm.copyWith(
                    color: RobinTheme.accent,
                  )),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: RobinTheme.statusBg(project!.status),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(project!.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: RobinTheme.statusFg(project!.status),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(project!.projectName,
              style: RobinTheme.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(project!.category,
                style: const TextStyle(
                  fontSize: 11,
                  color: RobinTheme.accent,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final fmt = NumberFormat('#,###');
    final dateFmt = DateFormat('yyyy-MM-dd');

    final daysLeft = project!.dueDate.difference(DateTime.now()).inDays;
    final dueDateColor = daysLeft < 0
        ? RobinTheme.error
        : daysLeft < 30
            ? RobinTheme.warning
            : RobinTheme.textSecondary;

    return Column(
      children: [
        _InfoRow(label: '고객사', value: project!.customer),
        _InfoRow(
          label: '수주금액',
          value: '${fmt.format(project!.amount)} 만원',
          valueStyle: RobinTheme.headingSm,
        ),
        _InfoRow(label: '담당자', value: '김영업 과장 (로보스타)'),
        _InfoRow(
          label: '납기일',
          value:
              '${dateFmt.format(project!.dueDate)} (D${daysLeft >= 0 ? '-' : '+'}${daysLeft.abs()})',
          valueStyle: RobinTheme.bodySm
              .copyWith(color: dueDateColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDetailButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onViewDetails,
        style: ElevatedButton.styleFrom(
          backgroundColor: RobinTheme.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text('상세보기',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }

  Widget _buildTimeline() {
    final steps = [
      _TimelineStep(
        label: '수주',
        date: '2024-04-10',
        sub: '수주 등록 완료',
        status: _StepStatus.done,
      ),
      _TimelineStep(
        label: '설계',
        date: '2024-04-25',
        sub: '설계 완료',
        status: _StepStatus.done,
      ),
      _TimelineStep(
        label: '구매',
        date: null,
        sub: '부품 발주 진행 중',
        status: _StepStatus.inProgress,
      ),
      _TimelineStep(
        label: '생산',
        date: null,
        sub: '생산 대기 중',
        status: _StepStatus.pending,
      ),
      _TimelineStep(
        label: '납품/설치',
        date: null,
        sub: null,
        status: _StepStatus.pending,
      ),
      _TimelineStep(
        label: '운전/검수',
        date: null,
        sub: null,
        status: _StepStatus.pending,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('진행 단계 타임라인', style: RobinTheme.headingSm.copyWith(fontSize: 12)),
        const SizedBox(height: 12),
        ...steps
            .asMap()
            .entries
            .map((e) => _buildTimelineItem(e.value, e.key == steps.length - 1)),
      ],
    );
  }

  Widget _buildTimelineItem(_TimelineStep step, bool isLast) {
    Color dotColor;
    Widget dotWidget;

    switch (step.status) {
      case _StepStatus.done:
        dotColor = RobinTheme.success;
        dotWidget = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          child: const Icon(Icons.check, size: 12, color: Colors.white),
        );
      case _StepStatus.inProgress:
        dotColor = RobinTheme.warning;
        dotWidget = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: dotColor, width: 2),
          ),
          child: Center(
              child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          )),
        );
      case _StepStatus.pending:
        dotColor = RobinTheme.border;
        dotWidget = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: dotColor, width: 2),
            color: RobinTheme.surface,
          ),
        );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타임라인 라인
          Column(
            children: [
              dotWidget,
              if (!isLast)
                Expanded(
                    child: Container(
                  width: 2,
                  color: step.status == _StepStatus.done
                      ? RobinTheme.success.withOpacity(0.3)
                      : RobinTheme.border,
                )),
            ],
          ),
          const SizedBox(width: 12),
          // 내용
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(step.label,
                          style: RobinTheme.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: step.status == _StepStatus.pending
                                ? RobinTheme.textMuted
                                : RobinTheme.textPrimary,
                          )),
                      if (step.date != null) ...[
                        const Spacer(),
                        Text(step.date!, style: RobinTheme.labelXs),
                      ],
                    ],
                  ),
                  if (step.sub != null) ...[
                    const SizedBox(height: 2),
                    Text(step.sub!,
                        style: RobinTheme.bodySm.copyWith(fontSize: 11)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepStatus { done, inProgress, pending }

class _TimelineStep {
  final String label;
  final String? date;
  final String? sub;
  final _StepStatus status;
  const _TimelineStep({
    required this.label,
    required this.date,
    required this.sub,
    required this.status,
  });
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  const _InfoRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(label,
                style: RobinTheme.bodySm.copyWith(
                  color: RobinTheme.textMuted,
                  fontSize: 11,
                )),
          ),
          Expanded(
            child: Text(value,
                style: valueStyle ??
                    RobinTheme.bodyMd.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
          ),
        ],
      ),
    );
  }
}
