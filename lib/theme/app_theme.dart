import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildRacingTheme() {
  const primaryRed = Color(0xFFE10600);
  const trackGray = Color(0xFF121417);
  const asphalt = Color(0xFF1C1F26);

  final baseTextTheme = GoogleFonts.barlowCondensedTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  );

  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: trackGray,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryRed,
      brightness: Brightness.dark,
      primary: primaryRed,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 6,
      backgroundColor: asphalt,
      foregroundColor: Colors.white,
    ),
    textTheme: baseTextTheme.copyWith(
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    ),
    cardTheme: CardThemeData(
      color: asphalt,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: primaryRed.withValues(alpha: 0.35),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: GoogleFonts.barlowCondensed(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryRed,
      foregroundColor: Colors.white,
      elevation: 10,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: asphalt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.white24, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.white24, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: primaryRed, width: 2),
      ),
      labelStyle: GoogleFonts.barlowCondensed(
        color: Colors.white70,
        letterSpacing: 0.5,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      side: const BorderSide(color: Colors.white70, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryRed;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all<Color>(Colors.white),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: asphalt,
      contentTextStyle: GoogleFonts.barlowCondensed(
        color: Colors.white,
        fontSize: 16,
        letterSpacing: 0.5,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: const DividerThemeData(color: Colors.white12, thickness: 1),
  );
}
