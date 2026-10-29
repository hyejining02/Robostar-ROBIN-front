import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/screens/pipeline_registration_screen.dart';
import 'package:robin_portal/services/business_division_scope.dart';
import 'package:robin_portal/services/desktop_file_service.dart';
import 'package:robin_portal/services/traffic_excel_service.dart';
import 'helpers/pipeline_navigation.dart';

void main() {
  setUp(() =>
      selectedBusinessDivision.value = RobinBusinessDivision.platformModule);
  tearDown(() => selectedBusinessDivision.value = null);
  Future<void> size(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1800, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('파일 선택 취소는 등록과 검증 팝업을 만들지 않는다', (tester) async {
    await size(tester);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: PipelineRegistrationView(
                loadTrafficWorkbook: () async => null))));
    await tester.pumpAndSettle();
    await openPlatformTraffic(tester);
    await tester.tap(find.text('물동 Excel 불러오기'));
    await tester.pumpAndSettle();
    expect(find.text('물동 Excel 업로드 검증'), findsNothing);
    expect(find.textContaining('불러오기 실패'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('오류 행만 있으면 시트/행/열을 알리고 신규 등록을 비활성화한다', (tester) async {
    await size(tester);
    final row = List<Object?>.filled(47, null);
    row[20] = '오류 테스트';
    final bytes = DesktopFileService.createWorkbookBytes(
        sheetName: '입력', headers: trafficHeaders, rows: [row]);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: PipelineRegistrationView(
                loadTrafficWorkbook: () async =>
                    (name: '오류.xlsx', bytes: bytes)))));
    await tester.pumpAndSettle();
    await openPlatformTraffic(tester);
    await tester.tap(find.text('물동 Excel 불러오기'));
    await tester.pumpAndSettle();
    expect(find.text('오류 1건'), findsOneWidget);
    expect(find.text('입력!2행 · 오류'), findsOneWidget);
    expect(find.textContaining('AE2'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(
                find.byKey(const ValueKey('confirm-excel-import')))
            .onPressed,
        isNull);
    expect(tester.takeException(), isNull);
  });
}
