import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/services/platform_pipeline_service.dart';

PlatformPipelineData completePlatformVrb(String id) {
  final data = platformPipelineFor((RobinBusinessDivision.platformModule, id),
      customer: '시험 고객', project: '시험 과제', product: 'EFEM', quantity: 2);
  data.materials.add('300mm');
  data.bid = '100000000';
  data.groups.first.rows.first.fields
      .addAll({'name': 'HAND', 'price': '10000000', 'qty': '2'});
  for (final row in data.costs.values) {
    row.fields.addAll({'price': '0', 'qty': '1'});
  }
  data.costs['outside']!.fields.addAll({'price': '2000000', 'qty': '2'});
  data.costs['mfgTravel']!.fields['price'] = '100000';
  data.costs['export']!.fields['price'] = '500000';
  data.costs['salesTravel']!.fields['price'] = '200000';
  for (final e in {'design': '2', 'make': '2', 'setup': '4'}.entries) {
    data.costs[e.key]!.fields.addAll({'price': '300000', 'qty': e.value});
  }
  data.rates.addAll({
    'consumables': '1',
    'warranty': '2',
    'agent': '1',
    'commonMfg': '3',
    'fixedMfg': '4',
    'sga': '5'
  });
  data.quoteLines.first.fields
      .addAll({'name': 'EFEM', 'price': '100000000', 'qty': '1'});
  return data;
}

void main() {
  setUp(platformPipelineRecords.clear);
  test('Assess 필수값·장비 미정·반도체 이재물과 Repeat 원 프로젝트를 검사한다', () {
    final d = platformPipelineFor((RobinBusinessDivision.platformModule, 'A'));
    expect(d.validateAssess(), contains('업체를 입력해주세요.'));
    d.assess['customer'] = '고객';
    d.equipmentTbd = true;
    expect(d.validateAssess(), isEmpty);
    d.equipmentTbd = false;
    d.category = '반도체';
    d.equipment['EFEM'] = 2;
    expect(d.validateAssess(), contains('이재물을 선택해주세요.'));
    d.materials.add('300mm');
    expect(d.validateAssess(), isEmpty);
    d.registrationType = 'Repeat / 양산';
    expect(d.validateAssess(), contains('원 프로젝트를 선택해주세요.'));
  });
  test('SL 제외 이력을 보존하고 예정번호를 재사용하지 않는다', () {
    final d = completePlatformVrb('SL');
    d.autoTitle = true;
    d.saveAssess('영업');
    expect(d.units.length, 2);
    final original = d.units.map((u) => u.number).toList();
    d.equipment['EFEM'] = 1;
    d.saveAssess('영업');
    expect(d.units.last.excluded, isTrue);
    d.equipment['EFEM'] = 2;
    d.saveAssess('영업');
    expect(d.units.length, 3);
    expect(d.units.map((u) => u.number).toSet().length, 3);
    expect(d.units.take(2).map((u) => u.number), original);
    expect(d.projectName, contains('고객_EFEM_300mm'));
  });
  test('엑셀 G18·G29·G30·G39·G40 및 견적금액 기준 예비비를 계산한다', () {
    final d = completePlatformVrb('VRB');
    expect(d.result['material'], 20000000);
    expect(d.result['manufacturing'], 5100000);
    expect(d.result['selling'], 3700000);
    expect(d.result['reserve'],
        3000000); // Excel G28 = G10 × I28, not material × 3%.
    expect(d.result['variable'], 31800000);
    expect(d.result['margin'], 68200000);
    expect(d.result['fixed'], 14400000);
    expect(d.result['op'], 53800000);
    expect(d.result['opRatio'], closeTo(53.8, .00001));
    d.projectType = '턴키(전체)';
    expect(d.result['op'], 68300000);
  });
  test('누락 비용·요율과 0원을 구분하며 환율이 유효할 때만 환산한다', () {
    final d = completePlatformVrb('MISSING');
    d.rates.remove('sga');
    expect(d.result['op'], isNull);
    d.rates['sga'] = '0';
    expect(d.result['op'], 58800000);
    d.bid = '잘못된 금액';
    expect(d.revenue, isNull);
    d.bid = '';
    d.quote['currency'] = 'USD';
    d.quote['fx'] = '';
    expect(d.quoteKrw, isNull);
    d.quote['fx'] = '1300';
    d.quoteLines.first.fields['price'] = '100';
    expect(d.quoteKrw, 130000);
  });
  test('VRB 저장 후 견적서 Rev를 보존하고 변경 시 결재·제출을 초기화한다', () {
    final d = completePlatformVrb('REV');
    expect(() => d.saveQuote('영업'), throwsStateError);
    d.saveVrb('영업');
    d.saveQuote('영업');
    expect(d.revisions.length, 1);
    d.saveQuote('영업');
    expect(d.revisions.length, 1);
    final saved = d.revisions.first;
    d.approval = '승인';
    d.submittedDate = '2026-10-26';
    d.reply = '금액 승인';
    expect(d.readyToNegotiate, isTrue);
    d.groups.first.rows.first.fields['price'] = '20000000';
    d.touchProposal();
    expect(d.readyToNegotiate, isFalse);
    expect((saved.data['result'] as Map)['material'], 20000000);
    final mutate = saved.data;
    mutate['bid'] = '0';
    expect(saved.data['bid'], '100000000');
  });
}
