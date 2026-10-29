import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/screens/story_line_screens.dart';
import 'package:robin_portal/screens/pipeline_registration_screen.dart';
import 'package:robin_portal/services/product_identity_service.dart';
import 'package:robin_portal/widgets/product_identity_panel.dart';
import 'helpers/pipeline_navigation.dart';
import 'helpers/smart_order_specification.dart';

void main() {
  const record = (RobinBusinessDivision.robot, 'RB-2608-014');
  setUp(() {
    productIdentities.value = {};
    proposalSpecifications.value = {};
  });
  tearDown(() {
    productIdentities.value = {};
    proposalSpecifications.value = {};
  });

  test('제품코드·제품번호·도면번호와 사업부를 독립 관리한다', () {
    saveProductIdentity(
        record,
        const ProductIdentity(
            productCode: 'CODE-01',
            productNumber: 'PRODUCT-02',
            drawingNumber: 'DRAW-03'),
        author: '작성자');
    final stored = identityFor(record);
    expect(stored.productCode, 'CODE-01');
    expect(stored.productNumber, 'PRODUCT-02');
    expect(stored.drawingNumber, 'DRAW-03');
    expect(stored.status, '입력 코드 · 공식 검증 전');
    expect(
        identityFor((RobinBusinessDivision.platformModule, record.$2))
            .productCode,
        isEmpty);
    expect(identityFor((RobinBusinessDivision.robot, '다른 번호')).productNumber,
        isEmpty);
    expect(identityFor((RobinBusinessDivision.robot, '미입력')).status,
        '생성 규칙 확인 필요');
  });

  test('코드가 있는 사양 변경은 이력과 코드 재확인 상태를 남긴다', () {
    saveProductIdentity(
        record,
        const ProductIdentity(
            productCode: 'CODE-01',
            specification:
                ProductSpecification(model: 'RS', motorDirection: '상')),
        author: '영업');
    saveProductIdentity(
        record,
        const ProductIdentity(
            productCode: 'CODE-01',
            specification:
                ProductSpecification(model: 'RS', motorDirection: '하')),
        author: '설계');
    expect(identityFor(record).needsReview, isTrue);
    expect(identityFor(record).revision, 2);
    expect(identityFor(record).history.last, contains('모터 방향: 상 → 하'));
    expect(identityFor(record).productCode, 'CODE-01');
  });

  Future<void> openEditor(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1800, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: ProductIdentityPanel(recordKey: record))));
    await tester
        .tap(find.byKey(const ValueKey('edit-product-identity-RB-2608-014')));
    await tester.pumpAndSettle();
  }

  testWidgets('컨셉 사양 불러오기는 실제 입력값만 가져오고 번호를 생성하지 않는다', (tester) async {
    updateProposalSpecification(record, 'model', 'RS-TEST');
    updateProposalSpecification(record, 'stroke', '750');
    updateProposalSpecification(record, 'motor', '우');
    await openEditor(tester);
    await tester.tap(find.byKey(const ValueKey('identity-load-spec')));
    await tester.pumpAndSettle();
    TextFormField input(String id) =>
        tester.widget<TextFormField>(find.byKey(ValueKey('identity-$id')));
    expect(input('model').controller!.text, 'RS-TEST');
    expect(input('stroke').controller!.text, '750');
    expect(input('motor').controller!.text, '우');
    expect(input('sensor').controller!.text, isEmpty);
    expect(input('code').controller!.text, isEmpty);
    await tester.enterText(
        find.byKey(const ValueKey('identity-code')), 'MANUAL-01');
    await tester.enterText(
        find.byKey(const ValueKey('identity-number')), 'PRODUCT-01');
    await tester.enterText(
        find.byKey(const ValueKey('identity-drawing')), 'DRAWING-01');
    await tester.tap(find.byKey(const ValueKey('identity-save')));
    await tester.pumpAndSettle();
    expect(identityFor(record).specification.stroke, '750');
    expect(identityFor(record).drawingNumber, 'DRAWING-01');
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const MaterialApp(home: OrderManagementScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('자동화라인 증설'));
    await tester.pumpAndSettle();
    expect(find.text('제품코드: MANUAL-01'), findsOneWidget);
    expect(find.text('제품번호: PRODUCT-01'), findsOneWidget);
    expect(find.text('도면번호: DRAWING-01'), findsOneWidget);
    expect(find.text('PDM Rev.03 연계'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('사양 원천이 없으면 추정하지 않으며 취소하면 저장하지 않는다', (tester) async {
    await openEditor(tester);
    await tester.tap(find.byKey(const ValueKey('identity-load-spec')));
    await tester.pumpAndSettle();
    expect(find.textContaining('연결된 컨셉/레이아웃 사양이 없습니다'), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('identity-code')), '취소할 코드');
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(productIdentities.value, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('음수 Stroke는 저장하지 않는다', (tester) async {
    await openEditor(tester);
    await tester.enterText(
        find.byKey(const ValueKey('identity-stroke')), '-10');
    await tester.tap(find.byKey(const ValueKey('identity-save')));
    await tester.pumpAndSettle();
    expect(find.text('0 이상의 숫자를 입력해주세요.'), findsOneWidget);
    expect(productIdentities.value, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Proposal에서 입력한 사양이 동일 건 식별정보로 연결된다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1800, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PipelineRegistrationView())));
    await selectPipelineStatus(tester, 'Proposal', number: 'RB-2608-014');
    await tester.pumpAndSettle();
    await fillSmartOrderSpecification(tester, 'RB-2608-014');
    await applySmartOrderSpecification(tester);
    final edit =
        find.byKey(const ValueKey('edit-product-identity-RB-2608-014'));
    await tester.ensureVisible(edit);
    await tester.tap(edit);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('identity-load-spec')));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('identity-model')))
            .controller!
            .text,
        'ROBOT-INPUT');
    expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('identity-motor')))
            .controller!
            .text,
        isEmpty);
    expect(
        proposalSpecifications.value[record]!.smartOrderOptions['Motor Type'],
        '직렬');
    expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('identity-code')))
            .controller!
            .text,
        isEmpty);
    await tester.tap(find.byKey(const ValueKey('identity-save')));
    await tester.pumpAndSettle();
    expect(identityFor(record).specification.smartOrderOptions['Motor Type'],
        '직렬');
    expect(
        identityFor(record).specification.smartOrderOptions['MOTOR 용량'], '400');
    expect(tester.takeException(), isNull);
  });

  testWidgets('작은 화면 120% 배율에서도 편집 팝업을 스크롤해 저장한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(650, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.2)),
          child: child!),
      home: const Scaffold(body: ProductIdentityPanel(recordKey: record)),
    ));
    await tester
        .tap(find.byKey(const ValueKey('edit-product-identity-RB-2608-014')));
    await tester.pumpAndSettle();
    final drawing = find.byKey(const ValueKey('identity-drawing'));
    await tester.ensureVisible(drawing);
    await tester.enterText(drawing, 'DWG-MANUAL');
    await tester.tap(find.byKey(const ValueKey('identity-save')));
    await tester.pumpAndSettle();
    expect(identityFor(record).drawingNumber, 'DWG-MANUAL');
    expect(tester.takeException(), isNull);
  });
}
