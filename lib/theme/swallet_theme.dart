import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SwalletColors {
  SwalletColors._();

  static const Color brandBlue = Color(0xFF2F6BFF);
  static const Color actionCyan = Color(0xFF64D2FF);
  static const Color destructive = Color(0xFFEA3323);

  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFF2F2F2);
  static const Color lightSurfaceLow = Color(0xFFF0F0F0);
  static const Color lightSurfaceHigh = Color(0xFFEAEAEA);
  static const Color lightText = Color(0xFF141414);
  static const Color lightTextMuted = Color(0xFF70757F);
  static const Color lightOutline = Color(0xFFDCDDE2);

  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1B1B1B);
  static const Color darkSurfaceLow = Color(0xFF141414);
  static const Color darkSurfaceHigh = Color(0xFF2A2A2A);
  static const Color darkText = Color(0xFFF2F2F2);
  static const Color darkTextMuted = Color(0xFFA7ACB5);
  static const Color darkOutline = Color(0xFF2F3238);
}

class SwalletPalette {
  const SwalletPalette(this.isDark);

  final bool isDark;

  Color get background =>
      isDark ? SwalletColors.darkBackground : SwalletColors.lightBackground;
  Color get surface =>
      isDark ? SwalletColors.darkSurface : SwalletColors.lightSurface;
  Color get surfaceLow =>
      isDark ? SwalletColors.darkSurfaceLow : SwalletColors.lightSurfaceLow;
  Color get surfaceHigh =>
      isDark ? SwalletColors.darkSurfaceHigh : SwalletColors.lightSurfaceHigh;
  Color get text => isDark ? SwalletColors.darkText : SwalletColors.lightText;
  Color get textMuted =>
      isDark ? SwalletColors.darkTextMuted : SwalletColors.lightTextMuted;
  Color get outline =>
      isDark ? SwalletColors.darkOutline : SwalletColors.lightOutline;
  Color get primary =>
      isDark ? const Color(0xFF4D7CFF) : SwalletColors.brandBlue;
  Color get onPrimary => const Color(0xFFFFFFFF);
  Color get primaryContainer =>
      isDark ? const Color(0xFF1F3D8F) : const Color(0xFFE8EEFF);
  Color get onPrimaryContainer =>
      isDark ? const Color(0xFFDDE7FF) : const Color(0xFF1A3F99);
}

class SwalletText {
  SwalletText._();

  static TextStyle get title => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1,
        letterSpacing: 0,
      );

  static TextStyle get section => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0,
      );

  static TextStyle get body => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.25,
        letterSpacing: 0,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.25,
        letterSpacing: 0,
      );

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.25,
        letterSpacing: 0,
      );

  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1,
        letterSpacing: 0,
      );
}

class SwalletTheme {
  SwalletTheme._();

  static ThemeData theme(bool isDark) {
    final palette = SwalletPalette(isDark);
    final scheme = ColorScheme.fromSeed(
      seedColor: SwalletColors.brandBlue,
      brightness: isDark ? Brightness.dark : Brightness.light,
    ).copyWith(
      surface: palette.surface,
      onSurface: palette.text,
      onSurfaceVariant: palette.textMuted,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primaryContainer,
      onPrimaryContainer: palette.onPrimaryContainer,
      outlineVariant: palette.outline,
      error: SwalletColors.destructive,
    );

    final base = isDark ? ThemeData.dark() : ThemeData.light();
    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: palette.text,
      displayColor: palette.text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      cardColor: palette.surface,
      dividerColor: palette.outline,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: palette.text,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: SwalletText.bodyMedium.copyWith(color: palette.text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceLow,
        hintStyle: SwalletText.body.copyWith(color: palette.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          elevation: 0,
          textStyle: SwalletText.button,
          minimumSize: const Size(56, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          elevation: 0,
          textStyle: SwalletText.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          textStyle: SwalletText.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          textStyle: SwalletText.button,
          side: BorderSide(color: palette.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? palette.surfaceHigh : Colors.black,
        contentTextStyle: SwalletText.body.copyWith(color: Colors.white),
        actionTextColor: SwalletColors.actionCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
