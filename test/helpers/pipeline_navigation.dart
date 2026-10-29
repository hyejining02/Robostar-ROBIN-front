import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/services/business_division_scope.dart';

void usePlatformPipeline() {
  final previous = selectedBusinessDivision.value;
  selectedBusinessDivision.value = RobinBusinessDivision.platformModule;
  addTearDown(() => selectedBusinessDivision.value = previous);
}

Future<void> openPlatformTraffic(WidgetTester tester) async {
  final legacy = find.byKey(const ValueKey('platform-legacy-traffic'));
  if (legacy.evaluate().isEmpty) return;
  if (find.text('물동 Excel 불러오기').evaluate().isNotEmpty) return;
  await Scrollable.ensureVisible(tester.element(legacy), alignment: .5);
  await tester.pumpAndSettle();
  await tester.tap(find.text('기존 물동 Excel · ERP 번호 매칭'));
  await tester.pumpAndSettle();
  final upload = find.text('물동 Excel 불러오기');
  if (upload.evaluate().isNotEmpty) {
    await Scrollable.ensureVisible(tester.element(upload), alignment: .35);
    await tester.pumpAndSettle();
  }
}

Future<void> selectPipelineStatus(WidgetTester tester, String status,
    {String? number}) async {
  final filter = find.byKey(const ValueKey('pipeline-search-stage'));
  await tester.ensureVisible(filter);
  await tester.pumpAndSettle();
  await tester.tap(filter);
  await tester.pumpAndSettle();
  await tester.tap(find.text(status).last);
  await tester.pumpAndSettle();
  if (number != null) {
    final row = find.byKey(ValueKey('pipeline-overview-$number'));
    await Scrollable.ensureVisible(tester.element(row), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
  }
}
