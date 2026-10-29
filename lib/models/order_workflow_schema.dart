import 'access_control.dart';

class WorkField {
  final String id, label;
  final List<String> choices;
  final String? linkModule;
  const WorkField(this.id, this.label,
      {this.choices = const [], this.linkModule});
}

class WorkSection {
  final String id, title, source, notes;
  final List<String> modules;
  final bool platformOnly, robotOnly;
  const WorkSection(this.id, this.title, this.modules, this.source, this.notes,
      {this.platformOnly = false, this.robotOnly = false});
}

const workSections = [
  WorkSection(
      'documents',
      '7. 수주 문서·발주 대조',
      ['document', 'poCompare'],
      '플랫폼 영업 요구사항 실제 12·13장 / 로봇 9/8 회의록 실제 1장 1번',
      '파일은 로컬 참조입니다. 발주서 대조값은 담당자가 입력하며 OCR·ERP 확인값이 아닙니다.'),
  WorkSection(
      'approvals',
      '8. 조건별 결재',
      ['approvalRule', 'approval'],
      '로봇 9/8 회의록 실제 3장 7번',
      '결재선·가격 확정 시점·제한할 단계는 미확정입니다. 아래 규칙은 사용자 입력 시연이며 실제 ERP 결재가 아닙니다.',
      robotOnly: true),
  WorkSection('prices', '9. 구매 단가 이력', ['price'], '로봇 9/8 회의록 실제 1장 2번',
      '사업부 안에서 공통 조회합니다. 단가는 수동 시안이며 ERP 과거 자료의 이관 범위는 미확정입니다.'),
  WorkSection(
      'material',
      '10. 재료비 산출',
      ['costBasis', 'costLine', 'costSnapshot'],
      '재료비 산줄 프로세스 01_재료비예측프로세스!B5:G14 / 로봇 9/8 회의록 실제 1장 1번',
      '기준 BOM + 추가 − 제외 + 대체차액. 사급 제외·0단가를 구분합니다. 추천 가중치·연관 옵션 자동 계산은 미확정입니다.',
      robotOnly: true),
  WorkSection(
      'vrb',
      '11. VRB·견적·실행예산',
      ['vrb', 'quote', 'budget'],
      '플랫폼 영업 요구사항 실제 7~11장 / 플랫폼 9/14 회의록 3·13번',
      '요율과 판관비 계산 기준은 입력한 시안입니다. 예산은 근거 묶음만 저장하며 ERP 예산·승인을 변경하지 않습니다.',
      platformOnly: true),
  WorkSection('quote', '견적 Rev', ['quote'], '플랫폼 영업 요구사항 실제 9·10장',
      '새 Rev는 이전 버전을 보존하며 최신 Rev를 진행 기준으로 사용합니다.',
      robotOnly: true),
  WorkSection(
      'structure',
      '12. 수주·호기·모듈',
      ['hierarchy'],
      '플랫폼 구매 매핑 구매 모듈 구성!A2:J9 / 플랫폼 영업 요구사항 실제 14장',
      '번호 관계는 직접 연결합니다. 작업상태·진척률·납기위험을 분리하며 ERP 계층이나 진척률을 추정하지 않습니다.'),
  WorkSection(
      'purchase',
      '13·14. 구매·입고',
      ['purchase', 'leadTime'],
      '로봇 9/8 회의록 3·4번 / LMBS Sheet1!B15:B16 / 표준납기 사용설명서!A16:C26 / 플랫폼 구매 구매 (2)!L7:Q9',
      '지정·발주·입고·실제 적용 Maker를 구분합니다. 입고 예정은 공급처/변경/납품 예정 중 가장 늦은 날짜를 표시합니다. 실제 적용 여부는 별도 확인합니다.'),
  WorkSection(
      'consignment',
      '15. 사급품',
      ['consignment'],
      '플랫폼 9/14 회의록 실제 2장 4번',
      '원가 포함 여부와 생산 준비를 구분합니다. 입고되지 않은 사급품도 준비 부족에 포함합니다.',
      platformOnly: true),
  WorkSection(
      'inventory',
      '16. 가용·미래 재고',
      ['inventory', 'stockEvent'],
      '로봇 9/8 회의록 실제 4장 9번 / 플랫폼 9/14 회의록 실제 5장 12번',
      '현재고 기준시각부터 미래 수요·입고를 계산합니다. 현재고 반영된 거래는 재차 차감하지 않습니다. Forecast는 별도 시나리오입니다.'),
  WorkSection(
      'production',
      '17. 생산 배포·Serial',
      ['allocation', 'product'],
      '생산 QR 검토안 실제 3~6장 / 로봇 9/8 회의록 실제 4장 8번',
      'QR Key·모바일·라벨 규칙은 미확정입니다. 아래 버튼은 식별된 Serial의 스캔 이벤트 시연이며 실제 QR 발행·카메라 스캔이 아닙니다. 포장완료는 ERP 생산완료·출하완료와 다릅니다.',
      robotOnly: true),
  WorkSection(
      'schedule',
      '18. 생산 공정 일정',
      ['schedule'],
      '플랫폼 영업 요구사항 실제 14·15장 / Operation 회신 생산!D18:F22',
      '실제 현업 장표의 공정명을 입력합니다. 계획과 실적, 담당자, 원천을 구분합니다. 지연 기준은 계획 완료일 초과 여부만 표시합니다.',
      platformOnly: true),
  WorkSection(
      'quality',
      '19. 성적서·불량 조치',
      ['certificate', 'defect'],
      '품질 매핑 품질!H5:H8,J16:K32,J48:K58 / 플랫폼 9/14 회의록 실제 3장 7번',
      '고객/품목별 실제 성적서 양식 확보가 필요합니다. 접수 → 담당자 확인 → 자재/품질 확인 → 완료를 시연하며 출하 제한은 물류와 공유합니다.'),
  WorkSection(
      'shipment',
      '20. 출하 준비',
      ['shipment'],
      '플랫폼 영업 요구사항 실제 16·17장 / Operation 회신 물류_출하!A20:A22',
      '국내/해외와 출하 전 필수/사후 문서를 구분합니다. BL을 무조건 출하 전 필수로 강제하지 않습니다. 최종 출하 실적은 ERP 미연동입니다.'),
  WorkSection('setup', '21. Setup', ['setup'], '플랫폼 9/14 회의록 실제 3장 9번',
      '물류 이후 현장 설치·시운전 일정, 인원, 공수, 출장비, 이슈, 부품/발주를 관리합니다. ERP 예산은 미조회이며 임의 변경하지 않습니다.',
      platformOnly: true),
  WorkSection(
      'changes',
      '22. 수주 이후 변경',
      ['change'],
      '로봇 9/8 회의록 실제 4장 10번 / 플랫폼 9/14 회의록 실제 4장 10번',
      '변경 전후·이유·품목·비용·일정 영향·승인 참조를 기록합니다. 품의가 필요한 기준은 미확정입니다. 마감 후에도 이력을 조회합니다.'),
  WorkSection(
      'closing',
      '23. 업무종료·수금·ERP',
      ['closing', 'payment', 'integration'],
      '플랫폼 영업 요구사항 실제 18~20장 / 플랫폼 9/14 회의록 실제 4장 11번·5장 13번',
      '업무종료·출하·인수·Setup·매출·회계·수금을 구분합니다. 수금은 실제 입금 입력 기준이며 세금계산서 발행으로 완료 처리하지 않습니다. 연계 요청은 미전송만 기록합니다.'),
];
List<WorkSection> sectionsFor(RobinBusinessDivision division) => workSections
    .where((s) =>
        (!s.robotOnly || division == RobinBusinessDivision.robot) &&
        (!s.platformOnly || division == RobinBusinessDivision.platformModule))
    .toList();
const moduleTitles = {
  'document': '문서',
  'poCompare': '발주서 대조',
  'approvalRule': '시연 결재 규칙',
  'approval': '시연 결재 이력',
  'price': '구매 단가',
  'costBasis': '유사실적 기준',
  'costLine': '기준 BOM·옵션 차이',
  'costSnapshot': '저장된 산출 버전',
  'vrb': 'VRB 버전',
  'quote': '견적 Rev',
  'budget': '실행예산 근거 묶음',
  'hierarchy': '번호·하위 구성',
  'purchase': 'BOM·구매·입고',
  'leadTime': '표준납기 근거',
  'consignment': '사급품',
  'inventory': '현재고 기준',
  'stockEvent': '예정 투입·입고',
  'allocation': '협력사 배포',
  'product': 'Serial 생산상태',
  'schedule': '공정 일정',
  'certificate': '성적서',
  'defect': '불량·조치',
  'shipment': '출하 체크리스트',
  'setup': 'Setup 일정·이슈',
  'change': '변경 요청',
  'closing': '종료 상태',
  'payment': '계약금·중도금·잔금',
  'integration': 'ERP 연계 요청'
};

List<WorkField> fieldsFor(String m) => switch (m) {
      'document' => const [
          WorkField('title', '문서명 *'),
          WorkField('type', '문서 종류',
              choices: ['발주서 PO', '사양서', '도면', '협력사 견적서', '재료비 근거', '기타']),
          WorkField('revision', '파일 Revision *'),
          WorkField('verified', '도면 검토 상태', choices: ['미확인', '검토중', '검토완'])
        ],
      'poCompare' => const [
          WorkField('title', '비교명'),
          WorkField('poAmount', '발주서 금액(원) *'),
          WorkField('registeredAmount', 'ROBIN 등록 금액(원) *'),
          WorkField('poDate', '발주서 납기 YYYY-MM-DD *'),
          WorkField('registeredDate', 'ROBIN 납기 YYYY-MM-DD *')
        ],
      'approvalRule' => const [
          WorkField('title', '규칙명 *'),
          WorkField('minRate', '최소 재료비율 % *'),
          WorkField('maxRate', '최대 재료비율 % *'),
          WorkField('special', '특주 조건', choices: ['전체', '일반', '특주']),
          WorkField('approvers', '순서별 결재자 (쉼표 구분) *'),
          WorkField('demo', '규칙 구분', choices: ['미확정', '시연 규칙 동의'])
        ],
      'price' => const [
          WorkField('part', '품번 *'),
          WorkField('title', '품명 *'),
          WorkField('maker', 'Maker *'),
          WorkField('supplier', '구매처 *'),
          WorkField('unit', '수량 단위 *'),
          WorkField('currency', '통화', choices: ['KRW', 'USD', 'JPY', 'EUR']),
          WorkField('unitAmount', '단가 *'),
          WorkField('effectiveDate', '적용일 YYYY-MM-DD *'),
          WorkField('source', '단가 근거/원천 *'),
          WorkField('exception', '예외 구분',
              choices: ['없음', '0단가', '단가 미등록', 'Maker 변경', '품번 유지 예외'])
        ],
      'costBasis' => const [
          WorkField('title', '후보명 *'),
          WorkField('reference', 'ERP 수주/제품 참조번호 *'),
          WorkField('model', '모델 *'),
          WorkField('spec', '기준 사양 *'),
          WorkField('basisDate', '실적 기준일 YYYY-MM-DD *'),
          WorkField('difference', '신규 사양과 차이')
        ],
      'costLine' => const [
          WorkField('basisId', '유사실적 기준 *', linkModule: 'costBasis'),
          WorkField('title', '항목명 *'),
          WorkField('part', '품번 *'),
          WorkField('operation', '산출 구분', choices: ['기준', '추가', '제외', '대체']),
          WorkField('quantityQty', '수량 *'),
          WorkField('priceId', '구매 단가 연결(선택)', linkModule: 'price'),
          WorkField('unitAmount', '수동 단가(원) · 미정은 공란'),
          WorkField('previousAmount', '대체 전 금액(원, 대체 시 필수)'),
          WorkField('previousPart', '대체 전 품번(대체 시 필수)'),
          WorkField('consigned', '원가 구분', choices: ['일반 구매', '원가 제외']),
          WorkField('dependency', '연관 옵션·가공비 확인 근거')
        ],
      'vrb' => const [
          WorkField('title', 'VRB 이름 *'),
          WorkField('type', '프로젝트 유형', choices: ['반도체', 'AGV', 'FAS', '기타']),
          WorkField('rateVersion', '적용 요율 버전·근거 *'),
          WorkField('proposalAmount', '제안가(원) *'),
          WorkField('materialAmount', '재료비(원) *'),
          WorkField('outsideAmount', '외주 가공비(원) *'),
          WorkField('internalQty', '내부 공수 M/D *'),
          WorkField('internalUnitAmount', '내부 M/D 단가(원) *'),
          WorkField('externalQty', '외주 공수 M/D *'),
          WorkField('externalUnitAmount', '외주 M/D 단가(원) *'),
          WorkField('installationAmount', '설치·시운전비(원) *'),
          WorkField('overheadRate', '판관비율 % *'),
          WorkField('overheadBase', '판관비 계산 기준', choices: ['제안가', '직접원가'])
        ],
      'quote' => const [
          WorkField('title', '견적명 *'),
          WorkField('proposalAmount', '견적 금액(원) *'),
          WorkField('spec', '견적 사양 *'),
          WorkField('costId', '연결 산출 버전', linkModule: 'costSnapshot|vrb')
        ],
      'budget' => const [
          WorkField('title', '예산 근거 이름 *'),
          WorkField('drawingId', '동일 수주 검토완 도면 *',
              linkModule: 'verifiedDrawing'),
          WorkField('costId', '산출 버전/VRB *', linkModule: 'costSnapshot|vrb'),
          WorkField('poId', '동일 수주 PO *', linkModule: 'poDocument')
        ],
      'hierarchy' => const [
          WorkField('title', '구성명 *'),
          WorkField('type', '번호 종류',
              choices: ['프로젝트', '수주', '호기', '모듈', 'Serial']),
          WorkField('reference', '실제 참조번호 *'),
          WorkField('parentId', '상위 구성(선택)', linkModule: 'hierarchy'),
          WorkField('state', '작업 상태', choices: ['미확인', '대기', '진행', '보류', '완료']),
          WorkField('progressRate', '진척률 % · 미확정 공란'),
          WorkField('risk', '납기 위험', choices: ['미확인', '정상', '주의', '위험']),
          WorkField('dueDate', '납기 YYYY-MM-DD')
        ],
      'purchase' => const [
          WorkField('part', 'BOM 품번 *'),
          WorkField('title', '품명 *'),
          WorkField('unit', '호기번호'),
          WorkField('module', '모듈'),
          WorkField('requiredQty', '필요량 *'),
          WorkField('orderedQty', '발주량 *'),
          WorkField('receivedQty', '입고량 *'),
          WorkField('supplier', '공급처 *'),
          WorkField('maker', '지정 Maker *'),
          WorkField('orderMaker', '발주 Maker'),
          WorkField('receivedMaker', '입고 Maker'),
          WorkField('appliedMaker', '실제 적용 Maker(미확인 명시) *'),
          WorkField('actualPart', '실제 적용 품번'),
          WorkField('applicationState', '적용 확인', choices: ['미확인', '조립 확인']),
          WorkField('replacement', '대체품'),
          WorkField('changeReason', 'Maker/품번 변경 사유'),
          WorkField('supplierDate', '공급처 예정일 YYYY-MM-DD'),
          WorkField('changedDate', '변경 예정일 YYYY-MM-DD'),
          WorkField('deliveryDate', '납품 예정일 YYYY-MM-DD')
        ],
      'leadTime' => const [
          WorkField('title', '납기 기준명 *'),
          WorkField('supplier', '구매처 *'),
          WorkField('classification', '품목 분류 *'),
          WorkField('statistic', '통계 선택', choices: ['평균', '중앙', 'P80', '수동']),
          WorkField('sampleQty', '표본 건수 *'),
          WorkField('sourceDays', '선택 통계값(일)'),
          WorkField('manualDays', '수동납기(일, 미사용은 0) *')
        ],
      'consignment' => const [
          WorkField('part', '품번 *'),
          WorkField('title', '품명 *'),
          WorkField('type', '구분', choices: ['고객사 사급', '협력/제작업체 사급', '일반 구매']),
          WorkField('provider', '제공자 *'),
          WorkField('recipient', '수령자 *'),
          WorkField('plannedQty', '예정량 *'),
          WorkField('receivedQty', '입고량 *'),
          WorkField('usedQty', '투입량 *'),
          WorkField('receivedDate', '입고일 YYYY-MM-DD'),
          WorkField('costTreatment', '원가 처리',
              choices: ['확인 필요', '원가 포함', '원가 제외']),
          WorkField('ownership', '소유권·유상/무상 근거'),
          WorkField('assignee', '담당자')
        ],
      'inventory' => const [
          WorkField('part', '품번 *'),
          WorkField('title', '품명 *'),
          WorkField('onHandQty', '기준 현재고 *'),
          WorkField('snapshotDate', '기준일 YYYY-MM-DD *'),
          WorkField('snapshotReference', '재고 원천·기준시각 *'),
          WorkField('assignee', '부족 알림 담당자'),
          WorkField('safetyQty', '경고 기준수량(선택)'),
          WorkField('leadDays', '조달기간(일, 선택)')
        ],
      'stockEvent' => const [
          WorkField('part', '품번 *'),
          WorkField('title', '수요/입고명 *'),
          WorkField('type', '구분', choices: ['확정 투입', '입고 예정', 'Forecast']),
          WorkField('quantityQty', '수량 *'),
          WorkField('eventDate', '예정일 YYYY-MM-DD *'),
          WorkField('reference', '중복 판정용 근거번호 *'),
          WorkField('reflected', '현재고 반영', choices: ['미반영', '현재고 반영됨']),
          WorkField('confirmedReference', 'Forecast 대응 확정수요 번호')
        ],
      'allocation' => const [
          WorkField('title', '배포명 *'),
          WorkField('supplier', '생산 협력사 *'),
          WorkField('workCenter', 'Work Center *'),
          WorkField('orderQty', '전체 수주수량 *'),
          WorkField('quantityQty', '배포량 *'),
          WorkField('assignee', '내부 담당자')
        ],
      'product' => const [
          WorkField('title', '제품 모델 *'),
          WorkField('serial', 'Serial *'),
          WorkField('allocationId', '배포 건 *', linkModule: 'allocation'),
          WorkField('assignee', '내부 생산 담당자'),
          WorkField('planDate', '생산예정일 YYYY-MM-DD'),
          WorkField('dueDate', '납기 YYYY-MM-DD')
        ],
      'schedule' => const [
          WorkField('title', '현업 공정명 *'),
          WorkField('unit', '호기 *'),
          WorkField('module', '모듈 *'),
          WorkField('assignee', '담당자 *'),
          WorkField('origin', '입력 원천',
              choices: ['기존 생산 장표', '생산 수기', '영업·설계 입력']),
          WorkField('planStartDate', '계획 착수일 YYYY-MM-DD *'),
          WorkField('planEndDate', '계획 완료일 YYYY-MM-DD *'),
          WorkField('actualStartDate', '실제 착수일 YYYY-MM-DD'),
          WorkField('actualEndDate', '실제 완료일 YYYY-MM-DD'),
          WorkField('inspectionDate', '검사예정일 YYYY-MM-DD'),
          WorkField('shippingDate', '출하예정일 YYYY-MM-DD'),
          WorkField('issue', '일정 이슈')
        ],
      'certificate' => const [
          WorkField('title', '성적서명 *'),
          WorkField('customer', '고객사 *'),
          WorkField('item', 'ITEM/품번 *'),
          WorkField('template', '양식·버전 *'),
          WorkField('requiredFields', '필수 입력항목·작성값 *'),
          WorkField('result', '검사 판정', choices: ['미확인', '합격', '출하불가'])
        ],
      'defect' => const [
          WorkField('title', '불량 내용 *'),
          WorkField('customer', '고객사(ERP 미조회) *'),
          WorkField('part', '품목/도면번호 *'),
          WorkField('partName', '품목명(ERP 미조회)'),
          WorkField('quantityQty', '불량수량 *'),
          WorkField('category', '불량 중분류 *'),
          WorkField('subcategory', '불량 소분류 *'),
          WorkField('method', '조치방법 *'),
          WorkField('supplier', '구매협력사'),
          WorkField('assignee', '조치 담당자 *'),
          WorkField('dueDate', '조치예정일 YYYY-MM-DD'),
          WorkField('confirmer', '조치 확인 담당자 *'),
          WorkField('state', '처리 상태',
              choices: ['접수', '담당자 확인', '자재 확인', '품질 확인', '재검토', '완료']),
          WorkField('blocksShipment', '출하 제한',
              choices: ['미판정', '출하 제한', '제한 없음']),
          WorkField('actionResult', '조치·자재 반출/입고·품질 확인 내용'),
          WorkField('urgent', '긴급', choices: ['일반', '긴급'])
        ],
      'shipment' => const [
          WorkField('title', '준비 항목 *'),
          WorkField('destination', '납품 구분', choices: ['국내', '해외']),
          WorkField('required', '필수 시점', choices: ['출하 전 필수', '사후 문서', '참고']),
          WorkField('assignee', '담당자 *'),
          WorkField('status', '상태', choices: ['대기', '진행', '완료']),
          WorkField('completedDate', '완료일 YYYY-MM-DD'),
          WorkField('documentReference', '문서/BL 참조번호')
        ],
      'setup' => const [
          WorkField('title', '현장/Setup명 *'),
          WorkField('assignee', '담당자 *'),
          WorkField('planStartDate', '계획 시작일 YYYY-MM-DD *'),
          WorkField('planEndDate', '계획 완료일 YYYY-MM-DD *'),
          WorkField('peopleQty', '투입인원 *'),
          WorkField('manDays', '공수 M/D *'),
          WorkField('travelAmount', '출장비(원) *'),
          WorkField('issue', '이슈·조치사항'),
          WorkField('parts', '추가/변경 부품'),
          WorkField('purchaseReference', '추가 발주·입고 참조'),
          WorkField('changeId', '관련 변경요청', linkModule: 'change'),
          WorkField('state', '상태', choices: ['대기', '진행', '보류', '완료']),
          WorkField('confirmedBy', '내부 완료 확인자'),
          WorkField('completedDate', '완료일 YYYY-MM-DD')
        ],
      'change' => const [
          WorkField('title', '변경명 *'),
          WorkField('type', '유형',
              choices: ['고객 요청', '설계 변경/오류', '구매품 변경', '파손/망실', '기타 현장 이슈']),
          WorkField('target', 'BOM/품목/문서 식별자 *'),
          WorkField('before', '변경 전 *'),
          WorkField('after', '변경 후 *'),
          WorkField('costAmount', '추가 예상비용(원)'),
          WorkField('scheduleImpact', '납기 영향'),
          WorkField('assignee', '처리 담당자 *'),
          WorkField('approvalState', '승인 구분',
              choices: ['확인 필요', '품의 필요', '이력만 기록']),
          WorkField('approvalReference', '외부 품의/승인 참조번호'),
          WorkField('state', '처리 상태', choices: ['접수', '진행', '완료'])
        ],
      'closing' => const [
          WorkField('title', '종료 상태 기준명 *'),
          WorkField('businessState', '업무종료', choices: ['미확인', '진행', '종료']),
          WorkField('shippingState', '출하(ERP 미연동)', choices: ['미확인', '담당자 확인']),
          WorkField('acceptanceState', '고객인수', choices: ['미확인', '인수 확인']),
          WorkField('setupState', 'Setup',
              choices: ['미확인', '해당없음', '진행', '완료 확인']),
          WorkField('salesState', 'ERP 매출마감', choices: ['미조회']),
          WorkField('accountingState', 'ERP 회계마감', choices: ['미조회']),
          WorkField('actualMaterialAmount', '실제 마감 재료비 수동 참조(원)'),
          WorkField('evidence', '종료/실제원가 확인 근거')
        ],
      'payment' => const [
          WorkField('title', '수금 건명 *'),
          WorkField('type', '구분', choices: ['계약금', '중도금', '잔금']),
          WorkField('expectedAmount', '계약상 금액(원) *'),
          WorkField('paidAmount', '이번 실제 입금액(원) *'),
          WorkField('paidDate', '실제 입금일 YYYY-MM-DD'),
          WorkField('evidence', '입금/은행 근거번호 *'),
          WorkField('installmentReference', '약정번호(같은 약정의 분할 입금은 동일 번호) *'),
          WorkField('invoiceReference', '세금계산서 참조(입금과 별개)')
        ],
      _ => const [],
    };
