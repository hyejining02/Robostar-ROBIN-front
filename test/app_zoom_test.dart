import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/widgets/app_zoom.dart';

void main() {
  testWidgets('Ctrl + 마우스 휠로 앱 배율을 변경하고 초기화한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppZoom(child: Scaffold(body: Text('ROBIN'))),
      ),
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendEventToBinding(
      const PointerScrollEvent(
        position: Offset(200, 200),
        scrollDelta: Offset(0, -120),
      ),
    );
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(find.text('110%'), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-zoom-reset')));
    await tester.pump();

    expect(find.byKey(const Key('app-zoom-value')), findsNothing);
  });

  testWidgets('일반 마우스 휠은 앱 배율을 변경하지 않는다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppZoom(child: Scaffold(body: Text('ROBIN'))),
      ),
    );

    await tester.sendEventToBinding(
      const PointerScrollEvent(
        position: Offset(200, 200),
        scrollDelta: Offset(0, -120),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('app-zoom-value')), findsNothing);
  });
}
