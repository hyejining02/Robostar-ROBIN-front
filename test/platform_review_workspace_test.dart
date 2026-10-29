import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/screens/story_line_screens.dart';
import 'package:robin_portal/services/business_division_scope.dart';
import 'package:robin_portal/services/platform_review_service.dart';
import 'package:robin_portal/services/project_todo_service.dart';
import 'package:robin_portal/widgets/platform_review_workspace.dart';

class _PlatformFiles extends FileSelectorPlatform {
  @override
  Future<XFile?> openFile(
          {List<XTypeGroup>? acceptedTypeGroups,
          String? initialDirectory,
          String? confirmButtonText}) async =>
      XFile.fromData(Uint8List.fromList([1, 2, 3]),
          name: 'result.pdf', path: 'result.pdf');
}

void main() {
  late FileSelectorPlatform originalFiles;
  setUp(() {
    platformReviews.value = [];
    platformPriorityHistory.value = [];
    projectTodoItems.value = [];
    selectedBusinessDivision.value = RobinBusinessDivision.platformModule;
    originalFiles = FileSelectorPlatform.instance;
    FileSelectorPlatform.instance = _PlatformFiles();
  });
  tearDown(() {
    selectedBusinessDivision.value = null;
    FileSelectorPlatform.instance = originalFiles;
  });
  Future<void> open(WidgetTester tester,
      {Size size = const Size(1400, 1000)}) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: PlatformReviewWorkspace(initiallyExpanded: true)))));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final finder = find.byKey(ValueKey(key));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String key, String text) async {
    final finder = find.byKey(ValueKey(key));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, String key, String text) async {
    await tap(tester, key);
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<void> create(WidgetTester tester) async {
    await tap(tester, 'platform-review-create');
    for (final e in {
      'sl': 'SL-TEST-001',
      'project': '검토 테스트 과제',
      'customer': '테스트 고객',
      'designer': '이설계',
      'due': '2026-11-01',
      'spec': '두 항목 검토 요청'
    }.entries) {
      await enter(tester, 'platform-request-${e.key}', e.value);
    }
    await tap(tester, 'platform-request-save');
  }

  Future<void> complete(WidgetTester tester, PlatformReviewKind kind) async {
    await tap(tester, 'platform-reply-${kind.name}');
    await choose(tester, 'platform-reply-status', '검토완');
    await tap(tester, 'platform-reply-save');
    expect(find.textContaining('검토완은 결과 파일'), findsOneWidget);
    await tap(tester, 'platform-reply-attach');
    await enter(tester, 'platform-text-input', 'Rev.01');
    await tester.tap(find.text('확인').last);
    await tester.pumpAndSettle();
    await tap(tester, 'platform-reply-save');
  }

  testWidgets('SL 요청 후 두 검토를 각각 회신하고 결과 파일 Rev를 보존한다', (tester) async {
    await open(tester);
    await create(tester);
    expect(platformReviews.value.single.request.fields['sl'], 'SL-TEST-001');
    await choose(tester, 'platform-review-demo-role', '설계 회신 시연');
    await complete(tester, PlatformReviewKind.material);
    expect(platformReviews.value.single.status, '검토중');
    expect(find.textContaining('전체 검토완', findRichText: false), findsWidgets);
    await complete(tester, PlatformReviewKind.layout);
    expect(platformReviews.value.single.status, '검토완');
    expect(platformReviews.value.single.replies.length, 2);
    expect(
        platformReviews.value.single.replies.first.result!.revision, 'Rev.01');
    expect(tester.takeException(), isNull);
  });
  testWidgets('수정 요청은 새 Rev로 돌아가고 수주관리도 같은 SL 목록을 조회한다', (tester) async {
    await open(tester);
    await create(tester);
    await tap(tester, 'platform-review-edit');
    await enter(tester, 'platform-request-stroke', '700');
    await enter(tester, 'platform-request-order', 'SO-REFERENCE-001');
    await enter(tester, 'platform-request-reason', '고객 협의 변경');
    await tap(tester, 'platform-request-save');
    expect(platformReviews.value.single.request.revision, 2);
    await tester.pumpWidget(const MaterialApp(home: OrderManagementScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('플랫폼 수주 전 검토 · SL CODE'));
    await tester.pumpAndSettle();
    expect(find.text('SL-TEST-001'), findsOneWidget);
    expect(find.textContaining('SO-REFERENCE-001'), findsOneWidget);
    selectedBusinessDivision.value = RobinBusinessDivision.robot;
    await tester.pumpAndSettle();
    expect(find.text('플랫폼 수주 전 검토 · SL CODE'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('좁은 화면의 등록·목록·검색에서 overflow가 발생하지 않는다', (tester) async {
    await open(tester, size: const Size(700, 900));
    await create(tester);
    await enter(tester, 'platform-review-search', 'SL-TEST');
    expect(find.text('SL-TEST-001'), findsOneWidget);
    await enter(tester, 'platform-review-search', '없는번호');
    expect(find.text('SL-TEST-001'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
