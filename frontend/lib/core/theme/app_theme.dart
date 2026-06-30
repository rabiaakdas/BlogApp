import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color primary = Color(0xFF8B5CF6);
  static const Color secondary = Color(0xFFEC4899);
  static const Color background = Color(0xFFFAF7FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color softPurple = Color(0xFFF3E8FF);
  static const Color softPink = Color(0xFFFCE7F3);
  static const Color textDark = Color(0xFF111827);
  static const Color textGray = Color(0xFF6B7280);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      error: error,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textDark,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          color: textDark,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: textDark,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        bodyLarge: TextStyle(color: textDark, fontSize: 16, height: 1.45),
        bodyMedium: TextStyle(color: textGray, fontSize: 14, height: 1.4),
        bodySmall: TextStyle(color: textGray, fontSize: 12, height: 1.35),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        foregroundColor: textDark,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
