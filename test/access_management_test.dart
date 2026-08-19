import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/screens/access_management_screen.dart';

void main() {
  testWidgets('Python 권한 그룹 추가 다이얼로그를 열고 저장한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: PermissionManagementScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Python 그룹 관리'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    expect(find.text('Python 권한 그룹 추가'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '테스트 Python');
    await tester.tap(find.widgetWithText(FilledButton, '저장'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('테스트 Python'), findsWidgets);
  });

  testWidgets('Python 앱과 기능 권한 추가 다이얼로그를 연다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: PermissionManagementScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Python 앱·기능 관리'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('Python 앱 추가'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '취소'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, '기능 권한 추가'));
    await tester.pumpAndSettle();

    expect(find.textContaining('기능 권한 추가'), findsWidgets);
    await tester.tap(find.widgetWithText(TextButton, '취소'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('직원 권한 수정 다이얼로그를 열고 닫는다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(2200, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: EmployeeManagementScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('직원 수정·권한 변경').first);
    await tester.pumpAndSettle();
    expect(find.text('직원 수정·권한 변경'), findsWidgets);

    await tester.tap(find.widgetWithText(TextButton, '취소'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
