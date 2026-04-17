import 'package:flutter/material.dart';

// ─── Theme-aware boje (light/dark) ──────────────────────────────
@immutable
class HelpiColors extends ThemeExtension<HelpiColors> {
  const HelpiColors({
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.background,
    required this.border,
    required this.dividerColor,
    required this.chipBg,
    required this.scaffold,
    required this.pastelTeal,
    required this.pastelCoral,
  });

  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color background;
  final Color border;
  final Color dividerColor;
  final Color chipBg;
  final Color scaffold;
  final Color pastelTeal;
  final Color pastelCoral;

  /// Shortcut: `HelpiColors.of(context).surface`
  static HelpiColors of(BuildContext context) =>
      Theme.of(context).extension<HelpiColors>()!;

  static const light = HelpiColors(
    surface: Colors.white,
    textPrimary: Color(0xFF2D2D2D),
    textSecondary: Color(0xFF757575),
    background: Color(0xFFF9F7F4),
    border: Color(0xFFE0E0E0),
    dividerColor: Color(0xFFEEEEEE),
    chipBg: Color(0xFFF0F0F0),
    scaffold: Color(0xFFF9F7F4),
    pastelTeal: Color(0xFFE0F5F5),
    pastelCoral: Color(0xFFFFE8E5),
  );

  static const dark = HelpiColors(
    surface: Color(0xFF1E1E1E),
    textPrimary: Color(0xFFE0E0E0),
    textSecondary: Color(0xFF9E9E9E),
    background: Color(0xFF121212),
    border: Color(0xFF3A3A3A),
    dividerColor: Color(0xFF2C2C2C),
    chipBg: Color(0xFF3A3A3A),
    scaffold: Color(0xFF121212),
    pastelTeal: Color(0xFF1A3A3A),
    pastelCoral: Color(0xFF3A2020),
  );

  @override
  HelpiColors copyWith({
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? background,
    Color? border,
    Color? dividerColor,
    Color? chipBg,
    Color? scaffold,
    Color? pastelTeal,
    Color? pastelCoral,
  }) => HelpiColors(
    surface: surface ?? this.surface,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    background: background ?? this.background,
    border: border ?? this.border,
    dividerColor: dividerColor ?? this.dividerColor,
    chipBg: chipBg ?? this.chipBg,
    scaffold: scaffold ?? this.scaffold,
    pastelTeal: pastelTeal ?? this.pastelTeal,
    pastelCoral: pastelCoral ?? this.pastelCoral,
  );

  @override
  HelpiColors lerp(covariant HelpiColors? other, double t) {
    if (other == null) return this;
    return HelpiColors(
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      border: Color.lerp(border, other.border, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      chipBg: Color.lerp(chipBg, other.chipBg, t)!,
      scaffold: Color.lerp(scaffold, other.scaffold, t)!,
      pastelTeal: Color.lerp(pastelTeal, other.pastelTeal, t)!,
      pastelCoral: Color.lerp(pastelCoral, other.pastelCoral, t)!,
    );
  }
}

/// Helpi Admin tema — identična senior/student dizajn sustavu.
class HelpiTheme {
  HelpiTheme._();

  // ─── Boje ───────────────────────────────────────────────────────
  static const Color primary = Color(0xFFEF5B5B); // coral
  static const Color accent = Color(0xFF009D9D); // teal
  static const Color error = Color(0xFFC62828);
  static const Color background = Color(0xFFF9F7F4); // warm off-white
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color border = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color navUnselected = Color(0xFFB0B0B0);

  // Status boje — unija senior + student statusa
  static const Color statusProcessingText = Color(0xFFF57C00); // amber/orange
  static const Color statusProcessingBg = Color(0xFFFFF3E0);
  static const Color statusActiveText = Color(0xFF4CAF50);
  static const Color statusActiveBg = Color(0xFFE8F5E9);
  static const Color statusCompletedText = Color(0xFF1976D2); // blue
  static const Color statusCompletedBg = Color(0xFFE8F1FB);
  static const Color statusCancelledText = Color(0xFFEF5B5B);
  static const Color statusCancelledBg = Color(0xFFFFEBEE);
  static const Color statusScheduledText = Color(0xFF1976D2);
  static const Color statusScheduledBg = Color(0xFFE3F2FD);

  // Specijalne
  static const Color starYellow = Color(0xFFFFC107);
  static const Color chipBg = Color(0xFFF0F0F0);
  static const Color pastelTeal = Color(0xFFE0F5F5);
  static const Color pastelCoral = Color(0xFFFFE8E5);
  static const Color scaffold = background;

  // ─── Dimenzije ──────────────────────────────────────────────────
  static const double appBarHeight = 56.0;
  static const double buttonHeight = 56.0;
  static const double buttonRadius = 12.0;
  static const double cardRadius = 12.0;
  static const double chipRadius = 100.0;
  static const double statusBadgeRadius = 100.0;
  static const double bottomSheetRadius = 12.0;
  static const double pillRadius = 12.0;
  static const double inputFieldHeight = 48.0;

  // ─── Sidebar (desktop) ──────────────────────────────────────────
  static const double sidebarWidth = 260.0;

  // ─── NavigationRail (tablet) ────────────────────────────────────
  static const double navIndicatorRadius = 24.0;

  // ─── Tema ───────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    extensions: const [HelpiColors.light],
    colorScheme: const ColorScheme.light(
      primary: primary,
      primaryContainer: Color(0xFFFFE8E5),
      secondary: accent,
      secondaryContainer: Color(0xFFD4F0F0),
      error: error,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: appBarHeight,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        minimumSize: const Size(double.infinity, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        side: const BorderSide(color: accent, width: 2),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return textSecondary.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.pressed)) {
          return textSecondary.withValues(alpha: 0.12);
        }
        return Colors.transparent;
      }),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      shadowColor: Colors.black.withAlpha(15),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: const TextStyle(fontSize: 16, color: textSecondary),
      hintStyle: const TextStyle(fontSize: 16, color: textSecondary),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: accent,
      selectionColor: accent.withValues(alpha: 0.22),
      selectionHandleColor: accent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: accent,
      unselectedItemColor: navUnselected,
      selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 14),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: CircleBorder(),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF323232),
      contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
      actionTextColor: accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: const Color(0xE6616161),
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: const TextStyle(fontSize: 13, color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      waitDuration: const Duration(milliseconds: 400),
      preferBelow: false,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: surface,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(navIndicatorRadius)),
      ),
      selectedIconTheme: IconThemeData(color: accent),
      unselectedIconTheme: IconThemeData(color: navUnselected),
      selectedLabelTextStyle: TextStyle(
        color: accent,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(color: navUnselected, fontSize: 14),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      headerBackgroundColor: accent,
      headerForegroundColor: Colors.white,
      headerHeadlineStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headerHelpStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        if (states.contains(WidgetState.disabled)) {
          return textSecondary.withAlpha(100);
        }
        return textPrimary;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return accent;
        return null;
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return accent;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return accent;
        return null;
      }),
      todayBorder: const BorderSide(color: accent),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return textPrimary;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return accent;
        return null;
      }),
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: textSecondary),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: accent),
    ),
  );

  // ─── Dark tema ───────────────────────────────────────────────
  // Dark equivalents
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkDivider = Color(0xFF2C2C2C);
  static const Color darkChipBg = Color(0xFF3A3A3A);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    extensions: const [HelpiColors.dark],
    colorScheme: const ColorScheme.dark(
      primary: primary,
      primaryContainer: Color(0xFF5C2020),
      secondary: accent,
      secondaryContainer: Color(0xFF1A4A4A),
      error: error,
      surface: darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: appBarHeight,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: darkTextPrimary,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: darkTextPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: darkTextPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: darkTextPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: darkTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: darkTextPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: darkTextSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        minimumSize: const Size(double.infinity, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        side: const BorderSide(color: accent, width: 2),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return darkTextSecondary.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.pressed)) {
          return darkTextSecondary.withValues(alpha: 0.12);
        }
        return Colors.transparent;
      }),
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      shadowColor: Colors.black.withAlpha(30),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: const TextStyle(fontSize: 16, color: darkTextSecondary),
      hintStyle: const TextStyle(fontSize: 16, color: darkTextSecondary),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: accent,
      selectionColor: accent.withValues(alpha: 0.28),
      selectionHandleColor: accent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: accent,
      unselectedItemColor: navUnselected,
      selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 14),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: CircleBorder(),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: darkSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF3A3A3A),
      contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
      actionTextColor: accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: darkDivider,
      thickness: 1,
      space: 1,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: const Color(0xE6616161),
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: const TextStyle(fontSize: 13, color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      waitDuration: const Duration(milliseconds: 400),
      preferBelow: false,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: darkSurface,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(navIndicatorRadius)),
      ),
      selectedIconTheme: IconThemeData(color: accent),
      unselectedIconTheme: IconThemeData(color: navUnselected),
      selectedLabelTextStyle: TextStyle(
        color: accent,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(color: navUnselected, fontSize: 14),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: darkSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      headerBackgroundColor: accent,
      headerForegroundColor: Colors.white,
      headerHeadlineStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headerHelpStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        if (states.contains(WidgetState.disabled)) {
          return darkTextSecondary.withAlpha(100);
        }
        return darkTextPrimary;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return accent;
        return null;
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return accent;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return accent;
        return null;
      }),
      todayBorder: const BorderSide(color: accent),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return darkTextPrimary;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return accent;
        return null;
      }),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: darkTextSecondary,
      ),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: accent),
    ),
  );
}
