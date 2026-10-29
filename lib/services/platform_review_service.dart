import 'package:flutter/foundation.dart';

import '../models/access_control.dart';
import '../widgets/user_profile.dart';
import 'business_division_scope.dart';
import 'desktop_file_service.dart';
import 'project_todo_service.dart';

enum PlatformReviewKind {
  material('재료비'),
  layout('레이아웃');

  const PlatformReviewKind(this.label);
  final String label;
}

enum PlatformReplyStatus {
  unchecked('미확인'),
  reviewing('검토중'),
  done('검토완');

  const PlatformReplyStatus(this.label);
  final String label;
}

const platformRequestLabels = <String, String>{
  'sl': 'SL CODE',
  'project': '프로젝트명',
  'customer': '고객사',
  'sales': '영업담당자',
  'designer': '설계담당자',
  'due': '회신 기한',
  'cc': '참조자',
  'object': '이재물',
  'stroke': 'Stroke(mm)',
  'load': '하중(kg)',
  'warpage': 'Warpage(mm)',
  'spec': '세부 요청 스펙·고객 협의 내용',
  'quote': '견적 참조번호',
  'order': '수주 참조번호',
};

class PlatformReviewAccess {
  final bool read;
  final bool request;
  final bool reply;
  final bool prioritize;
  final String author;
  const PlatformReviewAccess(
      {required this.read,
      required this.request,
      required this.reply,
      required this.prioritize,
      required this.author});
  factory PlatformReviewAccess.current() {
    final user = robinUserProfile.value;
    final read = !user.isDealer &&
        BusinessDivisionScope.current()
            .includes(RobinBusinessDivision.platformModule);
    final leader = robinTeams.value.any((t) =>
        t.leaderId == user.username &&
        [RobinBusinessDivision.platformModule, RobinBusinessDivision.common]
            .contains(t.division));
    return PlatformReviewAccess(
        read: read,
        request: read &&
            (user.isAdmin ||
                user.departmentPermission == RobinDepartmentPermission.sales),
        reply: read &&
            (user.isAdmin ||
                user.departmentPermission ==
                    RobinDepartmentPermission.engineering),
        prioritize: read && (user.isAdmin || leader),
        author: '${user.name} ${user.rank}');
  }
}

@immutable
class PlatformReviewFile {
  final String id;
  final SelectedDesktopFile file;
  final String revision;
  const PlatformReviewFile(
      {required this.id, required this.file, required this.revision});
}

@immutable
class PlatformReviewRequest {
  final Map<String, String> fields;
  final Set<PlatformReviewKind> kinds;
  final List<PlatformReviewFile> attachments;
  final int revision;
  final String author;
  final DateTime at;
  final String reason;
  PlatformReviewRequest(
      {required Map<String, String> fields,
      required Set<PlatformReviewKind> kinds,
      required List<PlatformReviewFile> attachments,
      required this.revision,
      required this.author,
      required this.at,
      required this.reason})
      : fields = Map.unmodifiable(fields.map((k, v) => MapEntry(k, v.trim()))),
        kinds = Set.unmodifiable(kinds),
        attachments = List.unmodifiable(attachments);
}

@immutable
class PlatformReviewReply {
  final PlatformReviewKind kind;
  final PlatformReplyStatus status;
  final int requestRevision;
  final String expectedDate;
  final String note;
  final PlatformReviewFile? result;
  final String author;
  final DateTime at;
  const PlatformReviewReply(
      {required this.kind,
      required this.status,
      required this.requestRevision,
      required this.expectedDate,
      required this.note,
      required this.result,
      required this.author,
      required this.at});
}

@immutable
class PlatformReview {
  final String id;
  final int version;
  final List<PlatformReviewRequest> requests;
  final List<PlatformReviewReply> replies;
  const PlatformReview(
      {required this.id,
      required this.version,
      required this.requests,
      this.replies = const []});
  PlatformReviewRequest get request => requests.last;
  PlatformReviewReply? replyFor(PlatformReviewKind kind) {
    for (final r in replies.reversed) {
      if (r.kind == kind && r.requestRevision == request.revision) return r;
    }
    return null;
  }

  String get status {
    if (request.kinds
        .every((k) => replyFor(k)?.status == PlatformReplyStatus.done)) {
      return '검토완';
    }
    if (request.kinds.any((k) =>
        replyFor(k) != null &&
        replyFor(k)!.status != PlatformReplyStatus.unchecked)) {
      return '검토중';
    }
    return '미확인';
  }
}

@immutable
class PlatformPriorityEvent {
  final String author;
  final String reason;
  final DateTime at;
  final List<String> before;
  final List<String> after;
  PlatformPriorityEvent(
      {required this.author,
      required this.reason,
      required this.at,
      required List<String> before,
      required List<String> after})
      : before = List.unmodifiable(before),
        after = List.unmodifiable(after);
}

/// Frontend session store. SL is entered manually, not issued by ROBIN or ERP.
final platformReviews = ValueNotifier<List<PlatformReview>>([]);
int _platformReviewSequence = 0;
final platformPriorityHistory = ValueNotifier<List<PlatformPriorityEvent>>([]);

bool validPlatformDate(String value) {
  final date = DateTime.tryParse(value);
  return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) &&
      date != null &&
      date.toIso8601String().substring(0, 10) == value;
}

PlatformReview platformReviewById(String id) =>
    platformReviews.value.singleWhere((r) => r.id == id);

PlatformReview savePlatformRequest(
    {required PlatformReviewAccess actor,
    required Map<String, String> fields,
    required Set<PlatformReviewKind> kinds,
    List<PlatformReviewFile> attachments = const [],
    String? id,
    int? expectedVersion,
    String reason = ''}) {
  if (!actor.read || !actor.request) throw StateError('영업 요청 권한이 없습니다.');
  for (final key in [
    'sl',
    'project',
    'customer',
    'sales',
    'designer',
    'due',
    'spec'
  ]) {
    if ((fields[key] ?? '').trim().isEmpty) {
      throw StateError('${platformRequestLabels[key]}: 입력이 필요합니다.');
    }
  }
  if (!validPlatformDate(fields['due']!.trim())) {
    throw StateError('회신 기한은 실제 날짜 YYYY-MM-DD로 입력해주세요.');
  }
  if (kinds.isEmpty) throw StateError('재료비 또는 레이아웃 검토를 선택해주세요.');
  for (final key in ['stroke', 'load', 'warpage']) {
    final text = (fields[key] ?? '').trim();
    if (text.isEmpty) continue;
    final n = double.tryParse(text);
    if (n == null || !n.isFinite || n < 0) {
      throw StateError('${platformRequestLabels[key]}: 0 이상 숫자가 필요합니다.');
    }
  }
  final sl = fields['sl']!.trim().toUpperCase();
  final linkedPipeline = (fields['pipeline'] ?? '').trim();
  if (linkedPipeline.isNotEmpty && linkedPipeline != fields['sl']!.trim()) {
    throw StateError('검토 요청의 가수주번호가 원 수주와 다릅니다.');
  }
  if (linkedPipeline.isEmpty &&
      platformReviews.value.any(
          (r) => r.id != id && r.request.fields['sl']!.toUpperCase() == sl)) {
    throw StateError('이미 등록된 SL CODE입니다. 기존 건에서 수정해주세요.');
  }
  final previous = id == null ? null : platformReviewById(id);
  if (previous != null && previous.version != expectedVersion) {
    throw StateError('저장본이 변경되었습니다. 다시 열어주세요.');
  }
  if (previous != null && reason.trim().isEmpty) {
    throw StateError('요청 수정·재요청 사유를 입력해주세요.');
  }
  final now = DateTime.now();
  final request = PlatformReviewRequest(
      fields: fields,
      kinds: kinds,
      attachments: attachments,
      revision: (previous?.request.revision ?? 0) + 1,
      author: actor.author,
      at: now,
      reason: reason.trim());
  final updated = PlatformReview(
      id: previous?.id ??
          'platform-review-${now.microsecondsSinceEpoch}-${++_platformReviewSequence}',
      version: (previous?.version ?? 0) + 1,
      requests: List.unmodifiable([...?previous?.requests, request]),
      replies: previous?.replies ?? const []);
  platformReviews.value = previous == null
      ? [...platformReviews.value, updated]
      : [
          for (final r in platformReviews.value)
            r.id == updated.id ? updated : r
        ];
  _platformTodo(
      updated, request.fields['designer']!, actor.author, '설계 검토 요청', now);
  return updated;
}

PlatformReview savePlatformReply(
    {required PlatformReviewAccess actor,
    required String id,
    required int expectedVersion,
    required PlatformReviewKind kind,
    required PlatformReplyStatus status,
    String expectedDate = '',
    String note = '',
    PlatformReviewFile? result}) {
  if (!actor.read || !actor.reply) throw StateError('설계 회신 권한이 없습니다.');
  final previous = platformReviewById(id);
  if (previous.version != expectedVersion) {
    throw StateError('저장본이 변경되었습니다. 다시 열어주세요.');
  }
  if (!previous.request.kinds.contains(kind)) {
    throw StateError('요청하지 않은 검토 항목입니다.');
  }
  if (status == PlatformReplyStatus.reviewing &&
      !validPlatformDate(expectedDate.trim())) {
    throw StateError('검토중은 완료 예정일(YYYY-MM-DD)이 필요합니다.');
  }
  if (status == PlatformReplyStatus.done &&
      (result == null || result.revision.trim().isEmpty)) {
    throw StateError('검토완은 결과 파일과 파일 Rev가 필요합니다.');
  }
  if (previous.replyFor(kind)?.status == PlatformReplyStatus.done &&
      status != PlatformReplyStatus.done &&
      note.trim().isEmpty) {
    throw StateError('완료 회신을 되돌리는 사유를 입력해주세요.');
  }
  if (result != null &&
      previous.replies.any((r) =>
          r.kind == kind &&
          r.result != null &&
          r.result!.file.name == result.file.name &&
          r.result!.revision == result.revision &&
          r.result!.id != result.id)) {
    throw StateError('동일 파일명·Rev가 있습니다. 기존 Rev를 선택하거나 새 Rev를 입력해주세요.');
  }
  final now = DateTime.now();
  final reply = PlatformReviewReply(
      kind: kind,
      status: status,
      requestRevision: previous.request.revision,
      expectedDate: expectedDate.trim(),
      note: note.trim(),
      result: result,
      author: actor.author,
      at: now);
  final updated = PlatformReview(
      id: id,
      version: previous.version + 1,
      requests: previous.requests,
      replies: List.unmodifiable([...previous.replies, reply]));
  platformReviews.value = [
    for (final r in platformReviews.value) r.id == id ? updated : r
  ];
  _platformTodo(updated, previous.request.fields['sales']!, actor.author,
      '${kind.label} ${status.label} 회신 · 전체 ${updated.status}', now);
  return updated;
}

void movePlatformPriority(
    {required PlatformReviewAccess actor,
    required String id,
    required int delta,
    required String reason}) {
  if (!actor.read || !actor.prioritize) {
    throw StateError('우선순위는 관리자 또는 배정된 팀장만 변경할 수 있습니다.');
  }
  if (reason.trim().isEmpty) throw StateError('우선순위 변경 사유를 입력해주세요.');
  if (delta != 1 && delta != -1) throw StateError('한 순위씩 이동해주세요.');
  final rows = [...platformReviews.value];
  final index = rows.indexWhere((r) => r.id == id);
  final target = index + delta;
  if (index < 0 || target < 0 || target >= rows.length) return;
  final before = rows.map((r) => r.id).toList();
  final moving = rows.removeAt(index);
  rows.insert(target, moving);
  platformReviews.value = rows;
  platformPriorityHistory.value = [
    ...platformPriorityHistory.value,
    PlatformPriorityEvent(
        author: actor.author,
        reason: reason.trim(),
        at: DateTime.now(),
        before: before,
        after: rows.map((r) => r.id).toList())
  ];
}

void _platformTodo(PlatformReview review, String assignee, String author,
    String task, DateTime at) {
  addProjectTodo(ProjectTodoItem(
      id: '${review.id}:${review.version}',
      orderNo: review.request.fields['sl']!,
      projectName: review.request.fields['project']!,
      stage: '플랫폼 검토',
      assignee: assignee,
      task: '$task · 요청 Rev.${review.request.revision}',
      createdBy: author,
      createdAt: at.toIso8601String(),
      division: RobinBusinessDivision.platformModule,
      sourceLabel: '플랫폼 검토 상태 알림',
      navigationIndex: 1));
}
