import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/services/product_identity_service.dart';
import 'package:robin_portal/widgets/smart_order_specification_panel.dart';
import 'helpers/smart_order_specification.dart';

void main() {
  const record = (RobinBusinessDivision.robot, 'SPEC-001');
  setUp(() => proposalSpecifications.value = {});
  tearDown(() => proposalSpecifications.value = {});

  Future<void> open(WidgetTester tester, {double width = 678}) async {
    const captureFont = String.fromEnvironment('SPEC_FONT');
    if (captureFont.isNotEmpty) {
      await tester.runAsync(() async {
        final loader = FontLoader('CaptureFont')
          ..addFont(Future.value(
              ByteData.sublistView(File(captureFont).readAsBytesSync())));
        await loader.load();
      });
    }
    await tester.binding.setSurfaceSize(Size(width, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        theme:
            ThemeData(fontFamily: captureFont.isEmpty ? null : 'CaptureFont'),
        home: const Scaffold(
          body: SingleChildScrollView(
              child: RepaintBoundary(
            key: ValueKey('capture-spec'),
            child: SmartOrderSpecificationPanel(recordKey: record),
          )),
        )));
    await tester.pumpAndSettle();
  }

  testWidgets('사진의 두 단 구성과 비활성 옵션을 표시하고 좁은 화면에서 재배치한다', (tester) async {
    await open(tester);
    expect(tester.getTopLeft(find.text('선택 옵션')).dx,
        greaterThan(tester.getTopLeft(find.text('필수 선택 항목')).dx));
    expect(find.text('Motor Type 을 먼저 선택하세요'), findsNWidgets(3));
    expect(
        tester
            .widget<FilledButton>(
                find.byKey(const ValueKey('smartorder-apply')))
            .onPressed,
        isNull);
    if (const bool.fromEnvironment('CAPTURE_SPEC')) {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('capture-spec')));
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        File('.dart_tool/smart_order_specification.png')
            .writeAsBytesSync(data!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.binding.setSurfaceSize(const Size(430, 900));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('선택 옵션')).dy,
        greaterThan(tester.getTopLeft(find.text('필수 선택 항목')).dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('입력 중 사양은 저장하지 않으며 적용 시 전체 옵션을 동일 수주에 저장한다', (tester) async {
    await open(tester);
    await fillSmartOrderSpecification(tester, 'SPEC-001');
    expect(proposalSpecifications.value, isEmpty);
    await applySmartOrderSpecification(tester);
    final saved = proposalSpecifications.value[record]!;
    expect(saved.model, 'ROBOT-INPUT');
    expect(saved.stroke, '1000');
    expect(saved.smartOrderOptions['Motor Type'], '직렬');
    expect(saved.smartOrderOptions['MOTOR 용량'], '400');
    expect(saved.smartOrderOptions['배면특주'], 'N');
    await tester.pumpWidget(const SizedBox());
    await open(tester);
    expect(
        tester
            .widget<TextField>(
                find.byKey(const ValueKey('proposal-axis-SPEC-001')))
            .controller!
            .text,
        'X');
    expect(tester.takeException(), isNull);
  });

  testWidgets('스트로크 범위를 벗어나면 적용을 막는다', (tester) async {
    await open(tester);
    await fillSmartOrderSpecification(tester, 'SPEC-001');
    final stroke = find.byKey(const ValueKey('proposal-stroke-SPEC-001'));
    await tester.ensureVisible(stroke);
    await tester.enterText(stroke, '55');
    await tester.pumpAndSettle();
    expect(find.text('50~2000mm, 10mm 단위로 입력해주세요.'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(
                find.byKey(const ValueKey('smartorder-apply')))
            .onPressed,
        isNull);
    expect(proposalSpecifications.value, isEmpty);
  });
  testWidgets('설계 검토에서 저장한 사양 변경을 입력 화면에 동기화한다', (tester) async {
    await open(tester);
    updateProposalSpecification(record, 'model', '설계 수정 모델');
    updateProposalSpecification(record, 'stroke', '500');
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<TextField>(
                find.byKey(const ValueKey('proposal-model-SPEC-001')))
            .controller!
            .text,
        '설계 수정 모델');
    expect(
        tester
            .widget<TextField>(
                find.byKey(const ValueKey('proposal-stroke-SPEC-001')))
            .controller!
            .text,
        '500');
    expect(tester.takeException(), isNull);
  });
}
