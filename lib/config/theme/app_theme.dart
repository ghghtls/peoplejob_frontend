import 'package:flutter/material.dart';

/// PeopleJob Design System — token definitions and ThemeData
///
/// Color palette
///   Sapphire  : primary brand (#0B5FFF)
///   Obsidian  : neutral scale (#0B1220 → #F8F8FB)
///   Champagne : premium accent (#C8A96A)
///   Semantic  : success / warning / danger / info
///   iOS cat.  : secondary categorical palette (legacy, preserved)
class AppTheme {
  // ─── Sapphire (primary) ───────────────────────────────────────────────────
  static const Color sapphire900 = Color(0xFF001B66);
  static const Color sapphire700 = Color(0xFF0044CC);
  static const Color sapphire500 = Color(0xFF0B5FFF); // brand primary
  static const Color sapphire300 = Color(0xFF5A99FF);
  static const Color sapphire100 = Color(0xFFB8D0FF);
  static const Color sapphire50  = Color(0xFFE8F0FF);

  // ─── Obsidian (neutral) ───────────────────────────────────────────────────
  static const Color ink900 = Color(0xFF0B1220); // headlines
  static const Color ink800 = Color(0xFF161D2E);
  static const Color ink700 = Color(0xFF1C1C1E); // body text
  static const Color ink600 = Color(0xFF2C2C2E);
  static const Color ink500 = Color(0xFF48484A);
  static const Color ink400 = Color(0xFF636366);
  static const Color ink300 = Color(0xFF8E8E93); // secondary text
  static const Color ink200 = Color(0xFFAEAEB2);
  static const Color ink100 = Color(0xFFC7C7CC);
  static const Color ink75  = Color(0xFFD1D1D6);
  static const Color ink50  = Color(0xFFF2F2F7); // page background
  static const Color ink25  = Color(0xFFF8F8FB);

  // ─── Champagne (premium accent) ───────────────────────────────────────────
  static const Color champagne500 = Color(0xFFC8A96A);
  static const Color champagne300 = Color(0xFFDFC897);
  static const Color champagne50  = Color(0xFFFAF6EC);

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const Color success  = Color(0xFF0FA958);
  static const Color warning  = Color(0xFFE89500);
  static const Color danger   = Color(0xFFE5342F);
  static const Color info     = sapphire500;

  // ─── iOS categorical (secondary, preserved) ───────────────────────────────
  static const Color iosBlue   = Color(0xFF007AFF);
  static const Color iosGreen  = Color(0xFF34C759);
  static const Color iosOrange = Color(0xFFFF9500);
  static const Color iosPurple = Color(0xFFAF52DE);
  static const Color iosPink   = Color(0xFFFF2D55);
  static const Color iosTeal   = Color(0xFF5AC8FA);

  // ─── Semantic aliases (for backwards compat) ──────────────────────────────
  static const Color primaryBlue       = sapphire500;
  static const Color backgroundPrimary = Colors.white;
  static const Color backgroundSecondary = ink50;
  static const Color textPrimary       = ink900;
  static const Color textSecondary     = ink700;
  static const Color textTertiary      = ink300;

  // ─── Shadows (layered obsidian) ───────────────────────────────────────────
  static List<BoxShadow> get shadowXs => [
    BoxShadow(color: Color.fromRGBO(11, 18, 32, 0.04), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static List<BoxShadow> get shadowSm => [
    BoxShadow(color: Color.fromRGBO(11, 18, 32, 0.06), blurRadius: 8,  offset: Offset(0, 2)),
    BoxShadow(color: Color.fromRGBO(11, 18, 32, 0.04), blurRadius: 3,  offset: Offset(0, 1)),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(color: Color.fromRGBO(11, 18, 32, 0.08), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color.fromRGBO(11, 18, 32, 0.05), blurRadius: 6,  offset: Offset(0, 2)),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(color: Color.fromRGBO(11, 18, 32, 0.10), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: Color.fromRGBO(11, 18, 32, 0.06), blurRadius: 10, offset: Offset(0, 3)),
  ];

  static List<BoxShadow> get shadowBrand => [
    BoxShadow(color: Color.fromRGBO(11, 95, 255, 0.35), blurRadius: 28, spreadRadius: -6, offset: Offset(0, 10)),
    BoxShadow(color: Color.fromRGBO(11, 95, 255, 0.22), blurRadius: 10, spreadRadius: -2, offset: Offset(0, 4)),
  ];

  // ─── Border radii ─────────────────────────────────────────────────────────
  static const double radiusSm  = 8;
  static const double radiusMd  = 12;
  static const double radiusLg  = 16;
  static const double radiusXl  = 20;
  static const double radius2xl = 28;
  static const double radiusFull = 999;

  // ─── ThemeData ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const fontFamily = 'Pretendard';

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,

      colorScheme: const ColorScheme.light(
        primary: sapphire500,
        primaryContainer: sapphire50,
        secondary: champagne500,
        secondaryContainer: champagne50,
        surface: Colors.white,
        error: danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: ink900,
        onError: Colors.white,
        outline: ink75,
        outlineVariant: ink50,
        shadow: ink900,
        scrim: ink900,
        inverseSurface: ink900,
        onInverseSurface: Colors.white,
      ),

      scaffoldBackgroundColor: ink50,

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: sapphire500,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: ink75,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: ink900,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: sapphire500, size: 22),
        toolbarHeight: 56,
      ),

      // ── Card ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shadowColor: const Color.fromRGBO(11, 18, 32, 0.08),
      ),

      // ── Elevated Button ─────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sapphire500,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),

      // ── Outlined Button ─────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: sapphire500,
          side: const BorderSide(color: sapphire500, width: 1.5),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),

      // ── Text Button ─────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: sapphire500,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
      ),

      // ── Input ───────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ink50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: ink75),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: ink75),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: sapphire500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: danger, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          color: ink200,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
        ),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          color: ink400,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
        ),
        errorStyle: TextStyle(
          fontFamily: fontFamily,
          color: danger,
          fontSize: 12,
          letterSpacing: -0.2,
        ),
      ),

      // ── List Tile ───────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 32,
        iconColor: ink300,
        textColor: ink900,
      ),

      // ── Chip ────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: ink50,
        selectedColor: sapphire50,
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          side: const BorderSide(color: ink75),
        ),
      ),

      // ── Divider ─────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: ink50,
        thickness: 1,
        space: 1,
      ),

      // ── BottomNavBar ─────────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: sapphire500,
        unselectedItemColor: ink300,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Tab Bar ──────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: sapphire500,
        unselectedLabelColor: ink300,
        indicatorColor: sapphire500,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
        ),
      ),

      // ── Dialog ───────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius2xl),
        ),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: ink900,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: ink700,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
        ),
      ),

      // ── SnackBar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink800,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 14,
          letterSpacing: -0.2,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),

      // ── FloatingActionButton ──────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: sapphire500,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── Switch ───────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return ink100;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return sapphire500;
          return ink75;
        }),
      ),

      // ── Checkbox ─────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return sapphire500;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: ink100, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // ── Radio ────────────────────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return sapphire500;
          return ink100;
        }),
      ),

      // ── Progress Indicator ────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: sapphire500,
        linearTrackColor: sapphire50,
      ),

      // ── Typography ────────────────────────────────────────────────────────
      // 7-role scale: Display / H1 / H2 / Title / Body / Caption / Micro
      textTheme: TextTheme(
        // Display (32 / 700) — hero headings
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          height: 1.2,
          color: ink900,
        ),
        // H1 (24 / 700) — section headers
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          height: 1.3,
          color: ink900,
        ),
        // H2 (20 / 700) — sub-section headers
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.3,
          color: ink900,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          height: 1.35,
          color: ink900,
        ),
        // Title (17 / 600) — card titles, nav labels
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          height: 1.4,
          color: ink900,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          height: 1.4,
          color: ink900,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          height: 1.4,
          color: ink900,
        ),
        // Body (15 / 400) — main content
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
          height: 1.6,
          color: ink700,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
          height: 1.6,
          color: ink700,
        ),
        // Caption (13 / 500)
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
          height: 1.5,
          color: ink300,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: ink900,
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
          color: ink400,
        ),
        // Micro (11 / 600) — badges, tags
        labelSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          color: ink300,
        ),
      ),
    );
  }
}
