import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robin_portal/models/access_control.dart';
import 'package:robin_portal/screens/dashboard_screen.dart';
import 'package:robin_portal/screens/pipeline_registration_screen.dart';
import 'package:robin_portal/screens/portal_module_screen.dart';
import 'package:robin_portal/screens/story_line_screens.dart';
import 'package:robin_portal/services/project_todo_service.dart';
import 'package:robin_portal/widgets/user_profile.dart';

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
    expect(find.text('팀별·담당자별 업무 부하 현황'), findsOneWidget);
    expect(find.text('로봇 영업1팀'), findsWidgets);
    expect(find.textContaining('최플랫폼'), findsWidgets);
    expect(find.text('전체 조회에서는 팀 요약만 표시합니다.'), findsOneWidget);
    expect(find.text('로봇 영업1팀 팀원별 업무 부하 현황'), findsNothing);
    expect(find.text('전체 사업부'), findsOneWidget);
    expect(find.text('물류 자동화 프로젝트'), findsOneWidget);
    expect(find.text('스마트 팩토리 플랫폼 구축'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('todo-division-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('플랫폼·모듈 사업담당').last);
    await tester.pumpAndSettle();

    expect(find.text('스마트 팩토리 플랫폼 구축'), findsOneWidget);
    expect(find.text('물류 자동화 프로젝트'), findsNothing);
    expect(find.text('조회 2건'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('workload-team-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('로봇 영업1팀').last);
    await tester.pumpAndSettle();

    expect(find.text('선택한 팀의 팀원 3명을 표시합니다.'), findsOneWidget);
    expect(find.text('로봇 영업1팀 팀원별 업무 부하 현황'), findsOneWidget);
    expect(find.textContaining('박로빈'), findsWidgets);
    expect(find.textContaining('정영업'), findsWidgets);
    expect(find.textContaining('한로봇'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('팀장이 아닌 대리점 계정에는 팀 업무 부하를 숨긴다', (tester) async {
    await setDesktopSize(tester);
    final previousProfile = robinUserProfile.value;
    addTearDown(() => robinUserProfile.value = previousProfile);
    final dealer = robinEmployees.value.firstWhere(
      (employee) => employee.role == RobinAccountRole.dealer,
    );
    robinUserProfile.value = RobinUserProfile(
      name: dealer.name,
      department: dealer.department,
      rank: dealer.rank,
      email: dealer.email,
      phone: dealer.phone,
      username: dealer.id,
      role: dealer.role,
      departmentPermission: dealer.departmentPermission,
    );

    await tester.pumpWidget(
      MaterialApp(home: DashboardScreen(onNavigate: (_) {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('팀별·담당자별 업무 부하 현황'), findsNothing);
    expect(find.text('To-Do List'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('일반 직원은 소속 사업부 To-Do만 조회한다', (tester) async {
    await setDesktopSize(tester);
    final previousProfile = robinUserProfile.value;
    addTearDown(() => robinUserProfile.value = previousProfile);
    final employee = robinEmployees.value.firstWhere(
      (item) => item.id == 'platform_staff',
    );
    robinUserProfile.value = RobinUserProfile(
      name: employee.name,
      department: employee.department,
      rank: employee.rank,
      email: employee.email,
      phone: employee.phone,
      username: employee.id,
      role: employee.role,
      departmentPermission: employee.departmentPermission,
    );

    await tester.pumpWidget(
      MaterialApp(home: DashboardScreen(onNavigate: (_) {})),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('todo-division-filter')), findsNothing);
    expect(find.text('플랫폼·모듈 사업담당'), findsWidgets);
    expect(find.text('스마트 팩토리 플랫폼 구축'), findsOneWidget);
    expect(find.text('물류 자동화 프로젝트'), findsNothing);
    expect(find.text('오늘 처리할 To-Do  2건'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('마이페이지에서 본인의 권한 품의 내역만 조회한다', (tester) async {
    await setDesktopSize(tester);
    final previousProfile = robinUserProfile.value;
    addTearDown(() => robinUserProfile.value = previousProfile);
    final employee =
        robinEmployees.value.firstWhere((item) => item.id == 'staff');
    robinUserProfile.value = RobinUserProfile(
      name: employee.name,
      department: employee.department,
      rank: employee.rank,
      email: employee.email,
      phone: employee.phone,
      username: employee.id,
      role: employee.role,
      departmentPermission: employee.departmentPermission,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: PortalModuleScreen(type: PortalModule.myPage),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('권한 신청 진행'), findsOneWidget);
    expect(find.text('1건'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('my-permission-history-tab')));
    await tester.pumpAndSettle();

    expect(find.textContaining('RBN-APR-20260730-001'), findsOneWidget);
    expect(find.textContaining('RBN-APR-20260729-002'), findsNothing);
    expect(find.text('승인 대기'), findsOneWidget);
    expect(find.textContaining('영업 방문차량 및 분석 업무'), findsOneWidget);
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
    expect(find.text('수주 중단'), findsNothing);
    expect(find.text('Proposal · 컨셉설계'), findsOneWidget);
    expect(find.text('Negotiation · 원가/결재'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Assess 물동은 상세 버튼에서만 47개 전체 항목을 연다', (tester) async {
    await setDesktopSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PipelineRegistrationView()),
      ),
    );
    await tester.pumpAndSettle();

    // 일반 행 선택은 선택 상태만 바꾸고 상세창을 열지 않는다.
    await tester.tap(find.text('LGD 베트남 EGL 3D wafer 세정기'));
    await tester.pumpAndSettle();
    expect(find.text('Assess 수주물동 전체 상세'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('assess-detail-button-RB-2608-021')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Assess 수주물동 전체 상세'), findsOneWidget);
    expect(find.text('전체 47열 · 업무 44개'), findsOneWidget);
    for (final section in [
      '기본·조직',
      '제품·매출 분류',
      '고객·프로젝트',
      '금액·원가',
      '등급·반영',
      '원본 계산 보조열',
    ]) {
      expect(find.text(section), findsOneWidget);
    }
    for (final field in [
      '주차',
      'ERP 수주번호',
      '수익성구분',
      '외화매출액',
      '지급수수료(백만원)',
      '조정 재료비(억원)',
      'AU (헤더 없음)',
    ]) {
      expect(find.text(field), findsWidgets);
    }
    expect(find.text('미매칭 (가수주 RB-2608-021)'), findsOneWidget);
    expect(find.text('재료비율'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('물동 Excel 검증 후 신규 행에 가수주번호를 자동 채번한다', (tester) async {
    await setDesktopSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PipelineRegistrationView()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('물동 Excel 불러오기'));
    await tester.pumpAndSettle();
    expect(find.text('물동 Excel 업로드 검증'), findsOneWidget);
    expect(find.text('전체 47열'), findsOneWidget);
    expect(find.text('신규 2건'), findsOneWidget);
    expect(find.text('중복 검토 1건'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('confirm-excel-import')));
    await tester.pumpAndSettle();

    expect(find.text('물동 Excel 업로드 검증'), findsNothing);
    expect(find.text('2차전지 조립라인 로봇 자동화'), findsWidgets);
    expect(find.text('디스플레이 물류 이송 로봇'), findsWidgets);
    expect(find.text('LGD 베트남 EGL 3D wafer 세정기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('가수주번호에 ERP 공식 수주번호를 매칭한다', (tester) async {
    await setDesktopSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PipelineRegistrationView()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('LGD 베트남 EGL 3D wafer 세정기'));
    await tester.pumpAndSettle();
    expect(find.text('Assess 수주물동 전체 상세'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('open-erp-order-match')));
    await tester.pumpAndSettle();
    expect(find.text('ERP 공식 수주번호 매칭'), findsOneWidget);
    expect(find.text('RB-2608-021'), findsWidgets);

    await tester.enterText(
      find.byKey(const ValueKey('erp-order-number-input')),
      'so-2608-099',
    );
    await tester.tap(find.byKey(const ValueKey('confirm-erp-order-match')));
    await tester.pumpAndSettle();

    expect(find.text('RB-2608-021\nSO-2608-099'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('assess-detail-button-RB-2608-021')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Assess 수주물동 전체 상세'), findsOneWidget);
    expect(find.text('SO-2608-099'), findsOneWidget);
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

  testWidgets('Proposal에서 도면 버전·댓글·스펙 복사 협업을 저장한다', (tester) async {
    await setDesktopSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PipelineRegistrationView()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('pipeline-stage-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('proposal-RB-2608-014')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('proposal-collaboration-RB-2608-014')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Proposal 도면·댓글 협업'), findsOneWidget);
    expect(find.text('Layout_Concept_Rev03.pdf'), findsOneWidget);
    expect(find.text('스펙 복사 입력'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('copy-proposal-spec')));
    await tester.pumpAndSettle();
    expect(find.text('스펙 복사 완료'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('attach-proposal-file')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('proposal-file-name-input')),
      'Layout_Concept_Rev04.pdf',
    );
    await tester.tap(find.byKey(const ValueKey('confirm-proposal-file')));
    await tester.pumpAndSettle();
    expect(find.text('Layout_Concept_Rev04.pdf'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('proposal-comment-input')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('proposal-comment-input')),
      '안전펜스 변경사항 확인 완료했습니다.',
    );
    await tester.tap(find.byKey(const ValueKey('post-proposal-comment')));
    await tester.pumpAndSettle();
    expect(find.text('안전펜스 변경사항 확인 완료했습니다.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('save-proposal-collaboration')));
    await tester.pumpAndSettle();
    expect(find.text('Proposal 도면·댓글 협업'), findsNothing);
    expect(find.textContaining('첨부 4건 · 댓글 3건'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('사내 계정은 유사 모델 단가와 재료비율 결재선을 조회한다', (tester) async {
    await setDesktopSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PipelineRegistrationView()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('pipeline-stage-2')));
    await tester.pumpAndSettle();
    expect(find.text('유사 모델 단가 근거 TOP 3'), findsOneWidget);
    expect(find.text('재료비율 결재선 · 임시 기준'), findsOneWidget);
    expect(find.text('ROBIN 단가표 관리'), findsOneWidget);

    await tester.tap(find.text('ROBIN 단가표 관리'));
    await tester.pumpAndSettle();
    expect(find.text('ROBIN 표준 단가표'), findsOneWidget);
    expect(find.text('단가 변경 이력'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('대리점 계정은 본인 Proposal 도면 협업만 표시한다', (tester) async {
    final previousProfile = robinUserProfile.value;
    addTearDown(() => robinUserProfile.value = previousProfile);
    final dealer = robinEmployees.value.firstWhere(
      (employee) => employee.role == RobinAccountRole.dealer,
    );
    robinUserProfile.value = RobinUserProfile(
      name: dealer.name,
      department: dealer.department,
      rank: dealer.rank,
      email: dealer.email,
      phone: dealer.phone,
      username: dealer.id,
      role: dealer.role,
      departmentPermission: dealer.departmentPermission,
    );
    await setDesktopSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PipelineRegistrationView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('컨셉도면 송수신'), findsOneWidget);
    expect(find.textContaining('RB-2608-011'), findsOneWidget);
    expect(find.textContaining('RB-2608-014'), findsNothing);
    expect(find.text('도면·댓글 송수신'), findsOneWidget);
    expect(find.byKey(const ValueKey('pipeline-stage-2')), findsNothing);
    expect(find.text('ROBIN 단가표 관리'), findsNothing);
    expect(find.text('유사 모델 단가 근거 TOP 3'), findsNothing);
    expect(find.text('재료비율 결재선 · 임시 기준'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('대리점 계정은 본인 입찰과 진행단계를 읽기 전용으로 조회한다', (tester) async {
    final previousProfile = robinUserProfile.value;
    addTearDown(() => robinUserProfile.value = previousProfile);
    final dealer = robinEmployees.value.firstWhere(
      (employee) => employee.role == RobinAccountRole.dealer,
    );
    robinUserProfile.value = RobinUserProfile(
      name: dealer.name,
      department: dealer.department,
      rank: dealer.rank,
      email: dealer.email,
      phone: dealer.phone,
      username: dealer.id,
      role: dealer.role,
      departmentPermission: dealer.departmentPermission,
    );
    await setDesktopSize(tester);

    await tester.pumpWidget(const MaterialApp(home: OrderManagementScreen()));
    await tester.pumpAndSettle();
    expect(find.text('내 입찰'), findsWidgets);
    expect(find.textContaining('RB-2608-014'), findsOneWidget);
    expect(find.textContaining('RB-2608-011'), findsNothing);
    expect(find.text('재료비율'), findsNothing);
    expect(find.text('상세/결재'), findsNothing);

    await tester.pumpWidget(const MaterialApp(home: ProjectManagementScreen()));
    await tester.pumpAndSettle();
    expect(find.text('진행단계 조회'), findsWidgets);
    expect(find.textContaining('SO-2608-014'), findsOneWidget);
    expect(find.textContaining('SO-2608-011'), findsNothing);
    expect(find.text('메모·댓글'), findsNothing);
    expect(find.text('납기 변경'), findsNothing);
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

  testWidgets('프로젝트관리는 설계부터 6단계이며 수주번호 검색 후 입력한다', (tester) async {
    await setDesktopSize(tester);
    await tester.pumpWidget(
      const MaterialApp(home: ProjectManagementScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('수주'), findsNothing);
    for (final stage in ['설계', '구매', '생산', '품질', '물류', '마감']) {
      expect(find.text(stage), findsWidgets);
    }
    await tester
        .longPress(find.byKey(const ValueKey('project-stage-SO-2608-014-설계')));
    await tester.pumpAndSettle();
    expect(find.textContaining('담당자: 이설계 책임'), findsOneWidget);
    expect(find.textContaining('완료일:'), findsOneWidget);

    await tester.tap(find.text('품질').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('IQC'), findsWidgets);
    await tester.tap(find.text('검사 결과 입력'));
    await tester.pumpAndSettle();
    expect(find.text('품질 입력 · 수주번호 검색'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('project-order-search-input')),
      'SO-2608-014',
    );
    await tester
        .tap(find.byKey(const ValueKey('continue-project-stage-input')));
    await tester.pumpAndSettle();
    expect(find.text('품질 검사 결과 입력'), findsOneWidget);
    expect(find.text('기본값 0(양품)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('프로젝트 메모 답글 등록 시 담당자 Home To-Do를 생성한다', (tester) async {
    projectTodoItems.value = [];
    addTearDown(() => projectTodoItems.value = []);
    await setDesktopSize(tester);
    await tester.pumpWidget(
      const MaterialApp(home: ProjectManagementScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('메모·댓글'));
    await tester.pumpAndSettle();
    expect(find.text('프로젝트 메모·댓글 이력'), findsOneWidget);
    await tester.tap(find.text('답글').first);
    await tester
        .ensureVisible(find.byKey(const ValueKey('project-memo-input')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('project-memo-input')),
      '장기재고 확인 결과를 오늘 공유해주세요.',
    );
    await tester.tap(find.byKey(const ValueKey('add-project-memo')));
    await tester.pumpAndSettle();
    expect(find.text('장기재고 확인 결과를 오늘 공유해주세요.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('save-project-memos')));
    await tester.pumpAndSettle();
    expect(projectTodoItems.value, hasLength(1));

    await tester.pumpWidget(
      MaterialApp(home: DashboardScreen(onNavigate: (_) {})),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('장기재고 확인 결과를 오늘 공유해주세요.'), findsOneWidget);
    expect(find.textContaining('김구매 팀장'), findsWidgets);
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

    await tester.pumpWidget(scaled(DashboardScreen(onNavigate: (_) {})));
    await tester.pumpAndSettle();
    expect(find.text('팀별·담당자별 업무 부하 현황'), findsOneWidget);
    expect(tester.takeException(), isNull);

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
