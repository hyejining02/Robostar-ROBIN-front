import 'package:flutter/foundation.dart';

import '../models/access_control.dart';
import '../widgets/user_profile.dart';
import 'business_division_scope.dart';
import 'platform_review_service.dart';
import 'product_identity_service.dart';
import 'project_todo_service.dart';
import 'robot_design_review_service.dart';

enum DesignWorkKind {
  review('검토 요청서'),
  order('수주 업무'),
  other('기타 업무');

  const DesignWorkKind(this.label);
  final String label;
}

enum DesignWorkStatus {
  unknown('미확인'),
  working('진행'),
  held('보류'),
  done('완료');

  const DesignWorkStatus(this.label);
  final String label;
}

class DesignOrderSource {
  final RobinBusinessDivision division;
  final String number;
  final String project;
  final String model;
  final String due;
  final String stage;
  final bool urgent;
  const DesignOrderSource(
      {required this.division,
      required this.number,
      required this.project,
      required this.model,
      required this.due,
      required this.stage,
      this.urgent = false});
}

@immutable
class OtherDesignTask {
  final String id;
  final RobinBusinessDivision division;
  final String type;
  final String reference;
  final String title;
  final String assignee;
  final String due;
  final String orderReference;
  final String notes;
  final String author;
  final DateTime at;
  const OtherDesignTask(
      {required this.id,
      required this.division,
      required this.type,
      required this.reference,
      required this.title,
      required this.assignee,
      required this.due,
      required this.orderReference,
      required this.notes,
      required this.author,
      required this.at});
}

@immutable
class DesignWorkItem {
  final String id;
  final DesignWorkKind kind;
  final RobinBusinessDivision division;
  final String number;
  final String title;
  final String assignee;
  final String due;
  final DesignWorkStatus status;
  final String sourceStatus;
  final bool urgent;
  final int sourceVersion;
  final ProductIdentityKey? robotKey;
  final String? platformId;
  final String? otherId;
  const DesignWorkItem(
      {required this.id,
      required this.kind,
      required this.division,
      required this.number,
      required this.title,
      required this.assignee,
      required this.due,
      required this.status,
      required this.sourceStatus,
      this.urgent = false,
      this.sourceVersion = 0,
      this.robotKey,
      this.platformId,
      this.otherId});
  DesignWorkChange? get management => designWorkChanges.value[id]?.lastOrNull;
  DesignWorkStatus get displayStatus =>
      kind == DesignWorkKind.review ? status : management?.status ?? status;
  String get displayAssignee => kind == DesignWorkKind.review
      ? assignee
      : management?.assignee ?? assignee;
  String get displayDue =>
      kind == DesignWorkKind.review ? due : management?.due ?? due;
  bool get displayUrgent => management?.urgent ?? urgent;
  String get token =>
      '$sourceVersion:${designWorkChanges.value[id]?.length ?? 0}';
}

@immutable
class DesignWorkChange {
  final DesignWorkStatus status;
  final String assignee;
  final String due;
  final bool urgent;
  final String reason;
  final String author;
  final DateTime at;
  final List<String> differences;
  DesignWorkChange(
      {required this.status,
      required this.assignee,
      required this.due,
      required this.urgent,
      required this.reason,
      required this.author,
      required this.at,
      required List<String> differences})
      : differences = List.unmodifiable(differences);
}

final otherDesignTasks = ValueNotifier<List<OtherDesignTask>>([]);
final designWorkChanges =
    ValueNotifier<Map<String, List<DesignWorkChange>>>({});
int _otherDesignSequence = 0;

bool get canReadDesignWork =>
    !robinUserProfile.value.isDealer &&
    BusinessDivisionScope.current().allowed.isNotEmpty;
bool get canManageDesignWork =>
    canReadDesignWork &&
    (robinUserProfile.value.isAdmin ||
        robinUserProfile.value.departmentPermission ==
            RobinDepartmentPermission.engineering);
bool mayManageDesignItem(DesignWorkItem item) {
  if (!canManageDesignWork ||
      !BusinessDivisionScope.current().includes(item.division)) {
    return false;
  }
  final profile = robinUserProfile.value;
  return profile.isAdmin ||
      (item.displayAssignee.isEmpty && item.kind != DesignWorkKind.review) ||
      [profile.name, '${profile.name} ${profile.rank}']
          .contains(item.displayAssignee);
}

List<DesignWorkItem> collectDesignWork(
    {List<DesignOrderSource> orders = const [], BusinessDivisionScope? scope}) {
  final view = scope ?? BusinessDivisionScope.current();
  if (robinUserProfile.value.isDealer) return [];
  final items = <DesignWorkItem>[];
  for (final e in robotDesignReviews.value.entries) {
    final r = e.value;
    items.add(DesignWorkItem(
        id: 'robot:${e.key.$1.name}:${e.key.$2}',
        kind: DesignWorkKind.review,
        division: e.key.$1,
        number: e.key.$2,
        title: '${r.projectName.isEmpty ? e.key.$2 : r.projectName} · 로봇 검토',
        assignee: r.content.fields['designer'] ?? '',
        due: r.content.fields['due'] ?? '',
        status: switch (r.status) {
          RobotReviewStatus.draft => DesignWorkStatus.unknown,
          RobotReviewStatus.changes ||
          RobotReviewStatus.rejected =>
            DesignWorkStatus.held,
          RobotReviewStatus.completed => DesignWorkStatus.done,
          _ => DesignWorkStatus.working
        },
        sourceStatus: '로봇 ${r.status.label} · 요청 Rev.${r.revision}',
        sourceVersion: r.version,
        robotKey: e.key));
  }
  for (final r in platformReviews.value) {
    for (final kind in r.request.kinds) {
      final reply = r.replyFor(kind);
      items.add(DesignWorkItem(
          id: 'platform:${r.id}:${kind.name}',
          kind: DesignWorkKind.review,
          division: RobinBusinessDivision.platformModule,
          number: r.request.fields['sl']!,
          title: '${r.request.fields['project']} · ${kind.label} 검토',
          assignee: r.request.fields['designer'] ?? '',
          due: reply?.status == PlatformReplyStatus.reviewing
              ? reply!.expectedDate
              : r.request.fields['due'] ?? '',
          status: switch (reply?.status) {
            PlatformReplyStatus.done => DesignWorkStatus.done,
            PlatformReplyStatus.reviewing => DesignWorkStatus.working,
            _ => DesignWorkStatus.unknown
          },
          sourceStatus:
              '플랫폼 ${kind.label} ${reply?.status.label ?? '미확인'} · 요청 Rev.${r.request.revision}',
          sourceVersion: r.version,
          platformId: r.id));
    }
  }
  for (final order in orders) {
    items.add(DesignWorkItem(
        id: 'order:${order.division.name}:${order.number}',
        kind: DesignWorkKind.order,
        division: order.division,
        number: order.number,
        title: '${order.project} · ${order.model}',
        assignee: '',
        due: order.due,
        status: DesignWorkStatus.unknown,
        urgent: order.urgent,
        sourceStatus: '프로젝트 ${order.stage} · 설계 완료 여부 미연동'));
  }
  for (final task in otherDesignTasks.value) {
    items.add(DesignWorkItem(
        id: 'other:${task.id}',
        kind: DesignWorkKind.other,
        division: task.division,
        number: task.reference.isEmpty ? task.id : task.reference,
        title: '${task.type} · ${task.title}',
        assignee: task.assignee,
        due: task.due,
        status: DesignWorkStatus.unknown,
        sourceStatus: '${task.type} 원본 참조 · 수동 등록/원본 연계 미확인',
        otherId: task.id));
  }
  final seen = <String>{};
  return items
      .where((item) => view.includes(item.division) && seen.add(item.id))
      .toList();
}

OtherDesignTask createOtherDesignTask(
    {required RobinBusinessDivision division,
    required String type,
    required String reference,
    required String title,
    required String assignee,
    required String due,
    String orderReference = '',
    String notes = ''}) {
  if (!canManageDesignWork ||
      !BusinessDivisionScope.current().includes(division)) {
    throw StateError('등록 권한이 없습니다.');
  }
  if (!['서비스요청', '불량', '기타'].contains(type)) throw StateError('업무 유형을 확인해주세요.');
  if (title.trim().isEmpty || assignee.trim().isEmpty) {
    throw StateError('업무명과 담당자를 입력해주세요.');
  }
  if (type != '기타' && reference.trim().isEmpty) {
    throw StateError('서비스/불량 업무의 원본 접수번호를 입력해주세요.');
  }
  if (due.trim().isNotEmpty && !validPlatformDate(due.trim())) {
    throw StateError('업무 기한은 YYYY-MM-DD로 입력해주세요.');
  }
  if (reference.trim().isNotEmpty &&
      otherDesignTasks.value.any((r) =>
          r.division == division &&
          r.type == type &&
          r.reference.toUpperCase() == reference.trim().toUpperCase())) {
    throw StateError('동일 원본의 설계 업무가 있습니다. 기존 업무를 사용해주세요.');
  }
  final user = robinUserProfile.value;
  if (!user.isAdmin &&
      ![user.name, '${user.name} ${user.rank}'].contains(assignee.trim())) {
    throw StateError('현재 시안에서는 본인에게 배정한 업무만 등록할 수 있습니다.');
  }
  final now = DateTime.now();
  final task = OtherDesignTask(
      id: 'design-other-${now.microsecondsSinceEpoch}-${++_otherDesignSequence}',
      division: division,
      type: type,
      reference: reference.trim(),
      title: title.trim(),
      assignee: assignee.trim(),
      due: due.trim(),
      orderReference: orderReference.trim(),
      notes: notes.trim(),
      author: '${user.name} ${user.rank}',
      at: now);
  otherDesignTasks.value = [...otherDesignTasks.value, task];
  return task;
}

void updateDesignWork(
    {required String id,
    required String expectedToken,
    required List<DesignOrderSource> orders,
    required DesignWorkStatus status,
    required String assignee,
    required String due,
    required bool urgent,
    required String reason}) {
  final item =
      collectDesignWork(orders: orders).where((r) => r.id == id).firstOrNull;
  if (item == null || !mayManageDesignItem(item)) {
    throw StateError('수정할 수 없는 업무입니다.');
  }
  if (item.token != expectedToken) {
    throw StateError('원본/관리값이 변경되었습니다. 다시 열어주세요.');
  }
  if (reason.trim().isEmpty) throw StateError('변경 사유를 입력해주세요.');
  if (item.kind == DesignWorkKind.review &&
      (status != item.status ||
          assignee.trim() != item.assignee ||
          due.trim() != item.due)) {
    throw StateError('검토 상태·담당자·기한은 원본 요청서에서 변경해주세요.');
  }
  if (due.trim().isNotEmpty && !validPlatformDate(due.trim())) {
    throw StateError('업무 기한은 YYYY-MM-DD로 입력해주세요.');
  }
  final user = robinUserProfile.value;
  if (!user.isAdmin &&
      ![user.name, '${user.name} ${user.rank}'].contains(assignee.trim())) {
    throw StateError('다른 담당자로 재배정하는 권한은 확인 전입니다.');
  }
  final differences = <String>[];
  if (status != item.displayStatus) {
    differences.add('상태: ${item.displayStatus.label} → ${status.label}');
  }
  if (assignee.trim() != item.displayAssignee) {
    differences.add('담당자: ${item.displayAssignee} → ${assignee.trim()}');
  }
  if (due.trim() != item.displayDue) {
    differences.add('기한: ${item.displayDue} → ${due.trim()}');
  }
  if (urgent != item.displayUrgent) {
    differences.add('긴급: ${item.displayUrgent} → $urgent');
  }
  if (differences.isEmpty) return;
  final now = DateTime.now();
  final change = DesignWorkChange(
      status: status,
      assignee: assignee.trim(),
      due: due.trim(),
      urgent: urgent,
      reason: reason.trim(),
      author: '${user.name} ${user.rank}',
      at: now,
      differences: differences);
  final wasUrgent = item.displayUrgent;
  designWorkChanges.value = {
    ...designWorkChanges.value,
    id: List.unmodifiable([...?designWorkChanges.value[id], change])
  };
  if (urgent && !wasUrgent && assignee.trim().isNotEmpty) {
    addProjectTodo(ProjectTodoItem(
        id: '$id:urgent:${designWorkChanges.value[id]!.length}',
        orderNo: item.number,
        projectName: item.title,
        stage: '설계',
        assignee: assignee.trim(),
        task: '긴급 설계 업무 · ${reason.trim()}',
        createdBy: '${user.name} ${user.rank}',
        createdAt: now.toIso8601String(),
        division: item.division,
        sourceLabel: '설계 업무관리',
        navigationIndex: 3));
  }
}
