import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> fillSmartOrderSpecification(WidgetTester tester, String number,
    {String model = 'ROBOT-INPUT'}) async {
  for (final entry in {
    'model': model,
    'motor': '직렬',
    'axis': 'X',
    'stroke': '1000',
    'screwMount': '고정-지지',
    'screw': '시험 입력',
    'baseMount': '표준',
    'cover': '표준',
    'maker': '시험 MAKER',
    'series': '시험 SERIES',
    'capacity': '400',
  }.entries) {
    final field = find.byKey(ValueKey('proposal-${entry.key}-$number'));
    await Scrollable.ensureVisible(tester.element(field), alignment: .5);
    await tester.pumpAndSettle();
    await tester.enterText(field, entry.value);
    await tester.pump();
  }
}

Future<void> applySmartOrderSpecification(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('smartorder-apply'));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}
