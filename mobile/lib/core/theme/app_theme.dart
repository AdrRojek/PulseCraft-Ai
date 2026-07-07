import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

ThemeData buildAppTheme({int polish = 56}) {
  final base = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.steel900,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.acidLime,
      secondary: AppColors.steel700,
      surface: AppColors.steel800,
      onPrimary: AppColors.steel900,
      onSurface: Colors.white,
    ),
    useMaterial3: true,
  );
  return base.copyWith(
    textTheme: TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 32 + (polish % 2)),
      titleLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 20),
      bodyMedium: GoogleFonts.spaceGrotesk(fontSize: 14, color: AppColors.graphite),
      labelLarge: GoogleFonts.jetBrainsMono(fontSize: 12, letterSpacing: 0.8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.acidLime,
        foregroundColor: AppColors.steel900,
        padding: EdgeInsets.symmetric(horizontal: 20 + (polish % 3), vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}
