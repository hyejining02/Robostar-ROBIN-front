// Source: 사양정보(설계팀 작성) (1).xlsx, 설계팀!A3:C78.
// Read-only source snapshot; unconfirmed engineering compatibility is not inferred.
class RobotReviewOption {
  final int row;
  final String group;
  final String label;
  final String description;
  const RobotReviewOption(this.row, this.group, this.label, this.description);
  String get source => '설계팀!B$row:C$row';
}

const robotReviewOptions = <RobotReviewOption>[
  RobotReviewOption(
      3, "BASE", "BASE 측면 견시창", "RS,RJ,RK ROBOT BASE 측면의 견시창 적용시 사용."),
  RobotReviewOption(
      4, "BASE", "BASE 측면 HOLE", "RC ROBOT BASE 측면의 HOLE 적용시 사용."),
  RobotReviewOption(
      5, "BASE", "BASE 배면 C/B", "ROBOT 배면 카운터 보어 적용시 사용. RC MODEL 적용 불가"),
  RobotReviewOption(6, "BASE", "BASE 배면 C/B 특주",
      "ROBOT 배면 카운터 보어의 위치 및 표준 외 사이즈 변경 적용시 사용. RC MODEL 적용 불가"),
  RobotReviewOption(
      7, "BASE", "BASE 배면 TAP 특주", "ROBOT 배면 TAP의 위치 및 표준 외 사이즈 변경 적용시 사용."),
  RobotReviewOption(8, "BASE", "BASE 배면 PIN 특주",
      "ROBOT 배면 위치결정 PIN의 위치 및 표준 외 사이즈 변경 적용시 사용."),
  RobotReviewOption(9, "BASE", "BASE 배면 C/B 및 PIN 특주",
      "ROBOT 배면 카운터 보어와 위치결정 PIN의 위치 및 표준 외 사이즈 변경 적용시 사용. RC MODEL 적용 불가"),
  RobotReviewOption(10, "BASE", "BASE 배면 TAP 및 PIN 특주",
      "ROBOT 배면 TAP과 위치결정 PIN의 위치 및 표준 외 사이즈 변경 적용시 사용."),
  RobotReviewOption(12, "UPPER COVER", "U/COVER 압출 적용", "U/COVER 표준 사용시 작성."),
  RobotReviewOption(13, "UPPER COVER", "U/COVER AL 당김 적용",
      "주유 매니폴드 사용에 따른 알루미늄 재질 요청 사용시 작성. / 주유 사양 외적으로 요청 가능."),
  RobotReviewOption(14, "UPPER COVER", "U/COVER PC 당김 적용",
      "주유 매니폴드 사용에 따른 PC 재질 요청 사용시 작성. / 주유 사양 외적으로 요청 가능."),
  RobotReviewOption(15, "UPPER COVER", "U/COVER SUS 당김 적용",
      "주유 매니폴드 사용에 따른 SUS 재질 요청 사용시 작성. / 주유 사양 외적으로 요청 가능."),
  RobotReviewOption(
      17, "주유 방식", "주유 매니폴드 NIPPLE 적용", "내부배관 연결 후, 매니폴드 BLOCK에서 NIPPLE 직접 주유"),
  RobotReviewOption(18, "주유 방식", "주유 매니폴드 FITTING 적용",
      "내부배관 연결 후, 매니폴드 BLOCK에서 FITTING을 통한 외부배관 주유"),
  RobotReviewOption(19, "주유 방식", "주유 관로주유 NIPPLE 적용",
      "CARRIER에 관로 가공하여 LM BLOCK 상면가공, BALL SCREW 배관 연결을 통해 NIPPLE 직접 주유\n1RAIL MODEL 적용 불가"),
  RobotReviewOption(20, "주유 방식", "주유 관로주유 FITTING 적용",
      "CARRIER에 관로 가공하여 LM BLOCK 상면가공, BALL SCREW 배관 연결을 통해 FITTING을 통한 외부배관 주유\n1RAIL MODEL 적용 불가"),
  RobotReviewOption(21, "주유 방식", "주유 NIPPLE 적용",
      "1. 직교 ROBOT LM BLOCK 및 BALL SCREW NUT NIPPLE 직접 주유  \n2. LINEAR 내부배관 연결 후 CARRIER 측면 NIPPLE 직접 주유."),
  RobotReviewOption(22, "주유 방식", "주유 FITTING 적용",
      "1. 직교 ROBOT LM BLOCK 및 BALL SCREW NUT 외부 배관연결\n2. LINEAR 내부배관 연결 후 CARRIER 측면 FITTING을 통한 외부배관 주유."),
  RobotReviewOption(
      24, "MOTOR", "MOTOR 외장형", "직교 ROBOT의 SERVO MOTOR 외부 체결 방식."),
  RobotReviewOption(25, "MOTOR", "MOTOR TOP COVER AL",
      "직교 ROBOT의 SERVO MOTOR 커넥터 TYPE 내장 체결 방식 중 추가 COVER 적용."),
  RobotReviewOption(26, "MOTOR", "MOTOR TOP COVER SUS", ""),
  RobotReviewOption(27, "MOTOR", "MOTOR TOP COVER STEEL", ""),
  RobotReviewOption(28, "MOTOR", "MOTOR TOP COVER PC", ""),
  RobotReviewOption(29, "MOTOR", "MOTOR TOP COVER AL(견시창)",
      "직교 ROBOT의 SERVO MOTOR 커넥터 TYPE 내장 체결 방식 중 추가 COVER + PC 견시창 적용."),
  RobotReviewOption(30, "MOTOR", "MOTOR TOP COVER SUS(견시창)", ""),
  RobotReviewOption(31, "MOTOR", "MOTOR TOP COVER STEEL(견시창)", ""),
  RobotReviewOption(32, "MOTOR", "MOTOR 내장 COVER 고무패킹",
      "내장형 MOTOR 적용 시, END / CASE COVER의 전기배선 막음 처리 방법."),
  RobotReviewOption(33, "MOTOR", "MOTOR 내장 COVER 바디하네스",
      "내장형 MOTOR 적용 시, END / CASE COVER의 전기배선 방법"),
  RobotReviewOption(35, "병렬 품목", "FRONT PLATE COVER 견시창(정면/상면/측면)",
      "직교 ROBOT의 PULLEY 조립부 COVER의 PC 견시창 적용."),
  RobotReviewOption(36, "병렬 품목", "FRONT PLATE COVER 견시창(정면/상면_HOLE)",
      "직교 ROBOT의 PULLEY 조립부 COVER의 PC 견시창 적용 및 상면견시창측에 타이밍 BELT의 텐션을 확인하는 HOLE을 적용."),
  RobotReviewOption(37, "병렬 품목", "FRONT PLATE COVER 견시창(정면/측면_HOLE)",
      "직교 ROBOT의 PULLEY 조립부 COVER의 PC 견시창 적용 및 측면견시창측에 타이밍 BELT의 텐션을 확인하는 HOLE을 적용."),
  RobotReviewOption(38, "병렬 품목", "FRONT PLATE COVER 분리형(상/하, 좌/우)",
      "직교 ROBOT의 PULLEY 조립부 COVER의 분리 조립 방향 적용."),
  RobotReviewOption(39, "병렬 품목", "POWER LOCK PULLEY",
      "일반 PULLEY 체결(클램프) 방식이 아닌 POWER LOCK(구매품)을 통한 PULLEY 구동 방식"),
  RobotReviewOption(40, "병렬 품목", "BELT 외부텐션",
      "MOTOR측 PULLEY의 외부조정을 통해 TIMING BELT 장력 조절 방식."),
  RobotReviewOption(42, "COUPLING", "OLDHAM COUPLING",
      "COUPLING 구매품 요청에 따른 적용품.\nBELT ROBOT은 OLDHAM COUPLING 사용 불가"),
  RobotReviewOption(43, "COUPLING", "DISK COUPLING", ""),
  RobotReviewOption(44, "COUPLING", "POWER LOCK COUPLING", ""),
  RobotReviewOption(45, "COUPLING", "JAW COUPLING", ""),
  RobotReviewOption(47, "CARRIER", "CARRIER 체결부 특주",
      "CARRIER 상부 USER 사용 TAP 및 C/B등의 특주 요청 시."),
  RobotReviewOption(49, "KEY", "구동부 KEY 적용",
      "BALL SCREW, MOTOR, 감속기, PULLEY(Belt) 구동부의 KEY 사용 적용시."),
  RobotReviewOption(50, "LM GUIDE", "LM GUIDE 볼리테이너",
      "각 ROBOT MODEL의 표준품 외 사용 요청시 적용.\n\nEX) 볼리테이너 - THK社 SSR 사양\n     등하중 볼리테이너 - THK社 SHS 사양\n     등하중 - THK社 HSR 사양\n     고체윤활 - THK社 KZ SEAL"),
  RobotReviewOption(51, "LM GUIDE", "LM GUIDE 등하중 볼리테이너", ""),
  RobotReviewOption(52, "LM GUIDE", "LM GUIDE 등하중", ""),
  RobotReviewOption(53, "LM GUIDE", "LM GUIDE 고체윤활", ""),
  RobotReviewOption(55, "표준 외 구매품", "SENSOR 보호블럭<GRS>",
      "로보스타 표준 외장센서 BRACKET 외 사용 요청시.\n<GRS> 업체 제작품용으로 사급 진행."),
  RobotReviewOption(56, "표준 외 구매품", "SENSOR 보호블럭",
      "로보스타 표준 외장센서 BRACKET 외 사용 요청시.\n로보스타 제작품용"),
  RobotReviewOption(57, "표준 외 구매품", "SENSOR BRACKET 형상특주",
      "로보스타 표준 외장센서 BRACKET 외 사용 요청시 _ \"ㄱ\"형상용, 중첩용, 방폭용, 근접용 등등…"),
  RobotReviewOption(
      58, "표준 외 구매품", "SENSOR 형번 <메이커>", "EE-SX674/674A SENSOR 외 품목을 사용할 시 작성"),
  RobotReviewOption(59, "표준 외 구매품", "POSITION SENSOR 적용",
      "외장센서의 원점, 리밋+/- 외의 위치 확인 SENSOR 추가 적용 _ 주) 원점과 동일 사양 적용을 표준으로 한다"),
  RobotReviewOption(
      60, "표준 외 구매품", "B/SCREW 형번 <메이커>", "로보스타 표준으로 사용하는 품목 외 사용할 시 작성"),
  RobotReviewOption(
      61, "표준 외 구매품", "커플링 견시창", "U/COVER 및 커플링 하우징 등의 커플링 견시창 적용 시"),
  RobotReviewOption(
      62, "표준 외 구매품", "커플링부 HOLE 적용", "직렬 ROBOT U/COVER 커플링 부분의 HOLE 가공 적용 방법"),
  RobotReviewOption(64, "ROBOT 구동 종류", "토션바 구동",
      "BELT ROBOT에서 구동+가이드 축으로 구성 되어 토션바 연결을 통한 SERVO MOTOR 하나로 구동하는 방식의 ROBOT"),
  RobotReviewOption(
      65, "ROBOT 구동 종류", "Y-BELT 구동", "BELT ROBOT의 벽면 취부 구동 방식 ROBOT"),
  RobotReviewOption(66, "ROBOT 구동 종류", "DUAL BELT 구동",
      "1ROBOT의 CARRIER 2개, SERVO MOTOR 2개로 구성하여 2줄 BELT를 통해 각 CARRIER 개별 구동하는 방식의 BELT ROBOT"),
  RobotReviewOption(67, "ROBOT 구동 종류", "DUAL MOTOR 구동",
      "1ROBOT의 CARRIER 2개, SERVO MOTOR 2개로 구성하여 1줄 BALL SCREW를 통해 각 CARRIER 개별 구동하는 방식의 ROBOT"),
  RobotReviewOption(68, "ROBOT 구동 종류", "CENTERING 구동",
      "1ROBOT의 CARRIER 2개, SERVO MOTOR 1개로 구성하여, 좌나사/ 우나사를 통해 구동하는 방식의 ROBOT"),
  RobotReviewOption(69, "ROBOT 구동 종류", "중첩 구동",
      "1ROBOT의 CARRIER 2개, SERVO MOTOR 2개로 구성하여 2줄 BALL SCREW를 통해 각 CARRIER개별 구동하는 방식의 ROBOT"),
  RobotReviewOption(70, "ROBOT 구동 종류", "BODY MOVING 구동",
      "수직방향의 ROBOT을 CARRIER로 고정 후, BASE가 움직이는 방식"),
  RobotReviewOption(71, "ROBOT 구동 종류", "고정-고정 적용", "BALL SCREW의 고정 방식"),
  RobotReviewOption(72, "ROBOT 구동 종류", "BELT 튐방지 ROLLER 적용",
      "BELT ROBOT의 고속 및 고하중 구동 시, 구동 PULLEY에서 BELT의 이탈 방지를 보조하는 방식"),
  RobotReviewOption(74, "그 외 특기 사항", "LINEAR LM GUIDE MOTOR 및 SCALE 사양 기입 삭제",
      "기존 LINEAR LAYOUT의 사양표 중복 작성에 따른 NOTE란 표기 삭제."),
  RobotReviewOption(75, "그 외 특기 사항", "FREE CARRIER 도면상 지시선으로 표기",
      "FREE CARRIER 사용 적용에 따른 도면에서 NOTE란 미표기로 도면 그림의 지시선으로 구동 CARRIER와 FREE CARRIER 표기"),
  RobotReviewOption(76, "그 외 특기 사항", "레이던트 적용",
      "영업 사원 요청 시, 작성 / 전기도금 기반의 표면처리로, 금속 표면에 얇고 균일한 피막을 형성해 내식성·내열성·전기절연성 등을 높이는 기술"),
  RobotReviewOption(77, "그 외 특기 사항", "BASE 연결형",
      "NOTE 미표기 도면 그림의 치수와 지시선으로 표기 / BASE의 압출 허용길이 초과 및 USER 요청에 따라 1ROBOT의 2개 이상 BASE 연결 구조 방식"),
  RobotReviewOption(78, "그 외 특기 사항", "END COVER 이물 단가공",
      "직교 ROBOT의 Z축 방향 구동에서 누유 발생에 따른 이물받이 기능 추가"),
];

/// Only restrictions explicitly stated in the supplied notes are enforced.
String? reviewOptionRestriction(
    RobotReviewOption option, Map<String, String> fields) {
  final model = (fields['model'] ?? '').toUpperCase().trim();
  final drive = fields['drive'] ?? '';
  final layout = fields['layout'] ?? '';
  if (option.row == 74) return '사양표와 중복되어 NOTE 기입 삭제 대상 (원문)';
  if ([5, 6, 9].contains(option.row) && model.startsWith('RC')) {
    return 'RC MODEL 적용 불가 · ${option.source}';
  }
  if ([19, 20].contains(option.row) && fields['rails'] == '1') {
    return '1RAIL MODEL 적용 불가 · ${option.source}';
  }
  if (option.row == 42 && drive == 'Belt') {
    return 'BELT ROBOT은 OLDHAM COUPLING 사용 불가 · ${option.source}';
  }
  if (option.group == '병렬 품목' && layout != '병렬') {
    return '병렬 배치 선택 시 적용 · ${option.source}';
  }
  if (option.row == 62 && layout != '직렬') {
    return '직렬 ROBOT 항목 · ${option.source}';
  }
  return null;
}

const robotReviewFieldLabels = <String, String>{
  'requester': '영업담당자',
  'designer': '설계담당자',
  'due': '요청 희망일',
  'composition': '구조',
  'drive': '구동 방식',
  'layout': '직렬/병렬 배치',
  'combination': '조합 구조 상세',
  'model': '모델',
  'stroke': 'Stroke(mm)',
  'payload': '가반하중(kg)',
  'speed': '최대속도(mm/s)',
  'center': '무게중심점(mm, 기준축 명기)',
  'cycles': '분당 왕복횟수(회/min)',
  'rails': 'RAIL 수',
  'motor': '모터 방향',
  'sensor': '센서 방향',
  'maker': 'Maker 지정 여부',
  'makerName': '지정 Maker·대상 부품',
  'makerNotes': 'Maker 특이사항',
  'extra': '추가 사양',
  'request': '검토 요청사항',
  'documentNo': '관련 문서번호',
  'marking': '아이마킹 위치·색상',
  'lmCap': 'LM CAP 적용',
  'cable': '센서케이블 사양',
  'cableTreatment': '센서케이블 처리 방법',
  'grease': '그리스 사양·주유 후 포장',
  'plateNut': '판너트 적용·수량',
  'reducer': '감속기 사급/구매',
  'linearSupply': '리니어 모터·마그넷·앰프 사급/구매',
  'sticker': '가감속 스티커 언어',
  'woodPacking': '나무판 3단 적용',
  'combinedShipment': '조합출하',
  'boxPacking': 'BOX 포장',
  'salesOther': '영업 추가 특기사항',
};
