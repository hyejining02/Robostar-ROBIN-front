class OrderProject {
  final String orderNo;
  final String projectName;
  final String category; // 로봇 / 플랫폼
  final String projectType;
  final String customer;
  final double amount; // 백만원
  final String status;
  final int progress; // %
  // 진행 단계 플래그
  final bool stepOrder;
  final bool stepDesign;
  final bool stepPurchase;
  final bool stepProduction;
  final bool stepDelivery;
  final bool stepOperation;
  final DateTime dueDate;
  final DateTime lastUpdated;

  const OrderProject({
    required this.orderNo, // 수주번호
    required this.projectName, // 프로젝트명
    required this.category, // 프로젝트 구분
    required this.projectType, // 프로젝트 종류
    required this.customer, // 고객사
    required this.amount, // 수주금액(만원)
    required this.status, // 프로젝트 상태
    required this.progress, // 전체 진행률
    required this.stepOrder, // 수주
    required this.stepDesign, // 설계
    required this.stepPurchase, //구매
    required this.stepProduction, // 생산
    required this.stepDelivery, // 납품/설치
    required this.stepOperation, // 운전/검수
    required this.dueDate, // 납기일
    required this.lastUpdated, // 최종업데이트
  });
}

class NoticeItem {
  final String title;
  final DateTime date;
  const NoticeItem({required this.title, required this.date});
}

class UpdateItem {
  final String orderNo;
  final String description;
  final DateTime datetime;
  const UpdateItem(
      {required this.orderNo,
      required this.description,
      required this.datetime});
}

// ---- 샘플 데이터 -------------
class SampleData {
  static const int initialProjectCount = 8;
  static String? recentlyRegisteredOrderNo;

  static final List<OrderProject> projects = [
    OrderProject(
      orderNo: 'SO-2405-001',
      projectName: '자동화 라인 구축 프로젝트',
      category: '로봇',
      projectType: '산업용 로봇',
      customer: 'AA사',
      amount: 850,
      status: '진행 중 (Ing)',
      progress: 78,
      stepOrder: true,
      stepDesign: true,
      stepPurchase: true,
      stepProduction: false,
      stepDelivery: false,
      stepOperation: false,
      dueDate: DateTime(2024, 6, 30),
      lastUpdated: DateTime(2024, 5, 28),
    ),
    OrderProject(
      orderNo: 'SO-2405-002',
      projectName: '스마트 팩토리 구축',
      category: '로봇',
      projectType: '협동 로봇',
      customer: 'FA사',
      amount: 2100,
      status: '진행 중 (Ing)',
      progress: 55,
      stepOrder: true,
      stepDesign: true,
      stepPurchase: false,
      stepProduction: false,
      stepDelivery: false,
      stepOperation: false,
      dueDate: DateTime(2024, 8, 10),
      lastUpdated: DateTime(2024, 5, 27),
    ),
    OrderProject(
      orderNo: 'SO-2405-003',
      projectName: '물류 자동화 프로젝트',
      category: '로봇',
      projectType: 'AGV/AMR',
      customer: 'CA사',
      amount: 1200,
      status: '진행 중 (Ing)',
      progress: 92,
      stepOrder: true,
      stepDesign: true,
      stepPurchase: true,
      stepProduction: true,
      stepDelivery: false,
      stepOperation: false,
      dueDate: DateTime(2024, 5, 30),
      lastUpdated: DateTime(2024, 5, 27),
    ),
    OrderProject(
      orderNo: 'SO-2405-004',
      projectName: '서비스 로봇 개발',
      category: '플랫폼',
      projectType: '로봇 솔루션',
      customer: 'DA사',
      amount: 950,
      status: '진행 중 (Ing)',
      progress: 40,
      stepOrder: true,
      stepDesign: false,
      stepPurchase: false,
      stepProduction: false,
      stepDelivery: false,
      stepOperation: false,
      dueDate: DateTime(2024, 7, 20),
      lastUpdated: DateTime(2024, 5, 24),
    ),
    OrderProject(
      orderNo: 'SO-2405-005',
      projectName: '검사 장비 개선',
      category: '로봇',
      projectType: '비전 검사',
      customer: 'EA사',
      amount: 350,
      status: '진행 중 (Ing)',
      progress: 80,
      stepOrder: true,
      stepDesign: true,
      stepPurchase: true,
      stepProduction: false,
      stepDelivery: false,
      stepOperation: false,
      dueDate: DateTime(2024, 6, 28),
      lastUpdated: DateTime(2024, 5, 24),
    ),
    OrderProject(
      orderNo: 'SO-2405-006',
      projectName: '로봇 시스템 공급 건',
      category: '플랫폼',
      projectType: '제어 플랫폼',
      customer: 'BA사',
      amount: 620,
      status: '완료 (Success)',
      progress: 100,
      stepOrder: true,
      stepDesign: true,
      stepPurchase: true,
      stepProduction: true,
      stepDelivery: true,
      stepOperation: true,
      dueDate: DateTime(2024, 5, 20),
      lastUpdated: DateTime(2024, 5, 20),
    ),
    OrderProject(
      orderNo: 'SO-2405-007',
      projectName: 'AGV 공급 건',
      category: '로봇',
      projectType: 'AGV/AMR',
      customer: 'GA사',
      amount: 480,
      status: '진행 중 (Ing)',
      progress: 65,
      stepOrder: true,
      stepDesign: true,
      stepPurchase: false,
      stepProduction: false,
      stepDelivery: false,
      stepOperation: false,
      dueDate: DateTime(2024, 6, 25),
      lastUpdated: DateTime(2024, 5, 21),
    ),
    OrderProject(
      orderNo: 'SO-2405-008',
      projectName: '제어 시스템 업그레이드',
      category: '플랫폼',
      projectType: '제어 플랫폼',
      customer: 'IA사',
      amount: 780,
      status: '중단 (Drop)',
      progress: 15,
      stepOrder: true,
      stepDesign: false,
      stepPurchase: false,
      stepProduction: false,
      stepDelivery: false,
      stepOperation: false,
      dueDate: DateTime(2024, 7, 5),
      lastUpdated: DateTime(2024, 5, 18),
    ),
  ];

  static final List<NoticeItem> notices = [
    NoticeItem(title: 'ERP 연동 작업 안내 (5/28 업데이트)', date: DateTime(2024, 5, 28)),
    NoticeItem(title: '로봇 제어 플랫폼 v2.1 업데이트 안내', date: DateTime(2024, 5, 24)),
    NoticeItem(title: '납기 일정 변경 안내 (SO-2405-004)', date: DateTime(2024, 5, 22)),
    NoticeItem(title: '품질 검사 기준 변경 안내', date: DateTime(2024, 5, 20)),
  ];

  static final List<UpdateItem> updates = [
    UpdateItem(
        orderNo: 'SO-2405-001',
        description: '구매 단계 진행률 업데이트',
        datetime: DateTime(2024, 5, 28, 10, 30)),
    UpdateItem(
        orderNo: 'SO-2405-002',
        description: '생산 준비 시작',
        datetime: DateTime(2024, 5, 27, 16, 20)),
    UpdateItem(
        orderNo: 'SO-2405-003',
        description: '생산 완료',
        datetime: DateTime(2024, 5, 27, 14, 10)),
    UpdateItem(
        orderNo: 'SO-2405-004',
        description: '구매 지연 (부품 입고 대기)',
        datetime: DateTime(2024, 5, 24, 11, 5)),
    UpdateItem(
        orderNo: 'SO-2405-005',
        description: '검사 테스트 완료',
        datetime: DateTime(2024, 5, 24, 9, 45)),
  ];
}
