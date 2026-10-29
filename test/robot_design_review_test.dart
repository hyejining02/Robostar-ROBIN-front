import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/services/product_identity_service.dart';
import 'package:robin_portal/services/project_todo_service.dart';
import 'package:robin_portal/services/robot_design_review_catalog.dart';
import 'package:robin_portal/services/robot_design_review_service.dart';

RobotReviewContent reviewFixture(
        {Map<String, String> fields = const {},
        Set<int> options = const {},
        ReviewDrawing? drawing}) =>
    RobotReviewContent(fields: {
      'requester': '김영업',
      'designer': '이설계',
      'due': '2026-11-01',
      'composition': '단축',
      'drive': 'B/Screw',
      'layout': '직렬',
      'model': 'RS-100',
      'payload': '10',
      'speed': '1000',
      'request': '컨셉 구조 검토',
      ...fields,
    }, options: options, drawing: drawing);

void main() {
  const key = (RobinBusinessDivision.robot, 'RB-REVIEW-001');
  const dwg1 = ReviewDrawing(
      id: 'd1', fileName: 'layout.pdf', number: 'DWG-01', revision: 'Rev.01');
  const dwg2 = ReviewDrawing(
      id: 'd2', fileName: 'layout.pdf', number: 'DWG-01', revision: 'Rev.02');
  RobotDesignReview apply(RobotReviewAction action, RobotReviewContent content,
          {RobotReviewRole role = RobotReviewRole.sales, String reason = ''}) =>
      applyRobotReview(
          key: key,
          expectedVersion: robotReviewFor(key).version,
          action: action,
          role: role,
          author: role == RobotReviewRole.sales ? '김영업' : '이설계',
          projectName: '테스트 프로젝트',
          content: content,
          reason: reason);
  setUp(() {
    robotDesignReviews.value = {};
    proposalSpecifications.value = {};
    projectTodoItems.value = [];
    productIdentities.value = {};
  });

  test('원문 명시 RC/1RAIL/Belt/직렬·병렬 제한을 적용한다', () {
    final fields = {
      'model': 'RC-100',
      'rails': '1',
      'drive': 'Belt',
      'layout': '직렬'
    };
    RobotReviewOption option(int row) =>
        robotReviewOptions.singleWhere((o) => o.row == row);
    for (final row in [5, 6, 9, 19, 20, 35, 42, 74]) {
      expect(reviewOptionRestriction(option(row), fields), isNotNull);
    }
    expect(reviewOptionRestriction(option(62), fields), isNull);
    expect(reviewOptionRestriction(option(35), {...fields, 'layout': '병렬'}),
        isNull);
    expect(reviewOptionRestriction(option(42), {...fields, 'drive': 'B/Screw'}),
        isNull);
  });
  test('임시저장과 제출 검증을 구분하고 잘못된 날짜/숫자/Maker를 표시한다', () {
    apply(RobotReviewAction.saveDraft, RobotReviewContent());
    expect(robotReviewFor(key).status, RobotReviewStatus.draft);
    expect(() => apply(RobotReviewAction.submit, RobotReviewContent()),
        throwsStateError);
    final errors = validateRobotReview(reviewFixture(fields: {
      'due': '2026-02-30',
      'speed': 'NaN',
      'stroke': '-1',
      'maker': '지정',
      'composition': '조합'
    }));
    expect(errors.join(), contains('희망일'));
    expect(errors.join(), contains('최대속도'));
    expect(errors.join(), contains('Maker'));
    expect(errors.join(), contains('조합'));
  });
  test('최초 요청에는 도면이 없어도 되며 설계 담당자 To-Do를 만든다', () {
    final r = apply(RobotReviewAction.submit, reviewFixture());
    expect(r.status, RobotReviewStatus.requested);
    expect(r.revision, 1);
    expect(projectTodoItems.value.single.assignee, '이설계');
    expect(projectTodoItems.value.single.navigationIndex, 1);
    expect(projectTodoItems.value.single.sourceLabel, '설계 검토 요청서');
  });
  test('설계 반려와 재요청에서 작성자·시각·사유·변경 전후를 보존한다', () {
    final initial = reviewFixture();
    apply(RobotReviewAction.submit, initial);
    expect(
        () => apply(RobotReviewAction.reject, initial,
            role: RobotReviewRole.design),
        throwsStateError);
    apply(RobotReviewAction.reject, initial,
        role: RobotReviewRole.design, reason: '사용조건 보완');
    expect(projectTodoItems.value.single.assignee, '김영업');
    final r = apply(
        RobotReviewAction.submit, reviewFixture(fields: {'payload': '20'}),
        reason: '하중 보완');
    expect(r.revision, 2);
    expect(r.status, RobotReviewStatus.requested);
    expect(r.history.first.snapshot.fields['payload'], '10');
    expect(r.history.last.snapshot.fields['payload'], '20');
    expect(r.history.last.changes.join(), contains('10 → 20'));
    expect(r.history[1].author, '이설계');
    expect(r.history[1].reason, '사용조건 보완');
    expect(r.history[1].at, isA<DateTime>());
    expect(projectTodoItems.value.length, 1);
  });
  test('수정요청과 반려는 서로 다른 상태이고 댓글과 별개다', () {
    apply(RobotReviewAction.submit, reviewFixture());
    final r = apply(RobotReviewAction.requestChanges, reviewFixture(),
        role: RobotReviewRole.design, reason: '배치 협의');
    expect(r.status, RobotReviewStatus.changes);
    expect(
        () => apply(RobotReviewAction.complete, reviewFixture(drawing: dwg1),
            role: RobotReviewRole.design, reason: '완료'),
        throwsStateError);
  });
  test('검토 시작과 완료를 분리하며 완료 시 도면번호와 Rev가 필요하다', () {
    apply(RobotReviewAction.submit, reviewFixture());
    apply(RobotReviewAction.start, reviewFixture(),
        role: RobotReviewRole.design);
    expect(robotReviewFor(key).status, RobotReviewStatus.reviewing);
    expect(
        () => apply(RobotReviewAction.complete, reviewFixture(),
            role: RobotReviewRole.design, reason: '완료'),
        throwsStateError);
    final r = apply(RobotReviewAction.complete, reviewFixture(drawing: dwg1),
        role: RobotReviewRole.design, reason: '설계 검토 완료');
    expect(r.status, RobotReviewStatus.completed);
    expect(r.revision, 1);
    expect(r.history.last.snapshot.drawing!.revision, 'Rev.01');
  });
  test('완료 후 사양 변경은 재검토로 돌아가며 과거 도면 매칭을 덮어쓰지 않는다', () {
    apply(RobotReviewAction.submit, reviewFixture());
    apply(RobotReviewAction.complete, reviewFixture(drawing: dwg1),
        role: RobotReviewRole.design, reason: '완료');
    final changed = reviewFixture(fields: {'payload': '30'}, drawing: dwg1);
    final r = apply(RobotReviewAction.submit, changed, reason: '고객 하중 변경');
    expect(r.drawingRecheck, isTrue);
    expect(r.status, RobotReviewStatus.requested);
    expect(r.history[1].snapshot.drawing!.revision, 'Rev.01');
    final completed = apply(RobotReviewAction.complete,
        reviewFixture(fields: {'payload': '30'}, drawing: dwg2),
        role: RobotReviewRole.design, reason: '변경 하중 검토 완료');
    expect(completed.drawingRecheck, isFalse);
    expect(completed.history.last.snapshot.drawing!.revision, 'Rev.02');
    expect(completed.history[1].snapshot.drawing!.revision, 'Rev.01');
  });
  test('설계 역할은 영업 원문을 덮어쓰지 못하고 동일 요청 중복 제출도 막는다', () {
    apply(RobotReviewAction.submit, reviewFixture());
    expect(() => apply(RobotReviewAction.submit, reviewFixture()),
        throwsStateError);
    expect(() => apply(RobotReviewAction.saveDraft, reviewFixture()),
        throwsStateError);
    expect(
        () => apply(RobotReviewAction.complete,
            reviewFixture(fields: {'payload': '999'}, drawing: dwg1),
            role: RobotReviewRole.design, reason: '임의 변경'),
        throwsStateError);
    expect(() => apply(RobotReviewAction.reject, reviewFixture(), reason: '반려'),
        throwsStateError);
  });
  test('저장 충돌·사업부 혼합·잘못된 옵션 적용을 막는다', () {
    apply(RobotReviewAction.submit, reviewFixture());
    expect(
        () => applyRobotReview(
            key: key,
            expectedVersion: 0,
            action: RobotReviewAction.start,
            role: RobotReviewRole.design,
            author: '설계',
            projectName: '프로젝트',
            content: reviewFixture()),
        throwsStateError);
    expect(
        () => applyRobotReview(
            key: (RobinBusinessDivision.platformModule, key.$2),
            expectedVersion: 0,
            action: RobotReviewAction.submit,
            role: RobotReviewRole.sales,
            author: '영업',
            projectName: '프로젝트',
            content: reviewFixture()),
        throwsStateError);
    expect(
        validateRobotReview(
            reviewFixture(fields: {'drive': 'Belt'}, options: {42})),
        isNotEmpty);
  });
  test('컨셉 사양을 명시적 저장 시 갱신하되 제품코드는 변경하지 않는다', () {
    saveProductIdentity(key, const ProductIdentity(productCode: 'MANUAL-CODE'),
        author: '영업');
    apply(
        RobotReviewAction.saveDraft, reviewFixture(fields: {'stroke': '700'}));
    expect(proposalSpecifications.value[key]!.stroke, '700');
    expect(identityFor(key).productCode, 'MANUAL-CODE');
  });
}
