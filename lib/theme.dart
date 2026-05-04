import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg          = Color(0xFF0A0E1A); // deep navy
  static const bgCard      = Color(0xFF112240); // navy card
  static const bgNav       = Color(0xFF0D1B2A); // sidebar navy
  static const text        = Color(0xFFCCD6F6); // lavender white
  static const textMuted   = Color(0xFF8892B0); // slate blue
  static const textLight   = Color(0xFFE6F1FF); // bright white
  static const accent      = Color(0xFF64FFDA); // cyan green
  static const accentLight = Color(0xFF1A3A3A); // dark cyan tint
  static const border      = Color(0xFF1E3A5F); // navy border
  static const highlight   = Color(0xFF112240); // highlight bg
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.bg,
    ),
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.textLight,
    ),
    useMaterial3: true,
  );

  static TextStyle mono({
    double size = 11,
    Color color = AppColors.textMuted,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.firaCode(fontSize: size, color: color, fontWeight: weight, letterSpacing: 0.05 * size);

  static TextStyle sans({
    double size = 15,
    Color color = AppColors.text,
    FontWeight weight = FontWeight.w300,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle display({
    double size = 15,
    Color color = AppColors.textLight,
    FontWeight weight = FontWeight.w700,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing ?? -0.02 * size,
        height: height,
      );
}
