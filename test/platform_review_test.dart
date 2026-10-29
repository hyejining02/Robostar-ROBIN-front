import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/services/business_division_scope.dart';
import 'package:robin_portal/services/desktop_file_service.dart';
import 'package:robin_portal/services/platform_review_service.dart';
import 'package:robin_portal/services/project_todo_service.dart';
import 'package:robin_portal/widgets/user_profile.dart';

const platformActor = PlatformReviewAccess(
    read: true, request: true, reply: true, prioritize: true, author: '테스트 담당');
Map<String, String> platformFixture(String sl) => {
      'sl': sl,
      'project': '플랫폼 테스트',
      'customer': '테스트 고객',
      'sales': '김영업',
      'designer': '이설계',
      'due': '2026-11-01',
      'spec': '레이아웃과 재료비 검토',
      'object': '웨이퍼',
      'stroke': '500',
      'load': '10',
      'warpage': '0.1'
    };
const materialFile = PlatformReviewFile(
    id: 'file1',
    file: SelectedDesktopFile(path: 'material.xlsx', name: 'material.xlsx'),
    revision: 'Rev.01');
const layoutFile = PlatformReviewFile(
    id: 'file2',
    file: SelectedDesktopFile(path: 'layout.pdf', name: 'layout.pdf'),
    revision: 'Rev.01');

void main() {
  setUp(() {
    platformReviews.value = [];
    platformPriorityHistory.value = [];
    projectTodoItems.value = [];
  });
  PlatformReview create(String sl, {Set<PlatformReviewKind>? kinds}) =>
      savePlatformRequest(
          actor: platformActor,
          fields: platformFixture(sl),
          kinds: kinds ?? PlatformReviewKind.values.toSet());
  PlatformReview reply(PlatformReview record, PlatformReviewKind kind,
          PlatformReplyStatus status,
          {String expectedDate = '',
          PlatformReviewFile? file,
          String note = ''}) =>
      savePlatformReply(
          actor: platformActor,
          id: record.id,
          expectedVersion: record.version,
          kind: kind,
          status: status,
          expectedDate: expectedDate,
          result: file,
          note: note);

  test('SL CODE 중복/필수값/날짜/숫자/검토대상을 검증한다', () {
    create('SL-001');
    expect(() => create('sl-001'), throwsStateError);
    for (final fields in [
      <String, String>{},
      {...platformFixture('SL-002'), 'due': '2026-02-30'},
      {...platformFixture('SL-002'), 'stroke': 'NaN'}
    ]) {
      expect(
          () => savePlatformRequest(
              actor: platformActor,
              fields: fields,
              kinds: PlatformReviewKind.values.toSet()),
          throwsStateError);
    }
    expect(() => create('SL-002', kinds: {}), throwsStateError);
  });
  test('재료비만 완료하면 전체 완료가 아니고 두 항목을 완료해야 검토완이다', () {
    var r = create('SL-001');
    r = reply(r, PlatformReviewKind.material, PlatformReplyStatus.done,
        file: materialFile);
    expect(r.status, '검토중');
    expect(r.replyFor(PlatformReviewKind.layout), isNull);
    r = reply(r, PlatformReviewKind.layout, PlatformReplyStatus.done,
        file: layoutFile);
    expect(r.status, '검토완');
    expect(r.replies.length, 2);
  });
  test('요청한 항목 하나만 있으면 해당 항목 기준으로 완료를 계산한다', () {
    var r = create('SL-001', kinds: {PlatformReviewKind.layout});
    expect(
        () => reply(r, PlatformReviewKind.material, PlatformReplyStatus.done,
            file: materialFile),
        throwsStateError);
    r = reply(r, PlatformReviewKind.layout, PlatformReplyStatus.done,
        file: layoutFile);
    expect(r.status, '검토완');
  });
  test('검토중은 예정일, 검토완은 결과파일과 Rev가 필요하다', () {
    final r = create('SL-001');
    expect(
        () => reply(
            r, PlatformReviewKind.material, PlatformReplyStatus.reviewing),
        throwsStateError);
    expect(
        () => reply(
            r, PlatformReviewKind.material, PlatformReplyStatus.reviewing,
            expectedDate: '2026-13-01'),
        throwsStateError);
    expect(
        () => reply(r, PlatformReviewKind.material, PlatformReplyStatus.done),
        throwsStateError);
    final updated = reply(
        r, PlatformReviewKind.material, PlatformReplyStatus.reviewing,
        expectedDate: '2026-11-02');
    expect(updated.replyFor(PlatformReviewKind.material)!.expectedDate,
        '2026-11-02');
  });
  test('요청 변경은 새 Rev로 저장하고 과거 회신과 결과파일을 자동 승계하지 않는다', () {
    var r = create('SL-001');
    r = reply(r, PlatformReviewKind.material, PlatformReplyStatus.done,
        file: materialFile);
    r = reply(r, PlatformReviewKind.layout, PlatformReplyStatus.done,
        file: layoutFile);
    expect(
        () => savePlatformRequest(
            actor: platformActor,
            id: r.id,
            expectedVersion: r.version,
            fields: platformFixture('SL-001'),
            kinds: r.request.kinds),
        throwsStateError);
    final changed = savePlatformRequest(
        actor: platformActor,
        id: r.id,
        expectedVersion: r.version,
        fields: {
          ...platformFixture('SL-001'),
          'stroke': '700',
          'order': 'SO-REFERENCE'
        },
        kinds: r.request.kinds,
        reason: '고객 Stroke 변경');
    expect(changed.request.revision, 2);
    expect(changed.status, '미확인');
    expect(changed.replyFor(PlatformReviewKind.material), isNull);
    expect(changed.requests.first.fields['stroke'], '500');
    expect(changed.replies.first.result!.revision, 'Rev.01');
    expect(changed.replies.first.requestRevision, 1);
    expect(changed.request.fields['order'], 'SO-REFERENCE');
  });
  test('수정 충돌과 권한 없는 요청/회신/우선순위 변경을 차단한다', () {
    final r = create('SL-001');
    const viewer = PlatformReviewAccess(
        read: true,
        request: false,
        reply: false,
        prioritize: false,
        author: '조회');
    expect(
        () => savePlatformRequest(
            actor: viewer,
            fields: platformFixture('SL-002'),
            kinds: r.request.kinds),
        throwsStateError);
    expect(
        () => savePlatformReply(
            actor: viewer,
            id: r.id,
            expectedVersion: r.version,
            kind: PlatformReviewKind.layout,
            status: PlatformReplyStatus.unchecked),
        throwsStateError);
    expect(
        () => movePlatformPriority(
            actor: viewer, id: r.id, delta: 1, reason: '변경'),
        throwsStateError);
    expect(
        () => savePlatformReply(
            actor: platformActor,
            id: r.id,
            expectedVersion: 0,
            kind: PlatformReviewKind.layout,
            status: PlatformReplyStatus.unchecked),
        throwsStateError);
  });
  test('우선순위를 올리고 전후 순서/담당자/사유/시각을 보존한다', () {
    final a = create('SL-001');
    final b = create('SL-002');
    movePlatformPriority(
        actor: platformActor, id: b.id, delta: -1, reason: '고객 긴급 요청');
    expect(platformReviews.value.first.id, b.id);
    final e = platformPriorityHistory.value.single;
    expect(e.before, [a.id, b.id]);
    expect(e.after, [b.id, a.id]);
    expect(e.reason, '고객 긴급 요청');
    expect(e.at, isA<DateTime>());
  });
  test('완료 상태 되돌리기는 사유가 필요하고 동일 파일명·Rev를 중복 생성하지 않는다', () {
    var r = create('SL-001');
    r = reply(r, PlatformReviewKind.material, PlatformReplyStatus.done,
        file: materialFile);
    expect(
        () => reply(
            r, PlatformReviewKind.material, PlatformReplyStatus.unchecked),
        throwsStateError);
    const duplicate = PlatformReviewFile(
        id: 'another',
        file: SelectedDesktopFile(path: 'material.xlsx', name: 'material.xlsx'),
        revision: 'Rev.01');
    expect(
        () => reply(r, PlatformReviewKind.material, PlatformReplyStatus.done,
            file: duplicate),
        throwsStateError);
    r = reply(r, PlatformReviewKind.material, PlatformReplyStatus.unchecked,
        note: '재검토 필요');
    expect(r.status, '미확인');
    expect(r.replies.first.result, materialFile);
  });
  test('요청/회신 To-Do는 플랫폼 원천·담당자·요청 Rev를 표시한다', () {
    final r = create('SL-001');
    expect(projectTodoItems.value.first.assignee, '이설계');
    reply(r, PlatformReviewKind.material, PlatformReplyStatus.reviewing,
        expectedDate: '2026-11-02');
    expect(projectTodoItems.value.first.assignee, '김영업');
    expect(projectTodoItems.value.first.division,
        RobinBusinessDivision.platformModule);
    expect(projectTodoItems.value.first.navigationIndex, 1);
  });
  test('로봇 사업부 선택 시 플랫폼 접근이 닫히고 관리자 전체 조회는 허용한다', () {
    final previous = selectedBusinessDivision.value;
    selectedBusinessDivision.value = RobinBusinessDivision.robot;
    expect(PlatformReviewAccess.current().read, isFalse);
    selectedBusinessDivision.value = null;
    expect(PlatformReviewAccess.current().read, robinUserProfile.value.isAdmin);
    selectedBusinessDivision.value = previous;
  });
}
