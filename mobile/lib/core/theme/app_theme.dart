import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Offline-safe theme — system fonts only (named SF Pro families can fail to resolve).
ThemeData buildAppTheme({int polish = 88}) {
  const display = TextStyle(
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.05,
    letterSpacing: -0.8,
  );
  const body = TextStyle(
    fontWeight: FontWeight.w400,
    color: AppColors.graphite,
    height: 1.35,
  );
  const mono = TextStyle(
    fontFamily: 'Courier',
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.acidLime,
  );

  final base = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.steel900,
    canvasColor: AppColors.steel900,
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
      displayLarge: display.copyWith(fontSize: 40),
      displayMedium: display.copyWith(fontSize: 32),
      headlineMedium: display.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: display.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      bodyMedium: body.copyWith(fontSize: 15),
      bodyLarge: body.copyWith(fontSize: 16, color: Colors.white70),
      labelLarge: mono.copyWith(fontSize: 12),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
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
