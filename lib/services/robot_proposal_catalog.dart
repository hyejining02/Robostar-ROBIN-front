// Extracted from the supplied classification workbook (Sheet2, rows 2–192)
// and material simulator DEMO_v2. Prices are demo values, never ERP prices.
const robotItemClassificationRows = <Map<String, dynamic>>[
  {
    "row": 2,
    "values": ["ASF", "체결기", "ASF", "체결기", "ASF", "체결기"]
  },
  {
    "row": 3,
    "values": ["HUM", "휴머노이드", "HUM", "휴머노이드", "CLO", "CLOID"]
  },
  {
    "row": 4,
    "values": ["RAC", "수직다관절", "A", "A SERIES", "A", "A SERIES"]
  },
  {
    "row": 5,
    "values": [
      "RAC",
      "수직다관절",
      "RCN2",
      "N2E 수직다관절 CABLE",
      "RCN2",
      "N2E 수직다관절 CABLE"
    ]
  },
  {
    "row": 6,
    "values": ["RAC", "수직다관절", "N2", "N2 CONTROLLER", "N2", "N2 CONTROLLER"]
  },
  {
    "row": 7,
    "values": ["RAC", "수직다관절", "N2K", "N2K CONTROLLER", "N2K", "N2K CONTROLLER"]
  },
  {
    "row": 8,
    "values": ["RAC", "수직다관절", "RAC", "수직 옵션", "RAC", "수직 옵션"]
  },
  {
    "row": 9,
    "values": [
      "RAC",
      "수직다관절",
      "RCNE",
      "N2 수직다관절 CABLE",
      "RCNE",
      "N2 수직다관절 CABLE"
    ]
  },
  {
    "row": 10,
    "values": [
      "RAC",
      "수직다관절",
      "RCNV",
      "N2 수직다관절 Cable",
      "RCNV",
      "N2 수직다관절 Cable"
    ]
  },
  {
    "row": 11,
    "values": ["RAC", "수직다관절", "RO", "ROBOMAN", "RO", "ROBOMAN"]
  },
  {
    "row": 12,
    "values": [
      "RAC",
      "수직다관절",
      "GTP",
      "GRAPHIC TEACH PENDANT",
      "GTP",
      "GRAPHIC TEACH PENDANT"
    ]
  },
  {
    "row": 13,
    "values": ["RAC", "수직다관절", "S2A", "N2중형서보", "S2A", "N2 중형서보"]
  },
  {
    "row": 14,
    "values": ["RAC", "수직다관절", "SN2M", "N2 중형서보", "SN2M", "N2 중형서보"]
  },
  {
    "row": 15,
    "values": ["RAC", "수직다관절", "SN2S", "N2 소형서보", "SN2S", "N2 소형서보"]
  },
  {
    "row": 16,
    "values": [
      "RAC",
      "수직다관절",
      "TPN",
      "TEACH PENDANT 6축 (N2)",
      "TPN",
      "TEACH PENDANT 6축 (N2)"
    ]
  },
  {
    "row": 17,
    "values": [
      "RAC",
      "수직다관절",
      "VA",
      "N2 CONTROLLER OPTION",
      "VA",
      "N2 CONTROLLER OPTION"
    ]
  },
  {
    "row": 18,
    "values": ["RAC", "수직다관절", "SN2E", "N2 소형서보", "SN2E", "N2 소형서보"]
  },
  {
    "row": 19,
    "values": ["RBC", "기구부", "PMS", "정밀 스테이지", "PMS", "정밀 스테이지"]
  },
  {
    "row": 20,
    "values": ["RBC", "기구부", "RB", "RBC 직각", "RG", "RG TYPE"]
  },
  {
    "row": 21,
    "values": ["RBC", "기구부", "RD", "RBCD 직각", "GU", "GUIDE TYPE"]
  },
  {
    "row": 22,
    "values": ["RBC", "기구부", "RB", "RBC 직각", "BE", "BELT TYPE"]
  },
  {
    "row": 23,
    "values": ["RBC", "기구부", "RBC", "WA-UNIT", "RBCWA", "W-UNIT"]
  },
  {
    "row": 24,
    "values": ["RBC", "기구부", "RB", "RBC 직각", "BS", "B/S TYPE"]
  },
  {
    "row": 25,
    "values": ["RBC", "기구부", "RBI", "MOTOR", "RBI", "MOTOR"]
  },
  {
    "row": 26,
    "values": ["RBC", "기구부", "RB", "RBC 직각", "GA", "GANTRY TYPE"]
  },
  {
    "row": 27,
    "values": ["RBC", "기구부", "RBM", "직각 옵션(제품)-1", "RBM", "직각 옵션(제품)-1"]
  },
  {
    "row": 28,
    "values": ["RBC", "기구부", "NC", "NC 직각", "BS", "B/S TYPE"]
  },
  {
    "row": 29,
    "values": ["RBC", "기구부", "RBN", "직각 옵션(제품)", "RBN", "직각 옵션(제품)"]
  },
  {
    "row": 30,
    "values": ["RBC", "기구부", "NS", "NS 직각", "BS", "B/S TYPE"]
  },
  {
    "row": 31,
    "values": ["RBC", "기구부", "RBD", "DRIVER", "RBD", "DRIVER"]
  },
  {
    "row": 32,
    "values": ["RBC", "기구부", "RBG", "직각 옵션(제품 LG전용)", "RBG", "직각 옵션(제품 LG전용)"]
  },
  {
    "row": 33,
    "values": ["RBC", "기구부", "RBO", "직각 옵션(KCTECH 용)", "RBO", "직각 옵션(KCTECH 용)"]
  },
  {
    "row": 34,
    "values": ["RBC", "기구부", "ROG", "조심형 BRACKET", "ROG", "조심형 BRACKET"]
  },
  {
    "row": 35,
    "values": ["RBC", "기구부", "RBP", "직각 옵션", "RBP", "직각 옵션"]
  },
  {
    "row": 36,
    "values": ["RBC", "기구부", "RG", "RG 직각", "RG", "RACK&PINION GEAR TYPE"]
  },
  {
    "row": 37,
    "values": ["RBC", "기구부", "RJ", "RJ 직각", "BS", "B/S TYPE"]
  },
  {
    "row": 38,
    "values": ["RBC", "기구부", "RBS", "ZW-UNIT", "RBS", "ZW-UNIT"]
  },
  {
    "row": 39,
    "values": ["RBC", "기구부", "ROK", "RK 직교 BRACKET", "ROK", "RK 직교 BRACKET"]
  },
  {
    "row": 40,
    "values": ["RBC", "기구부", "RST", "RS TEST", "BS", "B/S TYPE"]
  },
  {
    "row": 41,
    "values": ["RBC", "기구부", "RSE", "RSE_미니액츄에이터", "SL", "SLIDER TYPE"]
  },
  {
    "row": 42,
    "values": ["RBC", "기구부", "REC", "REC 직각", "BS", "B/S TYPE"]
  },
  {
    "row": 43,
    "values": ["RBC", "기구부", "RC", "RC 직각", "BS", "B/S TYPE"]
  },
  {
    "row": 44,
    "values": ["RBC", "기구부", "RS", "RS 직각", "BS", "B/S TYPE"]
  },
  {
    "row": 45,
    "values": ["RBC", "기구부", "REC", "REC 직각", "GU", "GUIDE TYPE"]
  },
  {
    "row": 46,
    "values": ["RBC", "기구부", "RH", "RH 직각", "BS", "B/S TYPE"]
  },
  {
    "row": 47,
    "values": ["RBC", "기구부", "RH", "RH 직각", "GU", "GUIDE TYPE"]
  },
  {
    "row": 48,
    "values": ["RBC", "기구부", "RM", "RM 직각", "RM", "BS TYPE"]
  },
  {
    "row": 49,
    "values": ["RBC", "기구부", "ROR", "REC 직교 BRACKET", "ROR", "REC 직교 BRACKET"]
  },
  {
    "row": 50,
    "values": ["RBC", "기구부", "RMA", "감속기", "RMA", "감속기"]
  },
  {
    "row": 51,
    "values": ["RBC", "기구부", "RV", "CABLEVEYOR", "RV", "CABLEVEYOR"]
  },
  {
    "row": 52,
    "values": ["RBC", "기구부", "RJ", "RJ 직각", "BT", "BELT TYPE"]
  },
  {
    "row": 53,
    "values": ["RBC", "기구부", "RS", "RS 직각", "GU", "GUIDE TYPE"]
  },
  {
    "row": 54,
    "values": ["RBC", "기구부", "ROD", "RBCD 직교 BRACKET", "ROD", "RBCD 직교 BRACKET"]
  },
  {
    "row": 55,
    "values": ["RBC", "기구부", "ROJ", "RJ 직교 BRACKET", "ROJ", "RJ 직교 BRACKET"]
  },
  {
    "row": 56,
    "values": ["RBC", "기구부", "RS", "RS 직각", "BT", "BELT TYPE"]
  },
  {
    "row": 57,
    "values": ["RBC", "기구부", "ROM", "RM 직교 BRACKET", "ROM", "RM 직교 BRACKET"]
  },
  {
    "row": 58,
    "values": ["RBC", "기구부", "RSC", "RSC_미니액츄에이터", "CL", "CYLINDER TYPE"]
  },
  {
    "row": 59,
    "values": ["RBC", "기구부", "ROB", "RBC직교 BRACKET", "ROB", "RBC직교 BRACKET"]
  },
  {
    "row": 60,
    "values": ["RBC", "기구부", "RQ", "RQ 직각(중국판매용)", "BS", "B/S TYPE"]
  },
  {
    "row": 61,
    "values": ["RBC", "기구부", "RE", "모노 캐리어", "BS", "B/S TYPE"]
  },
  {
    "row": 62,
    "values": ["RBC", "기구부", "ROC", "RC 직교 BRACKET", "ROC", "RC 직교 BRACKET"]
  },
  {
    "row": 63,
    "values": ["RBC", "기구부", "ROL", "샤프트 리니어 BRACKET", "ROL", "샤프트 리니어 BRACKET"]
  },
  {
    "row": 64,
    "values": ["RBC", "기구부", "ROS", "RS 직교 BRACKET", "ROS", "RS(H) 직교 BRACKET"]
  },
  {
    "row": 65,
    "values": ["RBC", "기구부", "RJ", "RJ 직각", "GU", "GUIDE TYPE"]
  },
  {
    "row": 66,
    "values": ["RBC", "기구부", "RD", "RBCD 직각", "BE", "BELT TYPE"]
  },
  {
    "row": 67,
    "values": ["RBC", "기구부", "RK", "RK 직각 (수익형 BELT)", "BT", "BELT TYPE"]
  },
  {
    "row": 68,
    "values": ["RBC", "기구부", "RD", "RBCD 직각", "BS", "B/S TYPE"]
  },
  {
    "row": 69,
    "values": ["RBC", "기구부", "RBT", "직각 옵션-1", "RBT", "직각 옵션-1"]
  },
  {
    "row": 70,
    "values": ["RBC", "기구부", "RJ", "RJ 직각", "RA", "RACK PINION TYPE"]
  },
  {
    "row": 71,
    "values": ["RBC", "기구부", "RM", "RM 직각", "GU", "GUIDE TYPE"]
  },
  {
    "row": 72,
    "values": ["RBC", "기구부", "RJW", "WA-UNIT", "RJWA", "W-UNIT"]
  },
  {
    "row": 73,
    "values": ["RBC", "기구부", "ROF", "평판 리니어 BRACKET", "ROF", "평판 리니어 BRACKET"]
  },
  {
    "row": 74,
    "values": ["RBC", "기구부", "RC", "RC 직각", "BT", "BELT TYPE"]
  },
  {
    "row": 75,
    "values": ["RBC", "기구부", "RC", "RC 직각", "GU", "GUIDE TYPE"]
  },
  {
    "row": 76,
    "values": ["RBC", "기구부", "RB", "RBC 직각", "GU", "GUIDE TYPE"]
  },
  {
    "row": 77,
    "values": ["RBC", "기구부", "ROH", "RH 직교 BRACKET", "ROH", "RH 직교 BRACKET"]
  },
  {
    "row": 78,
    "values": ["RBC", "기구부", "RTO", "토션바 UNIT", "RTO", "토션바 UNIT"]
  },
  {
    "row": 79,
    "values": ["RBC", "기구부", "NB", "NB 직각 (BELT)", "BT", "BELT TYPE"]
  },
  {
    "row": 80,
    "values": ["RBC", "기구부", "RB", "RBC 직각", "RA", "RACK&PINION TYPE"]
  },
  {
    "row": 81,
    "values": ["RCA", "SCARA", "RGA", "RV SCARA", "RGA", "RV SCARA"]
  },
  {
    "row": 82,
    "values": ["RCA", "SCARA", "RBSA", "ABS SCARA", "RBSA", "ABS SCARA"]
  },
  {
    "row": 83,
    "values": ["RCA", "SCARA", "S", "S SERIES", "S", "S SERIES"]
  },
  {
    "row": 84,
    "values": ["RCA", "SCARA", "RSA", "ABS SCARA", "RSA", "ABS SCARA"]
  },
  {
    "row": 85,
    "values": ["RCA", "SCARA", "RSI", "INC SCARA", "RSI", "INC SCARA"]
  },
  {
    "row": 86,
    "values": ["RCA", "SCARA", "SR", "GTC SCARA", "SR", "GTC SCARA"]
  },
  {
    "row": 87,
    "values": ["RCA", "SCARA", "RBSI", "INC SCARA", "RBSI", "INC SCARA"]
  },
  {
    "row": 88,
    "values": ["RCA", "SCARA", "RBS", "ZW-UNIT", "RBSZW", "ZW-UNIT"]
  },
  {
    "row": 89,
    "values": ["RCA", "SCARA", "RHA", "고속 SCARA", "RHA", "고속 SCARA"]
  },
  {
    "row": 90,
    "values": ["RCA", "SCARA", "RLD", "LG SCARA", "RLD", "LG SCARA"]
  },
  {
    "row": 91,
    "values": ["RCA", "SCARA", "RSD", "삼성 SCARA", "RSD", "삼성 SCARA"]
  },
  {
    "row": 92,
    "values": ["RCA", "SCARA", "RSO", "SCARA OPTION", "RSO", "SCARA OPTION"]
  },
  {
    "row": 93,
    "values": ["RCA", "SCARA", "RPA", "RV 감속기 SCARA", "RPA", "RV SCARA"]
  },
  {
    "row": 94,
    "values": [
      "RCM",
      "제어부",
      "KETOP",
      "KEBA TEACH PENDANT",
      "KETOP",
      "KEBA TEACH PENDANT"
    ]
  },
  {
    "row": 95,
    "values": ["RCM", "제어부", "Q", "서보모듈_IPM 일체형", "Q", "서보모듈_IPM 일체형"]
  },
  {
    "row": 96,
    "values": ["RCM", "제어부", "N2", "N2 CONTROLLER", "N2", "N2 CONTROLLER"]
  },
  {
    "row": 97,
    "values": ["RCM", "제어부", "RCS", "1축 컨트롤러", "RC80C", "단축 8000SERIES"]
  },
  {
    "row": 98,
    "values": ["RCM", "제어부", "SN2E", "N2 소형서보", "SN2E", "N2 소형서보"]
  },
  {
    "row": 99,
    "values": [
      "RCM",
      "제어부",
      "RCGS",
      "NRGM ROBOT SENSOR CABLE",
      "RCGS",
      "NRGM ROBOT SENSOR CABLE"
    ]
  },
  {
    "row": 100,
    "values": [
      "RCM",
      "제어부",
      "RCX2",
      "2축컨트롤러(2009.10 설계변경)",
      "RCX2",
      "2축컨트롤러(설계변경作)"
    ]
  },
  {
    "row": 101,
    "values": [
      "RCM",
      "제어부",
      "RTM",
      "2/4축 TEACH PENDANT",
      "RTM",
      "2~4축 TEACH PENDANT"
    ]
  },
  {
    "row": 102,
    "values": ["RCM", "제어부", "SN2S", "N2 소형 서보", "SN2S", "N2 소형 서보"]
  },
  {
    "row": 103,
    "values": ["RCM", "제어부", "S2A", "N2중형서보", "S2A", "N2중형서보"]
  },
  {
    "row": 104,
    "values": [
      "RCM",
      "제어부",
      "RCGM",
      "NRGM CONTROLLER",
      "RCGM",
      "NRGM CONTROLLER"
    ]
  },
  {
    "row": 105,
    "values": ["RCM", "제어부", "RCI1", "1축 컨트롤러 CE", "RCI1", "1축 컨트롤러 CE"]
  },
  {
    "row": 106,
    "values": ["RCM", "제어부", "RCK1", "단축CABLE", "RCK1", "단축CABLE"]
  },
  {
    "row": 107,
    "values": ["RCM", "제어부", "RCK3", "3축 CABLE", "RCK3", "3축 CABLE"]
  },
  {
    "row": 108,
    "values": ["RCM", "제어부", "RTC", "16축 로봇 모션 제어기", "RTC", "16축 로봇 모션 제어기"]
  },
  {
    "row": 109,
    "values": ["RCM", "제어부", "RCK4", "4축 CABLE", "RCK4", "4축 CABLE"]
  },
  {
    "row": 110,
    "values": ["RCM", "제어부", "RCM2", "2축컨트롤러", "RCM2", "2축컨트롤러"]
  },
  {
    "row": 111,
    "values": ["RCM", "제어부", "RCM4", "3/4축 컨트롤러", "RCM4", "3/4축컨트롤러"]
  },
  {
    "row": 112,
    "values": ["RCM", "제어부", "RCM6", "6축 컨트롤러", "RCM6", "6축 컨트롤러"]
  },
  {
    "row": 113,
    "values": ["RCM", "제어부", "RCN2", "N2E CABLE", "RCN2", "N2 CABLE 2축 범용"]
  },
  {
    "row": 114,
    "values": ["RCM", "제어부", "RCO", "제어부 OPTION", "RCO", "제어부 OPTION"]
  },
  {
    "row": 115,
    "values": [
      "RCM",
      "제어부",
      "RCQ",
      "N1(서보모듈 제외) 4축 CASE",
      "RCQ",
      "N1(서보모듈 제외) 4축 CASE"
    ]
  },
  {
    "row": 116,
    "values": ["RCM", "제어부", "RCS", "1축 컨트롤러", "RC60C", "단축 6000SERIES"]
  },
  {
    "row": 117,
    "values": ["RCM", "제어부", "RCS", "1축 컨트롤러", "RC70C", "단축 7000SERIES"]
  },
  {
    "row": 118,
    "values": ["RCM", "제어부", "RCS", "1축 컨트롤러", "RC70D", "단축 7000 리니어 드라이버"]
  },
  {
    "row": 119,
    "values": ["RCM", "제어부", "RGM4", "3/4축 컨트롤러", "RGM4", "4축 모션 컨트롤러"]
  },
  {
    "row": 120,
    "values": ["RCM", "제어부", "RIOCN", "I/O CONNECTOR", "RIOCN", "I/O CONNECTOR"]
  },
  {
    "row": 121,
    "values": ["RCM", "제어부", "I", "서보모듈_IPM 분리형", "I", "서보모듈_IPM 분리형"]
  },
  {
    "row": 122,
    "values": [
      "RCM",
      "제어부",
      "TPN",
      "TEACH PENDANT 6축 (N2)",
      "TPN",
      "TEACH PENDANT 6축 (N2)"
    ]
  },
  {
    "row": 123,
    "values": ["RCM", "제어부", "RCNV", "N2 CABLE", "RCNV", "N2 CABLE"]
  },
  {
    "row": 124,
    "values": ["RCM", "제어부", "RCN2", "N2E CABLE", "RCN2", "N2E CABLE"]
  },
  {
    "row": 125,
    "values": ["RCM", "제어부", "RCK2", "2축 CABLE", "RCK2", "2축 CABLE"]
  },
  {
    "row": 126,
    "values": ["RCM", "제어부", "RGM5", "16축 로봇 모션 제어기", "RGM5", "16축 로봇 모션 제어기"]
  },
  {
    "row": 127,
    "values": [
      "RCM",
      "제어부",
      "RCX4",
      "3/4축 컨트롤러(2009.10 설계변경)",
      "RCX4",
      "3/4축컨트롤러(설계변경作)"
    ]
  },
  {
    "row": 128,
    "values": ["RCM", "제어부", "REUIO", "확장 I/O CABLE", "REUIO", "확장 I/O CABLE"]
  },
  {
    "row": 129,
    "values": [
      "RCM",
      "제어부",
      "RCH",
      "N1(서보모듈 제외) 6축 CASE",
      "RCH",
      "N1(서보모듈 제외) 6축 CASE"
    ]
  },
  {
    "row": 130,
    "values": ["RCM", "제어부", "RGMIO", "RGM4 CABLE", "RGMIO", "RGM4 CABLE"]
  },
  {
    "row": 131,
    "values": [
      "RCM",
      "제어부",
      "RCD",
      "N1(서보모듈 제외) 2축 CASE",
      "RCD",
      "N1(서보모듈 제외) 2축 CASE"
    ]
  },
  {
    "row": 132,
    "values": [
      "RCM",
      "제어부",
      "N1BRK",
      "N1 EXTERNAL BRAKE UNIT",
      "N1BRK",
      "N1 EXTERNAL BRAKE UNIT"
    ]
  },
  {
    "row": 133,
    "values": [
      "RCM",
      "제어부",
      "N1SAFE",
      "N1 SAFETY MODULE",
      "N1SAFE",
      "N1 SAFETY MODULE"
    ]
  },
  {
    "row": 134,
    "values": [
      "RCM",
      "제어부",
      "RGMSE",
      "RGM4 SENSOR CABLE",
      "RGMSE",
      "RGM4 SENSOR CABLE"
    ]
  },
  {
    "row": 135,
    "values": ["RCM", "제어부", "RAK", "로봇 CABLE", "RAK", "로봇 CABLE"]
  },
  {
    "row": 136,
    "values": ["RCM", "제어부", "RSK", "사급모터 CABLE", "RSK", "사급모터 CABLE"]
  },
  {
    "row": 137,
    "values": [
      "RCM",
      "제어부",
      "RT6",
      "6축 TEACH PENDANT(TR)",
      "RT6",
      "6축 TEACH PENDANT"
    ]
  },
  {
    "row": 138,
    "values": ["RCM", "제어부", "RTCIO", "I/O 단자대 CABLE", "RTCIO", "I/O 단자대 CABLE"]
  },
  {
    "row": 139,
    "values": [
      "RCM",
      "제어부",
      "RTH",
      "6축 TEACH PENDANT",
      "RTH",
      "6축 TEACH PENDANT"
    ]
  },
  {
    "row": 140,
    "values": ["RCM", "제어부", "RTMIO", "I/O 단자대", "RTMIO", "I/O 단자대"]
  },
  {
    "row": 141,
    "values": [
      "RCM",
      "제어부",
      "RTS",
      "단축 TEACH PENDANT",
      "RTS",
      "단축 TEACH PENDANT"
    ]
  },
  {
    "row": 142,
    "values": ["RCM", "제어부", "RUSIO", "I/O CABLE", "RUSIO", "I/O CABLE"]
  },
  {
    "row": 143,
    "values": [
      "RCM",
      "제어부",
      "N1TRA",
      "TRACKING CABLE",
      "N1TRA",
      "TRACKING CABLE"
    ]
  },
  {
    "row": 144,
    "values": [
      "RCM",
      "제어부",
      "RCA4",
      "2/4축 ABSOLUTE CE",
      "RCA4",
      "2~4축ABSOLUTE CE"
    ]
  },
  {
    "row": 145,
    "values": ["RCM", "제어부", "RCGK", "NRGM 전장용 CABLE", "RCGK", "NRGM 전장용 CABLE"]
  },
  {
    "row": 146,
    "values": [
      "RCM",
      "제어부",
      "RCGD",
      "NRGM DRIVER I/O CABLE",
      "RCGD",
      "NRGM DRIVER I/O CABLE"
    ]
  },
  {
    "row": 147,
    "values": [
      "RCM",
      "제어부",
      "RCI4",
      "2~4축 INCREMENTAL CE",
      "RCI4",
      "2/4축 INCREMENTAL CE"
    ]
  },
  {
    "row": 148,
    "values": [
      "RCM",
      "제어부",
      "VA",
      "N2 CONTROLLER OPTION",
      "VA",
      "N2 CONTROLLER OPTION"
    ]
  },
  {
    "row": 149,
    "values": ["RCM", "제어부", "SN2M", "N2 중형서보", "SN2M", "N2 중형서보"]
  },
  {
    "row": 150,
    "values": ["RCM", "제어부", "N2K", "N2K CONTROLLER", "N2K", "N2K CONTROLLER"]
  },
  {
    "row": 151,
    "values": ["RCM", "제어부", "CX7", "CX7 컨트롤러", "CX7", "CX7 컨트롤러"]
  },
  {
    "row": 152,
    "values": ["RCM", "제어부", "RCNE", "N2 CABLE", "RCNE", "N2 CABLE"]
  },
  {
    "row": 153,
    "values": ["RCM", "제어부", "GS", "GTC SCARA", "GS", "GTC SCARA"]
  },
  {
    "row": 154,
    "values": [
      "RCM",
      "제어부",
      "GTP",
      "GRAPHIC TEACH PENDANT",
      "GTP",
      "GRAPHIC TEACH PENDANT"
    ]
  },
  {
    "row": 155,
    "values": [
      "RCM",
      "제어부",
      "RCGA",
      "NRGM SAFETY MODULE",
      "RCGA",
      "NRGM SAFETY MODULE"
    ]
  },
  {
    "row": 156,
    "values": [
      "RCM",
      "제어부",
      "RCGC",
      "NRGM SAFETY 통합 CABLE",
      "RCGC",
      "NRGM SAFETY 통합 CABLE"
    ]
  },
  {
    "row": 157,
    "values": [
      "RDT",
      "DESKTOP",
      "RDS",
      "X축 SINGLE DESK TOP",
      "RDS",
      "SINGLE DESK TOP"
    ]
  },
  {
    "row": 158,
    "values": ["RDT", "DESKTOP", "RDP", "PCB 검사기", "RDP", "PCB 검사기"]
  },
  {
    "row": 159,
    "values": [
      "RDT",
      "DESKTOP",
      "RDT",
      "X축 TWIN DESK TOP",
      "RDT",
      "TWIN DESK TOP"
    ]
  },
  {
    "row": 160,
    "values": [
      "RLN",
      "LINEAR",
      "ROE",
      "평판 리니어 BRACKET",
      "ROE",
      "평판 리니어 BRACKET"
    ]
  },
  {
    "row": 161,
    "values": ["RLN", "LINEAR", "RLE", "샤프트리니어 엔코더케이블", "RLE", "샤프트리니어 엔코더케이블"]
  },
  {
    "row": 162,
    "values": [
      "RLN",
      "LINEAR",
      "ROI",
      "샤프트 리니어 BRACKET",
      "ROI",
      "샤프트 리니어 BRACKET"
    ]
  },
  {
    "row": 163,
    "values": ["RLN", "LINEAR", "RLP", "샤프트리니어 파워케이블", "RLP", "샤프트리니어 파워케이블"]
  },
  {
    "row": 164,
    "values": ["RLN", "LINEAR", "RLS", "샤프트리니어 센서케이블", "RLS", "샤프트리니어 센서케이블"]
  },
  {
    "row": 165,
    "values": ["RLN", "LINEAR", "RL", "샤프트 리니어", "RL", "샤프트 리니어"]
  },
  {
    "row": 166,
    "values": ["RLN", "LINEAR", "RLO", "리니어 OPTION", "RLO", "리니어 OPTION"]
  },
  {
    "row": 167,
    "values": ["RLN", "LINEAR", "RX", "코베리 리니어", "RX", "코베리 리니어"]
  },
  {
    "row": 168,
    "values": ["RLN", "LINEAR", "RFP", "평판리니어 파워케이블", "RFP", "평판리니어 파워케이블"]
  },
  {
    "row": 169,
    "values": ["RLN", "LINEAR", "RF", "평판 리니어", "RF", "평판 리니어"]
  },
  {
    "row": 170,
    "values": ["RLN", "LINEAR", "RFH", "리니어 홀 연장 케이블", "RFH", "리니어 홀 연장 케이블"]
  },
  {
    "row": 171,
    "values": ["RLN", "LINEAR", "RFB", "리니어 브레이크 케이블", "RFB", "리니어 브레이크케이블"]
  },
  {
    "row": 172,
    "values": ["RLN", "LINEAR", "NF", "NF 리니어", "NF", "NF 리니어"]
  },
  {
    "row": 173,
    "values": ["RLN", "LINEAR", "RFD", "평판리니어 드라이버", "RFD", "평판리니어 드라이버"]
  },
  {
    "row": 174,
    "values": ["RLN", "LINEAR", "RFE", "평판리니어 엔코더케이블", "RFE", "평판리니어 엔코더케이블"]
  },
  {
    "row": 175,
    "values": ["RLN", "LINEAR", "RFS", "평판리니어 센서케이블", "RFS", "평판리니어 센서케이블"]
  },
  {
    "row": 176,
    "values": [
      "RLN",
      "LINEAR",
      "RFT",
      "평판리니어 THERMAL 케이블",
      "RFT",
      "평판리니어 THERMAL 케이블"
    ]
  },
  {
    "row": 177,
    "values": [
      "RLN",
      "LINEAR",
      "RLN",
      "리니어 OPTION(제품)",
      "RLN",
      "리니어 OPTION(제품)"
    ]
  },
  {
    "row": 178,
    "values": ["RPI", "수입품", "SX", "상순과기 리니어", "SX", "상순과기 리니어"]
  },
  {
    "row": 179,
    "values": ["RPI", "수입품", "RFS", "상순 리니어", "RFS", "상순 리니어"]
  },
  {
    "row": 180,
    "values": ["RPI", "수입품", "SR", "상순 직교", "SR", "상순 직교"]
  },
  {
    "row": 181,
    "values": ["RPI", "수입품", "MEC", "MECH MIND", "MEC", "MECH MIND"]
  },
  {
    "row": 182,
    "values": ["RPI", "수입품", "HB", "HANBERT 감속기", "HB", "HANBERT 감속기"]
  },
  {
    "row": 183,
    "values": ["RPI", "수입품", "MEC", "MECH MIND", "MEO", "MECH MIND OPTION"]
  },
  {
    "row": 184,
    "values": ["RPI", "수입품", "RPIO", "도입품 옵션", "RPIO", "도입품 옵션"]
  },
  {
    "row": 185,
    "values": ["RPI", "수입품", "RPID", "DENSO ROBOT", "RPID", "DENSO ROBOT"]
  },
  {
    "row": 186,
    "values": ["RPI", "수입품", "RPIK", "YASKAWA ROBOT", "RPIK", "YASKAWA ROBOT"]
  },
  {
    "row": 187,
    "values": ["RSM", "로봇시스템", "N2C", "N2C CONTROLLER", "N2C", "N2C CONTROLLER"]
  },
  {
    "row": 188,
    "values": ["RSM", "로봇시스템", "RSM", "로봇시스템", "RAM", "RPK옵션"]
  },
  {
    "row": 189,
    "values": ["RSM", "로봇시스템", "N2D", "N2D CONTROLLER", "N2D", "N2D CONTROLLER"]
  },
  {
    "row": 190,
    "values": ["RSM", "로봇시스템", "RPK", "RPK SERIES", "RPK", "RPK PICKER"]
  },
  {
    "row": 191,
    "values": ["SEM", "반도체", "SRO", "ROBOT", "ROBOT", "ROBOT"]
  },
  {
    "row": 192,
    "values": ["SEM", "반도체", "SDL", "DOOR LIFTER", "DOOR LIFTER", "DOOR LIFTER"]
  }
];

const robotDemoOptions = <Map<String, dynamic>>[
  {
    "cat": "급유/윤활",
    "name": "외부주유 - 매니폴더",
    "detail": "외부주유 매니폴더 적용",
    "impact": "상",
    "method": "옵션 적용 실적/BOM 참고",
    "form": "옵션 선택 + 관련 품목 BOM Delta",
    "delta": 280000
  },
  {
    "cat": "급유/윤활",
    "name": "상면급유",
    "detail": "상면에서 급유 가능하도록 사양 변경",
    "impact": "상",
    "method": "옵션별 추가금액 적용 회신 존재",
    "form": "정액 또는 BOM Delta 중 확정 필요",
    "delta": 180000
  },
  {
    "cat": "급유/윤활",
    "name": "구리스 THK AFF",
    "detail": "THK社 AFF 구리스 적용",
    "impact": "중",
    "method": "고객사 사양으로 적용",
    "form": "구매품/소모품 사양 선택",
    "delta": 70000
  },
  {
    "cat": "급유/윤활",
    "name": "구리스 Nipple 고리형 Cap",
    "detail": "노란색 Cap + 사용처 표기(LM:L / B/S:B)",
    "impact": "중",
    "method": "고객사 사양으로 적용",
    "form": "옵션/부품 추가",
    "delta": 45000
  },
  {
    "cat": "급유/윤활",
    "name": "니플 재질 변경",
    "detail": "Nipple 등 재질 변경",
    "impact": "상",
    "method": "특주 옵션",
    "form": "대체 부품 차액",
    "delta": 90000
  },
  {
    "cat": "LM/B/S",
    "name": "KZ 씰",
    "detail": "KZ Seal 적용",
    "impact": "상",
    "method": "적용 단가 관리 필요 항목",
    "form": "정액 또는 품목 추가",
    "delta": 160000,
    "only": "B/S"
  },
  {
    "cat": "LM/B/S",
    "name": "LM Maker 변경",
    "detail": "THK/NSK/이소쿠 등",
    "impact": "상",
    "method": "Maker별 단가 차이 반영",
    "form": "기본 Maker + 대체 Maker 차액",
    "delta": 220000,
    "control": "select",
    "choices": [
      ["NSK", 180000],
      ["이소쿠", 220000],
      ["기타", 250000]
    ]
  },
  {
    "cat": "LM/B/S",
    "name": "B/S Maker 변경",
    "detail": "THK/NSK/이소쿠 등",
    "impact": "상",
    "method": "Maker별 단가 차이 반영",
    "form": "기본 Maker + 대체 Maker 차액",
    "delta": 250000,
    "only": "B/S",
    "control": "select",
    "choices": [
      ["NSK", 200000],
      ["이소쿠", 250000],
      ["기타", 280000]
    ]
  },
  {
    "cat": "LM/B/S",
    "name": "B/S 등급 변경",
    "detail": "기본 C7 → C5 또는 C3",
    "impact": "상",
    "method": "등급 변경 시 재료비 편차 큼",
    "form": "등급별 품번/단가 차액",
    "delta": 350000,
    "only": "B/S",
    "control": "select",
    "choices": [
      ["C5", 350000],
      ["C3", 650000]
    ]
  },
  {
    "cat": "LM/B/S",
    "name": "B/S 파이 변경",
    "detail": "볼스크류 직경 증가/변경",
    "impact": "상",
    "method": "파이별 매입/가공 단가, 큰 B/S 적용",
    "form": "파이 선택 + 구매/가공 차액",
    "delta": 300000,
    "only": "B/S",
    "control": "select",
    "choices": [
      ["Ø20", 220000],
      ["Ø25", 380000],
      ["Ø32", 620000]
    ]
  },
  {
    "cat": "LM/B/S",
    "name": "B/S Lead 변경",
    "detail": "리드값 변경",
    "impact": "상",
    "method": "견적 검색조건 및 부품사양 차이",
    "form": "사양 선택에 따른 BOM/단가 변경",
    "delta": 0,
    "only": "B/S",
    "infoOnly": true
  },
  {
    "cat": "LM/B/S",
    "name": "LM Block 수량 증가",
    "detail": "Block 추가 시 전장 및 유동품 변경 가능",
    "impact": "상",
    "method": "수량 추가 + 유동품 변경 반영",
    "form": "수량 × 단가 및 변경 유동품 금액",
    "delta": 310000,
    "control": "qty",
    "unit": "EA"
  },
  {
    "cat": "LM/B/S",
    "name": "LM Block Retainer Type",
    "detail": "Retainer Type 적용",
    "impact": "상",
    "method": "고객사 사양으로 적용",
    "form": "대체 품번 차액",
    "delta": 140000
  },
  {
    "cat": "LM/B/S",
    "name": "LM Rail Bolt Hole Cap",
    "detail": "Bolt Hole Cap 적용",
    "impact": "중",
    "method": "고객사 사양으로 적용",
    "form": "부품 추가",
    "delta": 65000
  },
  {
    "cat": "LM/B/S",
    "name": "Laydent 처리",
    "detail": "LM Rail/B/S 적용 여부",
    "impact": "중",
    "method": "레이던트 처리 단가 항목 존재",
    "form": "후처리 비용 추가",
    "delta": 110000
  },
  {
    "cat": "구동/모터",
    "name": "Coupling Disk Type",
    "detail": "Disk Type Coupling 적용",
    "impact": "상",
    "method": "구매품 종류/메이커 변경",
    "form": "대체품 차액",
    "delta": 210000
  },
  {
    "cat": "구동/모터",
    "name": "Coupling 고정볼트 흑색 산화피막",
    "detail": "흑색 산화 피막 도금볼트 사용",
    "impact": "중",
    "method": "고객사 사양",
    "form": "부품/가공 차액",
    "delta": 50000
  },
  {
    "cat": "구동/모터",
    "name": "Power Lock",
    "detail": "Motor & B/S Shaft Power Lock 적용",
    "impact": "상",
    "method": "표준 대비 재료비 편차 큼",
    "form": "특주 BOM 품목 차액",
    "delta": 260000
  },
  {
    "cat": "구동/모터",
    "name": "외부 Tension",
    "detail": "외부 텐션 적용",
    "impact": "상",
    "method": "표준 대비 재료비 편차 큼",
    "form": "특주 BOM 품목 차액",
    "delta": 190000
  },
  {
    "cat": "구동/모터",
    "name": "Timing Belt 치형 변경",
    "detail": "원형 & 복합치형 사용",
    "impact": "중",
    "method": "고객사 사양",
    "form": "Belt 사양별 대체 단가",
    "delta": 120000,
    "only": "BELT"
  },
  {
    "cat": "구동/모터",
    "name": "Timing Belt Tension BKT",
    "detail": "Tension Bracket 적용",
    "impact": "중",
    "method": "고객사 사양/특주품",
    "form": "부품 추가",
    "delta": 95000,
    "only": "BELT"
  },
  {
    "cat": "구동/모터",
    "name": "Eagle Belt",
    "detail": "이글 벨트 적용 시 풀리/벨트 연동 변경",
    "impact": "상",
    "method": "변경 풀리/벨트 금액 추가 필요",
    "form": "대체 Belt 차액 + 변경 풀리 금액",
    "delta": 340000,
    "only": "BELT"
  },
  {
    "cat": "구동/모터",
    "name": "튐방지 Roller",
    "detail": "적용/미적용에 따라 재료비 편차 큼",
    "impact": "상",
    "method": "적용 여부에 따라 재료비 차이",
    "form": "부품 추가/삭제",
    "delta": 180000,
    "only": "BELT"
  },
  {
    "cat": "구동/모터",
    "name": "모터 Maker 변경",
    "detail": "미쓰비시, 지멘스 등",
    "impact": "중",
    "method": "Maker별 가공 단가 항목 존재",
    "form": "모터/가공 차액",
    "delta": 0,
    "infoOnly": true
  },
  {
    "cat": "구동/모터",
    "name": "표준보다 큰 모터 적용",
    "detail": "표준 기구부에 더 큰 모터 장착",
    "impact": "상",
    "method": "부품/Stroke 기준 추가금액 회신",
    "form": "대체 모터 + 가공/브라켓 영향",
    "delta": 240000
  },
  {
    "cat": "구동/모터",
    "name": "모터 설치방식",
    "detail": "내장형 / 외장형",
    "impact": "상",
    "method": "설치방식별 단가 관리 항목",
    "form": "형태별 옵션 단가/BOM Delta",
    "delta": 170000,
    "control": "select",
    "choices": [
      ["외장형", 170000],
      ["특주 외장형", 260000]
    ]
  },
  {
    "cat": "사급",
    "name": "모터 사급",
    "detail": "고객 사급 여부",
    "impact": "중",
    "method": "사급 사양 존재",
    "form": "포함/제외 플래그",
    "delta": 0,
    "dynamic": "motorSupply"
  },
  {
    "cat": "사급",
    "name": "감속기 사급",
    "detail": "Servo Motor와 감속기 사급",
    "impact": "중",
    "method": "사급 사양 존재",
    "form": "포함/제외 플래그",
    "delta": -420000
  },
  {
    "cat": "Carrier/가공",
    "name": "Free Carrier",
    "detail": "프리 캐리어 적용",
    "impact": "상",
    "method": "옵션 변경 시 유동품 다수 변경",
    "form": "변동 유동품 금액 산출 필요",
    "delta": 430000
  },
  {
    "cat": "Carrier/가공",
    "name": "Carrier 수량 증가",
    "detail": "Carrier 추가",
    "impact": "상",
    "method": "유동품 다수 변경 가능",
    "form": "수량 × 단가 + 변경 유동품",
    "delta": 360000,
    "control": "qty",
    "unit": "EA"
  },
  {
    "cat": "Carrier/가공",
    "name": "Carrier 연장",
    "detail": "고객 요청 또는 Block 추가로 길이 연장",
    "impact": "상",
    "method": "길이 증가에 따른 유동품 변경",
    "form": "길이 기반 추가비 + 가공비",
    "delta": 150000,
    "control": "qty",
    "unit": "100mm"
  },
  {
    "cat": "Carrier/가공",
    "name": "Carrier 통가공",
    "detail": "일체형/통가공품 적용",
    "impact": "상",
    "method": "압출 → 가공, 소재/가공비 변경",
    "form": "특주 가공품 차액",
    "delta": 520000
  },
  {
    "cat": "Carrier/가공",
    "name": "Carrier 상부 Tap & C'B 변경",
    "detail": "상부 Tap/Counter Bore 변경",
    "impact": "상",
    "method": "특주 가공",
    "form": "가공비 추가",
    "delta": 140000
  },
  {
    "cat": "가공/브라켓",
    "name": "조합 Bracket 길이 변경",
    "detail": "길이별 옵션 선택",
    "impact": "상",
    "method": "길이별 옵션 선택 단가 항목",
    "form": "길이 구간별 정액",
    "delta": 160000,
    "control": "select",
    "choices": [
      ["소", 100000],
      ["중", 160000],
      ["대", 260000]
    ]
  },
  {
    "cat": "가공/브라켓",
    "name": "BASE 취부 Tap & C'B",
    "detail": "추가 또는 위치 변경",
    "impact": "상",
    "method": "특주 가공",
    "form": "가공비 추가",
    "delta": 130000
  },
  {
    "cat": "Cover/외관",
    "name": "Upper Cover 재질",
    "detail": "SUS 0.3T / PC / PC(무정전) / 압출 Cover / AL 2T",
    "impact": "상",
    "method": "재질에 따라 재료비 차이 큼",
    "form": "재질 선택별 차액",
    "delta": 0,
    "control": "select",
    "choices": [
      ["PC", 180000],
      ["PC(무정전)", 290000],
      ["SUS 0.3T", 330000],
      ["압출 Cover", 410000],
      ["AL 2T", 520000]
    ]
  },
  {
    "cat": "Cover/외관",
    "name": "Front Cover 견시창",
    "detail": "정면 / 상면 / 측면 / 하면",
    "impact": "상",
    "method": "고객사 사양",
    "form": "가공/부품 추가",
    "delta": 140000,
    "control": "select",
    "choices": [
      ["정면", 140000],
      ["상면", 150000],
      ["측면", 130000],
      ["하면", 160000]
    ]
  },
  {
    "cat": "Cover/외관",
    "name": "벨트 로봇 구동부 견시창",
    "detail": "구동부 견시창 적용",
    "impact": "중",
    "method": "특주 사양",
    "form": "Cover/가공 차액",
    "delta": 120000,
    "only": "BELT"
  },
  {
    "cat": "Cover/외관",
    "name": "Housing 재질 변경",
    "detail": "하우징 재질 변경",
    "impact": "상",
    "method": "특주 사양",
    "form": "재질 차액",
    "delta": 230000
  },
  {
    "cat": "Cover/외관",
    "name": "토션바 Cover",
    "detail": "토션바 커버 적용",
    "impact": "상",
    "method": "특주 사양",
    "form": "부품/가공 추가",
    "delta": 210000
  },
  {
    "cat": "Cover/외관",
    "name": "리니어 이물받이 Cover",
    "detail": "이물받이 커버 적용",
    "impact": "상",
    "method": "특주 사양",
    "form": "부품/가공 추가",
    "delta": 190000
  },
  {
    "cat": "Cover/외관",
    "name": "전체 외관 흑색 처리",
    "detail": "전체 외관 Black 처리",
    "impact": "상",
    "method": "처리 단가 관리 필요 항목",
    "form": "표면처리비 추가",
    "delta": 380000
  },
  {
    "cat": "센서/전장",
    "name": "Sensor 수량 증가",
    "detail": "센서 및 Bracket/Dog 동반 증가",
    "impact": "상",
    "method": "센서+브라켓+도그 금액 합산",
    "form": "수량 × 단가 + 변경 유동품",
    "delta": 140000,
    "control": "qty",
    "unit": "EA"
  },
  {
    "cat": "센서/전장",
    "name": "Sensor 보호 Block",
    "detail": "센서 보호 블럭 적용",
    "impact": "상",
    "method": "특주 사양",
    "form": "부품 단가",
    "delta": 95000
  },
  {
    "cat": "센서/전장",
    "name": "Sensor Maker 변경",
    "detail": "센서 Maker 변경",
    "impact": "상",
    "method": "센서+브라켓+도그 합산 필요",
    "form": "Sensor 차액 + Bracket 추가",
    "delta": 160000
  },
  {
    "cat": "센서/전장",
    "name": "Sensor Dog 특주",
    "detail": "센서 Dog 특주",
    "impact": "상",
    "method": "특주 사양",
    "form": "부품 단가",
    "delta": 110000
  },
  {
    "cat": "센서/전장",
    "name": "Body Harness",
    "detail": "바디 하네스 적용",
    "impact": "중",
    "method": "적용 단가 관리 필요 항목",
    "form": "정액 또는 부품 추가",
    "delta": 170000
  },
  {
    "cat": "Linear",
    "name": "Magnet Maker",
    "detail": "Mitsubishi 정품 Magnet / 국산",
    "impact": "상",
    "method": "Maker에 따라 재료비 편차 큼",
    "form": "Maker 선택별 차액",
    "delta": 0,
    "control": "select",
    "choices": [
      ["Mitsubishi 정품", 520000],
      ["국산", 180000]
    ]
  },
  {
    "cat": "Linear",
    "name": "Scale Type",
    "detail": "Absolute / Incremental",
    "impact": "상",
    "method": "Scale Type/메이커별 단가 필요",
    "form": "Type 선택 및 메이커 단가 필요",
    "delta": 0,
    "control": "select",
    "choices": [
      ["Absolute", 480000],
      ["Incremental", 240000]
    ]
  }
];

const robotDemoMaster = <String, Map<String, int>>{
  "model": {"RS": 0, "RJ": 280000, "RC": 520000},
  "base": {
    "140": 3550000,
    "210": 4650000,
    "045N": 1850000,
    "066N": 2150000,
    "075N": 2450000,
    "095": 2850000
  },
  "axis": {"X": 0, "Y": 0, "Z": 0},
  "type": {"BELT": 430000, "B/S": 720000},
  "stroke": {
    "100ST": 100000,
    "200ST": 180000,
    "300ST": 260000,
    "400ST": 340000,
    "500ST": 420000,
    "600ST": 500000,
    "700ST": 590000,
    "800ST": 680000,
    "900ST": 770000,
    "1000ST": 860000
  },
  "drive": {"직렬": 0, "병렬": 390000},
  "lead": {
    "1505": 260000,
    "1510": 190000,
    "1520": 170000,
    "2010": 330000,
    "2020": 270000
  },
  "motorMaker": {
    "MITSUBISHI J5": 0,
    "PANA MSMF": -50000,
    "LS MECAPION": -90000
  },
  "motorCap": {
    "100W": 410000,
    "100W BRK": 490000,
    "200W": 470000,
    "200W BRK": 560000,
    "400W": 610000,
    "400W BRK": 710000,
    "750W": 890000,
    "750W BRK": 1030000
  }
};

const robotDemoPresets = <String, dynamic>{
  "LGD": [
    ["Coupling Disk Type"],
    ["외부 Tension"],
    ["Power Lock"],
    ["Front Cover 견시창", "정면"],
    ["Upper Cover 재질", "PC(무정전)"],
    ["외부주유 - 매니폴더"],
    ["모터 설치방식", "외장형"]
  ],
  "LGES": [
    ["Coupling Disk Type"],
    ["외부 Tension"],
    ["Power Lock"],
    ["Front Cover 견시창", "정면"],
    ["Upper Cover 재질", "PC"],
    ["외부주유 - 매니폴더"],
    ["모터 설치방식", "외장형"]
  ],
  "현대모비스": [
    ["Coupling Disk Type"],
    ["외부 Tension"],
    ["Power Lock"],
    ["Front Cover 견시창", "정면"],
    ["Upper Cover 재질", "압출 Cover"],
    ["외부주유 - 매니폴더"],
    ["모터 설치방식", "외장형"]
  ],
  "SKON": [
    ["Coupling Disk Type"],
    ["외부 Tension"],
    ["Power Lock"],
    ["Front Cover 견시창", "정면"],
    ["Upper Cover 재질", "PC"],
    ["외부주유 - 매니폴더"],
    ["모터 설치방식", "외장형"]
  ]
};
