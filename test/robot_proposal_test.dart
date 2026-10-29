import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/services/product_identity_service.dart';
import 'package:robin_portal/services/robot_proposal_service.dart';
import 'package:robin_portal/widgets/robot_proposal_workspace.dart';

const robotDemoTestBasis = {
  'model': 'RS',
  'base': '045N',
  'axis': 'X',
  'type': 'B/S',
  'stroke': '100ST',
  'drive': '직렬',
  'lead': '1505',
  'motorMaker': 'MITSUBISHI J5',
  'motorCap': '100W'
};

void main() {
  const key = (RobinBusinessDivision.robot, 'TEST-ROBOT-PROP');
  setUp(() {
    proposalSpecifications.value = {};
    robotProposalDrafts.clear();
  });
  test('분류 원본 191행과 이름이 다른 동일 코드 두 행을 모두 보존한다', () {
    expect(robotItemClassifications.length, 191);
    expect(robotItemClassifications.map((c) => c.major).toSet().length, 11);
    final duplicates = robotItemClassifications
        .where(
            (c) => c.major == 'RCM' && c.middle == 'RCN2' && c.minor == 'RCN2')
        .toList();
    expect(duplicates.map((c) => c.row), [113, 124]);
    expect(duplicates.map((c) => c.minorName), ['N2 CABLE 2축 범용', 'N2E CABLE']);
    expect(robotItemClassifications.singleWhere((c) => c.row == 44).path,
        'RBC · 기구부 / RS · RS 직각 / BS · B/S TYPE');
  });
  test('원본 DEMO 기준 금액과 수량·사급·타입 전용 옵션을 계산한다', () {
    expect(calculateRobotDemoCost(robotDemoTestBasis, {})!.total, 3340000);
    final result = calculateRobotDemoCost(robotDemoTestBasis, {
      'LM Block 수량 증가': const RobotCostOption(quantity: 2),
      '모터 사급': const RobotCostOption(),
      'Timing Belt 치형 변경': const RobotCostOption(),
    })!;
    expect(result.base, 3340000);
    expect(
        result.options, 210000); // 2 × 310,000 - 410,000. BELT-only excluded.
    expect(result.total, 3550000);
    expect(result.optionLines.containsKey('Timing Belt 치형 변경'), isFalse);
    final belt = {...robotDemoTestBasis, 'type': 'BELT'}..remove('lead');
    expect(calculateRobotDemoCost(belt, {})!.total, 2790000);
  });
  test('미입력·알 수 없는 규격은 0원이 아닌 미산출로 남긴다', () {
    expect(calculateRobotDemoCost({}, {}), isNull);
    expect(
        calculateRobotDemoCost({...robotDemoTestBasis, 'model': 'RS-N14'}, {}),
        isNull);
    expect(
        calculateRobotDemoCost(
            robotDemoTestBasis, {'알 수 없는 옵션': const RobotCostOption()}),
        isNull);
  });
  test('Rev는 사양·금액을 복사해 보존하고 변경분 및 삭제 구성품을 기록한다', () {
    final draft = robotProposalFor(key), request = draft.requests.first;
    final part = request.parts.first;
    part.classificationRow = 44;
    part.costInputs.addAll(robotDemoTestBasis);
    proposalSpecifications.value = {
      key: const ProductSpecification(model: 'RS', stroke: '100')
    };
    final first = saveRobotProposalRevision(request, author: '영업');
    expect(first.cost, 3340000);
    expect(request.dirty, isFalse);
    part.quantity = 2;
    part.costInputs['motorCap'] = '200W';
    proposalSpecifications.value = {
      key: const ProductSpecification(model: 'RS', stroke: '200')
    };
    final second =
        saveRobotProposalRevision(request, author: '영업', memo: '수량과 스트로크 변경');
    expect(first.cost, 3340000);
    expect(first.parts[part.id]!['Stroke(mm)'], '100');
    expect(first.parts[part.id]!['수량'], '1');
    expect(second.cost, 6800000);
    expect(second.changes.any((c) => c.contains('수량: 1 → 2')), isTrue);
    expect(
        second.changes.any((c) => c.contains('Stroke(mm): 100 → 200')), isTrue);
    expect(() => saveRobotProposalRevision(request, author: '영업'),
        throwsStateError);
    request.name = '저장 전 이름';
    final summary = robotProposalReviewSummary(key);
    expect(summary, contains('수량: 2'));
    expect(summary, contains('Rev.02'));
    expect(summary, contains('저장본 기준'));
    expect(summary, isNot(contains('저장 전 이름')));
  });
}
