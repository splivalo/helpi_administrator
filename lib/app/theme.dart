import 'package:flutter/material.dart';

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

  // ─── Tema ───────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
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
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: surface,
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
}
