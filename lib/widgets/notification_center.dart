import 'package:flutter/material.dart';

import '../theme/robin_theme.dart';

enum RobinNotificationType { assignment, schedule, approval, update }

class RobinNotification {
  final String id;
  final RobinNotificationType type;
  final String title;
  final String message;
  final String projectNo;
  final String projectName;
  final String createdAt;
  final String? dueDate;
  final bool isRead;

  const RobinNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.projectNo,
    required this.projectName,
    required this.createdAt,
    this.dueDate,
    this.isRead = false,
  });
}

const robinNotifications = <RobinNotification>[
  RobinNotification(
    id: 'NT-260728-001',
    type: RobinNotificationType.assignment,
    title: '설계 검토 담당자로 배정되었습니다.',
    message: 'ERP에서 RB-2607-014 프로젝트의 설계 검토 담당자가 김로빈 책임으로 변경되었습니다.',
    projectNo: 'RB-2607-014',
    projectName: 'A사 자동화라인 증설',
    createdAt: '2026-07-28 10:32',
    dueDate: '2026-07-30',
  ),
  RobinNotification(
    id: 'NT-260728-002',
    type: RobinNotificationType.assignment,
    title: '구매 단계 업무가 배정되었습니다.',
    message: 'ERP 단계 변경 결과에 따라 구매품 발주 확인 업무가 배정되었습니다.',
    projectNo: 'RB-2607-009',
    projectName: 'C사 물류 시스템',
    createdAt: '2026-07-28 09:58',
    dueDate: '2026-08-02',
  ),
  RobinNotification(
    id: 'NT-260727-006',
    type: RobinNotificationType.schedule,
    title: '납기 임박 프로젝트가 있습니다.',
    message: '프로젝트 납기까지 2일 남았습니다. 진행 상태와 미완료 업무를 확인하세요.',
    projectNo: 'RB-2607-011',
    projectName: 'B사 로봇 증설',
    createdAt: '2026-07-27 16:20',
    dueDate: '2026-07-30',
  ),
  RobinNotification(
    id: 'NT-260727-003',
    type: RobinNotificationType.approval,
    title: 'AX Board 접근 권한이 승인되었습니다.',
    message: '구매 분석 Python 앱의 링크 접근 권한이 승인되어 지금부터 사용할 수 있습니다.',
    projectNo: '-',
    projectName: '구매 분석 대시보드',
    createdAt: '2026-07-27 14:10',
    isRead: true,
  ),
  RobinNotification(
    id: 'NT-260726-009',
    type: RobinNotificationType.update,
    title: '수주 단계가 변경되었습니다.',
    message: 'RB-2607-006 수주의 단계가 Proposal에서 Negotiation으로 변경되었습니다.',
    projectNo: 'RB-2607-006',
    projectName: 'D사 제어 시스템',
    createdAt: '2026-07-26 11:05',
    isRead: true,
  ),
];

int get unreadRobinNotificationCount =>
    robinNotifications.where((item) => !item.isRead).length;

Future<void> showRobinNotificationCenter(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      alignment: Alignment.topRight,
      insetPadding: const EdgeInsets.only(top: 62, right: 22, bottom: 24),
      child: SizedBox(
        width: 430,
        height: 540,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 10, 12),
              child: Row(
                children: [
                  Text('알림 기록',
                      style: RobinTheme.headingSm.copyWith(fontSize: 15)),
                  const SizedBox(width: 8),
                  _CountBadge(count: unreadRobinNotificationCount),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close, size: 19),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: RobinNotificationList(
                onSelected: (notification) async {
                  Navigator.pop(dialogContext);
                  await showRobinNotificationDetail(context, notification);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showRobinNotificationDetail(
  BuildContext context,
  RobinNotification notification,
) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(22, 20, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(
        children: [
          _NotificationIcon(type: notification.type),
          const SizedBox(width: 10),
          Expanded(
              child: Text(notification.title, style: RobinTheme.headingSm)),
          IconButton(
            onPressed: () => Navigator.pop(dialogContext),
            icon: const Icon(Icons.close, size: 19),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message, style: RobinTheme.bodyMd),
            const SizedBox(height: 18),
            _DetailRow(label: '알림 ID', value: notification.id),
            _DetailRow(label: '프로젝트 번호', value: notification.projectNo),
            _DetailRow(label: '프로젝트명', value: notification.projectName),
            if (notification.dueDate != null)
              _DetailRow(label: '처리 기한', value: notification.dueDate!),
            _DetailRow(label: '알림 일시', value: notification.createdAt),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RobinTheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                notification.type == RobinNotificationType.assignment
                    ? 'ERP에서 배정된 업무를 처리한 뒤 ROBIN에서 진행 상태를 확인하세요.'
                    : '관련 프로젝트 상세 화면에서 최신 상태를 확인하세요.',
                style: RobinTheme.bodySm,
              ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('닫기'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(dialogContext),
          icon: const Icon(Icons.open_in_new, size: 16),
          label: Text(notification.type == RobinNotificationType.assignment
              ? 'ERP 업무 확인'
              : '관련 화면 확인'),
        ),
      ],
    ),
  );
}

class RobinNotificationList extends StatelessWidget {
  final ValueChanged<RobinNotification> onSelected;
  final int? maxItems;

  const RobinNotificationList({
    super.key,
    required this.onSelected,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    final items = maxItems == null
        ? robinNotifications
        : robinNotifications.take(maxItems!).toList();
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 58),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () => onSelected(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            color: item.isRead
                ? Colors.transparent
                : RobinTheme.accentLight.withValues(alpha: .42),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NotificationIcon(type: item.type),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: RobinTheme.headingSm
                                    .copyWith(fontSize: 12)),
                          ),
                          if (!item.isRead)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: RobinTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${item.projectNo} · ${item.projectName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: RobinTheme.bodySm),
                      const SizedBox(height: 5),
                      Text(item.createdAt, style: RobinTheme.labelXs),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    size: 17, color: RobinTheme.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final RobinNotificationType type;
  const _NotificationIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      RobinNotificationType.assignment => (
          Icons.assignment_ind_outlined,
          const Color(0xFF4F46E5)
        ),
      RobinNotificationType.schedule => (
          Icons.schedule_outlined,
          RobinTheme.signalYellow
        ),
      RobinNotificationType.approval => (
          Icons.approval_outlined,
          RobinTheme.signalGreen
        ),
      RobinNotificationType.update => (
          Icons.sync_alt_outlined,
          RobinTheme.primary
        ),
    };
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 105, child: Text(label, style: RobinTheme.labelXs)),
            Expanded(child: Text(value, style: RobinTheme.bodySm)),
          ],
        ),
      );
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: RobinTheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('$count',
            style: const TextStyle(color: Colors.white, fontSize: 10)),
      );
}
