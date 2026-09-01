import 'package:flutter/material.dart';

class RobinTheme {
  // -- 색상팔레트 : SmartOrder기준, 로보스타 로고(레드&그레이)
  // -- 요구사항 : 색상은 로고기준, SmartOrder와 통일
  // -- 기획 = 네이비/블루 -> 레드/그레이로 교체 진행

  // 메인레드
  static const Color primary = Color(0xFFAF0030);
  static const Color primaryDark = Color(0xFF8A0026);
  static const Color primaryLight = Color(0xFFC94060);

  // 액센트도 레드계열로 통일
  static const Color accent = Color(0xFFAF0030);
  static const Color accentLight = Color(0xFFFBE9EE);

  // 사이드바(다크그레이, 차콜)
  static const Color sidebarBg = Color(0xFF2B2B2E); // 차콜 그레이
  static const Color sidebarActive = Color(0xFF3D3D42); // 활성 메뉴 배경
  static const Color sidebarBorder = Color(0xFF3D3D42); // 사이드바 구분선

  // 상태색상(신호등Signal / 요구사항 : Green,Yellow,Red)
  static const Color signalGreen = Color(0xFF2E7D32); // 기준 충족
  static const Color signalYellow = Color(0xFFF9A825); // 소폭 미달
  static const Color signalRed = Color(0xFFC62828); // 대폭 미달

  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color pending = Color(0xFF6D5DD3);
  static const Color pendingLight = Color(0xFFF0EEFF);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);

  // 그레이 스케일 (SmartOrder 그레이 계열)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F7F8); // 밝은 그레이 배경
  static const Color textPrimary = Color(0xFF1F1F22);
  static const Color textSecondary = Color(0xFF6B6B70);
  static const Color textMuted = Color(0xFF9E9EA3);
  static const Color border = Color(0xFFE2E2E5);
  static const Color divider = Color(0xFFF0F0F1);

  // -- 타이포그래피 ---
  // -- 폰트 : LG스마트체 --

  static const String fontFamily = 'Malgun Gothic'; // Windows 맑은 고딕

  static TextStyle get headingLg => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get headingSm => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get bodyMd => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySm => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  static TextStyle get labelXs => const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textMuted,
        letterSpacing: 0.2,
      );

  static TextStyle get numericLg => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get numericMd => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  // --- 테마 ---
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          surface: surface,
        ),
        scaffoldBackgroundColor: background,
        fontFamily: fontFamily,
        dividerTheme: const DividerThemeData(color: border, thickness: 1),
        dialogTheme: DialogThemeData(
          backgroundColor: surface,
          surfaceTintColor: Colors.transparent,
          elevation: 18,
          shadowColor: const Color(0x52000000),
          barrierColor: const Color(0x73000000),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: border),
          ),
          titleTextStyle: headingLg.copyWith(fontSize: 18),
          contentTextStyle: bodyMd,
          actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: border),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(),
        ),
        dataTableTheme: const DataTableThemeData(
          headingRowHeight: 38,
          dataRowMinHeight: 38,
          dataRowMaxHeight: 48,
          horizontalMargin: 10,
          columnSpacing: 14,
          dividerThickness: 1,
        ),
        chipTheme: const ChipThemeData(
          padding: EdgeInsets.zero,
          labelPadding: EdgeInsets.symmetric(horizontal: 8),
          side: BorderSide(color: border),
          shape: StadiumBorder(),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            minimumSize: const Size(32, 32),
            padding: const EdgeInsets.all(6),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 32),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 32),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 30),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          ),
        ),
      );

  // --- 상태 배지 ---
  static Color statusBg(String status) {
    if (status.contains('진행')) return const Color(0xFFEFF6FF);
    if (status.contains('완료') || status.contains('Success')) {
      return successLight;
    }
    if (status.contains('중단') || status.contains('Drop')) return errorLight;
    return const Color(0xFFF3F4F6);
  }

  static Color statusFg(String status) {
    if (status.contains('진행')) return accent;
    if (status.contains('완료') || status.contains('Success')) return success;
    if (status.contains('중단') || status.contains('Drop')) return error;
    return textSecondary;
  }
}
