import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pulse_colors.dart';

class PulseCraftTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: PulseColors.surface,
      colorScheme: const ColorScheme.dark(
        primary: PulseColors.lime,
        secondary: PulseColors.steel,
        surface: PulseColors.primary,
        error: PulseColors.danger,
        onPrimary: PulseColors.surface,
        onSurface: PulseColors.ink,
      ),
    );
    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    final display = GoogleFonts.spaceGroteskTextTheme(base);
    final mono = GoogleFonts.jetBrainsMonoTextTheme(base);
    return display.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: PulseColors.ink,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: PulseColors.ink,
      ),
      bodyMedium: display.bodyMedium?.copyWith(color: PulseColors.mist),
      labelLarge: mono.labelLarge?.copyWith(
        color: PulseColors.lime,
        letterSpacing: 0.6,
      ),
    );
  }
}
