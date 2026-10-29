import 'package:flutter/foundation.dart';

import '../models/access_control.dart';
import 'desktop_file_service.dart';
import 'product_identity_service.dart';
import 'project_todo_service.dart';
import 'robot_design_review_catalog.dart';

enum RobotReviewStatus {
  draft('임시저장'),
  requested('요청'),
  reviewing('검토중'),
  changes('수정요청'),
  rejected('반려'),
  completed('완료');

  const RobotReviewStatus(this.label);
  final String label;
}

enum RobotReviewRole { sales, design }

enum RobotReviewAction {
  saveDraft,
  submit,
  start,
  requestChanges,
  reject,
  complete
}

@immutable
class ReviewDrawing {
  final String id;
  final String fileName;
  final String number;
  final String revision;
  final bool demo;
  final SelectedDesktopFile? file;
  const ReviewDrawing(
      {required this.id,
      required this.fileName,
      required this.number,
      required this.revision,
      this.demo = false,
      this.file});
  String get label =>
      '$fileName · 도면번호 ${number.isEmpty ? '미입력' : number} · $revision${demo ? ' (기존 시연 자료)' : ''}';
}

@immutable
class ReviewAttachment {
  final String id;
  final SelectedDesktopFile file;
  final String drawingNumber;
  final String drawingRevision;
  final DateTime selectedAt;
  const ReviewAttachment(
      {required this.id,
      required this.file,
      required this.selectedAt,
      this.drawingNumber = '',
      this.drawingRevision = ''});
  ReviewDrawing? get drawing => drawingNumber.isEmpty || drawingRevision.isEmpty
      ? null
      : ReviewDrawing(
          id: id,
          fileName: file.name,
          number: drawingNumber,
          revision: drawingRevision,
          file: file);
}

@immutable
class RobotReviewContent {
  final Map<String, String> fields;
  final Set<int> options;
  final List<ReviewAttachment> attachments;
  final ReviewDrawing? drawing;
  RobotReviewContent(
      {Map<String, String> fields = const {},
      Set<int> options = const {},
      List<ReviewAttachment> attachments = const [],
      this.drawing})
      : fields = Map.unmodifiable(fields.map((k, v) => MapEntry(k, v.trim()))),
        options = Set.unmodifiable(options),
        attachments = List.unmodifiable(attachments);

  Map<String, String> get values => {
        for (final field in robotReviewFieldLabels.entries)
          field.value: fields[field.key] ?? '',
        '설계 특기사항': robotReviewOptions
            .where((o) => options.contains(o.row))
            .map((o) => o.label)
            .join(', '),
        '첨부': attachments
            .map((a) =>
                '${a.id}: ${a.file.name} · ${a.drawingNumber} · ${a.drawingRevision}')
            .join('\n'),
      };
  bool sameRequest(RobotReviewContent other) => mapEquals(values, other.values);
}

@immutable
class RobotReviewEvent {
  final DateTime at;
  final String author;
  final RobotReviewRole role;
  final RobotReviewStatus from;
  final RobotReviewStatus to;
  final int revision;
  final String reason;
  final List<String> changes;
  final RobotReviewContent snapshot;
  const RobotReviewEvent(
      {required this.at,
      required this.author,
      required this.role,
      required this.from,
      required this.to,
      required this.revision,
      required this.reason,
      required this.changes,
      required this.snapshot});
}

@immutable
class RobotDesignReview {
  final String projectName;
  final String customer;
  final int version;
  final int revision;
  final RobotReviewStatus status;
  final RobotReviewContent content;
  final List<RobotReviewEvent> history;
  final bool drawingRecheck;
  RobotDesignReview(
      {this.projectName = '',
      this.customer = '',
      this.version = 0,
      this.revision = 0,
      this.status = RobotReviewStatus.draft,
      RobotReviewContent? content,
      this.history = const [],
      this.drawingRecheck = false})
      : content = content ?? RobotReviewContent();
}

/// Session-only frontend prototype. Not an approved production workflow or API.
final robotDesignReviews =
    ValueNotifier<Map<ProductIdentityKey, RobotDesignReview>>({});
RobotDesignReview robotReviewFor(ProductIdentityKey key) =>
    robotDesignReviews.value[key] ?? RobotDesignReview();

List<String> validateRobotReview(RobotReviewContent content) {
  final errors = <String>[];
  for (final key in [
    'requester',
    'designer',
    'due',
    'composition',
    'drive',
    'model',
    'request'
  ]) {
    if ((content.fields[key] ?? '').isEmpty) {
      errors.add('${robotReviewFieldLabels[key]}을(를) 입력해주세요.');
    }
  }
  final due = content.fields['due'] ?? '';
  final date = DateTime.tryParse(due);
  if (due.isNotEmpty &&
      (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(due) ||
          date == null ||
          date.toIso8601String().substring(0, 10) != due)) {
    errors.add('요청 희망일은 실제 날짜 YYYY-MM-DD로 입력해주세요.');
  }
  for (final key in ['stroke', 'payload', 'speed', 'cycles']) {
    final text = content.fields[key] ?? '';
    if (text.isEmpty) continue;
    final value = double.tryParse(text);
    if (value == null || !value.isFinite || value < 0) {
      errors.add('${robotReviewFieldLabels[key]}은(는) 0 이상의 숫자로 입력해주세요.');
    }
  }
  if (content.fields['composition'] == '조합' &&
      (content.fields['combination'] ?? '').isEmpty) {
    errors.add('조합 구조 상세를 입력해주세요.');
  }
  if (content.fields['maker'] == '지정' &&
      (content.fields['makerName'] ?? '').isEmpty) {
    errors.add('지정 Maker·대상 부품을 입력해주세요.');
  }
  for (final option
      in robotReviewOptions.where((o) => content.options.contains(o.row))) {
    final restriction = reviewOptionRestriction(option, content.fields);
    if (restriction != null) errors.add('${option.label}: $restriction');
  }
  return errors;
}

RobotDesignReview applyRobotReview(
    {required ProductIdentityKey key,
    required int expectedVersion,
    required RobotReviewAction action,
    required RobotReviewRole role,
    required String author,
    required String projectName,
    String customer = '',
    required RobotReviewContent content,
    String reason = ''}) {
  if (key.$1 != RobinBusinessDivision.robot) {
    throw StateError('로봇 검토 요청서만 처리합니다.');
  }
  final previous = robotReviewFor(key);
  if (previous.version != expectedVersion) {
    throw StateError('다른 곳에서 수정되었습니다. 저장 내용을 다시 불러와주세요.');
  }
  final salesAction = action == RobotReviewAction.saveDraft ||
      action == RobotReviewAction.submit;
  if ((salesAction && role != RobotReviewRole.sales) ||
      (!salesAction && role != RobotReviewRole.design)) {
    throw StateError('현재 시연 역할에서 수행할 수 없는 작업입니다.');
  }
  final editable = [
    RobotReviewStatus.draft,
    RobotReviewStatus.changes,
    RobotReviewStatus.rejected
  ].contains(previous.status);
  if (action == RobotReviewAction.saveDraft && !editable) {
    throw StateError('제출 후 변경은 수정 요청서로 남겨주세요.');
  }
  if (!salesAction && !previous.content.sameRequest(content)) {
    throw StateError('설계 회신은 영업 요청서를 직접 덮어쓸 수 없습니다. 수정요청 또는 반려를 사용해주세요.');
  }
  final hasChanges = !previous.content.sameRequest(content);
  if (previous.revision > 0 && hasChanges && reason.trim().isEmpty) {
    throw StateError('요청서 변경 사유를 입력해주세요.');
  }
  if (action == RobotReviewAction.submit && !editable && !hasChanges) {
    throw StateError('변경 내용이 없습니다. 기존 요청을 다시 제출하지 않습니다.');
  }
  if (action == RobotReviewAction.submit) {
    final errors = validateRobotReview(content);
    if (errors.isNotEmpty) throw StateError(errors.join('\n'));
  }
  if (action == RobotReviewAction.start &&
      previous.status != RobotReviewStatus.requested) {
    throw StateError('요청 상태에서 검토를 시작해주세요.');
  }
  if ([
        RobotReviewAction.requestChanges,
        RobotReviewAction.reject,
        RobotReviewAction.complete
      ].contains(action) &&
      ![RobotReviewStatus.requested, RobotReviewStatus.reviewing]
          .contains(previous.status)) {
    throw StateError('요청 또는 검토중 상태에서 회신해주세요.');
  }
  if (([
            RobotReviewAction.requestChanges,
            RobotReviewAction.reject,
            RobotReviewAction.complete
          ].contains(action) ||
          (action == RobotReviewAction.submit &&
              previous.revision > 0 &&
              previous.status != RobotReviewStatus.draft)) &&
      reason.trim().isEmpty) {
    throw StateError('수정·재요청·반려·완료 사유를 입력해주세요.');
  }
  if (action == RobotReviewAction.complete &&
      (content.drawing == null ||
          content.drawing!.number.isEmpty ||
          content.drawing!.revision.isEmpty)) {
    throw StateError('완료할 요청서에 도면번호·도면 Rev를 연결해주세요. 최초 요청 시 도면 첨부는 필수가 아닙니다.');
  }
  final nextStatus = switch (action) {
    RobotReviewAction.saveDraft =>
      editable && previous.status != RobotReviewStatus.draft
          ? previous.status
          : RobotReviewStatus.draft,
    RobotReviewAction.submit => RobotReviewStatus.requested,
    RobotReviewAction.start => RobotReviewStatus.reviewing,
    RobotReviewAction.requestChanges => RobotReviewStatus.changes,
    RobotReviewAction.reject => RobotReviewStatus.rejected,
    RobotReviewAction.complete => RobotReviewStatus.completed,
  };
  final changes = <String>[];
  for (final field in content.values.entries) {
    final before = previous.content.values[field.key] ?? '';
    if (before != field.value) {
      changes.add(
          '${field.key}: ${before.isEmpty ? '미입력' : before} → ${field.value.isEmpty ? '미입력' : field.value}');
    }
  }
  if (previous.content.drawing?.id != content.drawing?.id ||
      previous.content.drawing?.label != content.drawing?.label) {
    changes.add(
        '연결 도면: ${previous.content.drawing?.label ?? '없음'} → ${content.drawing?.label ?? '없음'}');
  }
  final revision =
      previous.revision + ((hasChanges || previous.revision == 0) ? 1 : 0);
  final now = DateTime.now();
  final updated = RobotDesignReview(
      projectName: projectName,
      customer: customer.isEmpty ? previous.customer : customer,
      version: previous.version + 1,
      revision: revision,
      status: nextStatus,
      content: content,
      drawingRecheck: action == RobotReviewAction.complete
          ? false
          : previous.drawingRecheck ||
              (hasChanges && previous.content.drawing != null),
      history: List.unmodifiable([
        ...previous.history,
        RobotReviewEvent(
            at: now,
            author: author,
            role: role,
            from: previous.status,
            to: nextStatus,
            revision: revision,
            reason: reason.trim(),
            changes: List.unmodifiable(changes),
            snapshot: content)
      ]));
  robotDesignReviews.value = {...robotDesignReviews.value, key: updated};
  if (salesAction) {
    // Explicit save only. Do not generate codes or overwrite the manually saved identity.
    for (final pair in [
      ('model', 'model'),
      ('stroke', 'stroke'),
      ('motor', 'motor'),
      ('sensor', 'sensor')
    ]) {
      updateProposalSpecification(key, pair.$2, content.fields[pair.$1] ?? '');
    }
  }
  if (action != RobotReviewAction.saveDraft &&
      action != RobotReviewAction.start) {
    final prefix = 'robot-review:${key.$1.name}:${key.$2}:';
    projectTodoItems.value =
        projectTodoItems.value.where((t) => !t.id.startsWith(prefix)).toList();
    addProjectTodo(ProjectTodoItem(
        id: '$prefix${updated.version}',
        orderNo: key.$2,
        projectName: projectName,
        stage: 'Proposal',
        assignee: content.fields[action == RobotReviewAction.submit
                ? 'designer'
                : 'requester'] ??
            '',
        task: '설계 검토 ${nextStatus.label} · 요청서 Rev.$revision',
        createdBy: author,
        createdAt: now.toIso8601String(),
        division: key.$1,
        sourceLabel: '설계 검토 요청서',
        navigationIndex: 1));
  }
  return updated;
}
