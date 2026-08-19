import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/screens/dashboard_screen.dart';
import 'package:robin_portal/screens/pipeline_registration_screen.dart';
import 'package:robin_portal/screens/portal_module_screen.dart';
import 'package:robin_portal/screens/story_line_screens.dart';

void main() {
  Future<void> setDesktopSize(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1800, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('Home에서 To-Do가 가장 먼저 표시된다', (tester) async {
    await setDesktopSize(tester);
    await tester.pumpWidget(
      MaterialApp(home: DashboardScreen(onNavigate: (_) {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('To-Do List'), findsOneWidget);
    expect(find.text('공지사항'), findsOneWidget);
    expect(find.text('업데이트 사항'), findsOneWidget);
    expect(find.text('AI Assistant'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('파이프라인 단계별 입력 화면을 연다', (tester) async {
    await setDesktopSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: PortalModuleScreen(type: PortalModule.pipeline),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('단계별 입력'));
    await tester.pumpAndSettle();
    expect(find.text('Assess · 물동'), findsOneWidget);
    expect(find.text('Proposal · 컨셉설계'), findsOneWidget);
    expect(find.text('Negotiation · 원가/결재'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Proposal 나래비와 Negotiation 원가 검증을 표시한다', (tester) async {
    await setDesktopSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: PortalModuleScreen(type: PortalModule.pipeline),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('수주를 선택하면'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pipeline-stage-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('proposal-RB-2608-014')));
    await tester.pumpAndSettle();
    expect(find.text('예상 물동'), findsOneWidget);
    expect(find.text('컨셉 도면'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('pipeline-stage-2')));
    await tester.pumpAndSettle();
    expect(find.text('특주 제품 사양'), findsOneWidget);
    expect(find.textContaining('ERP 제품코드 중복 검증'), findsOneWidget);
    expect(find.text('ROBIN 결재시스템'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('수주관리 원가 및 결재 상세를 연다', (tester) async {
    await setDesktopSize(tester);
    await tester.pumpWidget(
      const MaterialApp(home: OrderManagementScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('RB-2608-014'));
    await tester.pumpAndSettle();
    expect(find.text('원가 시뮬레이션'), findsOneWidget);
    expect(find.text('결재선'), findsOneWidget);
    expect(find.text('제안검토 · 수주 사양 변경이력'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('프로젝트관리의 7단계와 입력 탭을 표시한다', (tester) async {
    await setDesktopSize(tester);
    await tester.pumpWidget(
      const MaterialApp(home: ProjectManagementScreen()),
    );
    await tester.pumpAndSettle();

    for (final stage in ['수주', '설계', '구매', '생산', '품질', '물류', '마감']) {
      expect(find.text(stage), findsWidgets);
    }
    await tester.tap(find.text('품질').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('IQC'), findsWidgets);
    await tester.tap(find.text('검사 결과 입력'));
    await tester.pumpAndSettle();
    expect(find.text('품질 검사 결과 입력'), findsOneWidget);
    expect(find.text('기본값 0(양품)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('작은 업무 영역에서 세 화면의 글자가 잘리지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1120, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Widget scaled(Widget home) => MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.2)),
            child: child!,
          ),
          home: home,
        );

    await tester.pumpWidget(
        scaled(const PortalModuleScreen(type: PortalModule.pipeline)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('pipeline-stage-1')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('pipeline-stage-2')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(scaled(const OrderManagementScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(scaled(const ProjectManagementScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('데스크톱 창에서 세 관리 표의 오른쪽 열이 가려지지 않는다', (tester) async {
    Future<void> expectTableFits(Widget screen, Size size) async {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: screen)));
      await tester.pumpAndSettle();
      final controlledHorizontalScrolls = tester
          .widgetList<SingleChildScrollView>(
            find.byType(SingleChildScrollView),
          )
          .where(
            (scroll) =>
                scroll.scrollDirection == Axis.horizontal &&
                scroll.controller?.hasClients == true,
          );
      expect(controlledHorizontalScrolls, isNotEmpty);
      for (final scroll in controlledHorizontalScrolls) {
        expect(scroll.controller!.position.maxScrollExtent, closeTo(0, .01));
      }
      expect(tester.takeException(), isNull);
    }

    addTearDown(() => tester.binding.setSurfaceSize(null));
    await expectTableFits(
      const PipelineRegistrationView(),
      const Size(1017, 760),
    );
    await expectTableFits(
      const PipelineRegistrationView(),
      const Size(1687, 900),
    );
    expect(
      tester.getSize(find.byType(DataTable).first).width,
      greaterThan(1200),
    );
    await expectTableFits(
      const OrderManagementScreen(),
      const Size(1377, 850),
    );
    await expectTableFits(
      const ProjectManagementScreen(),
      const Size(1377, 850),
    );
  });
}
