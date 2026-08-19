import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/main.dart';

void main() {
  Future<void> setDesktopSize(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('ROBIN 로그인 화면을 표시한다', (tester) async {
    await setDesktopSize(tester);
    await tester.pumpWidget(const RobinPortalApp());
    await tester.pumpAndSettle();

    expect(find.text('ROBIN 포털 로그인'), findsOneWidget);
    expect(find.text('아이디'), findsOneWidget);
    expect(find.text('비밀번호'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);
    expect(find.text('로그인없이 둘러보기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('빈 로그인 제출 시 입력 안내를 표시한다', (tester) async {
    await setDesktopSize(tester);
    await tester.pumpWidget(const RobinPortalApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('로그인'));
    await tester.pump();

    expect(find.text('아이디와 비밀번호를 입력해주세요.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
