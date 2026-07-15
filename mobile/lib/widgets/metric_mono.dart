import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class MetricMono extends StatelessWidget {
  const MetricMono({super.key, required this.value, this.unit, this.size = 14});

  final String value;
  final String? unit;
  final double size;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.jetBrainsMono(fontSize: size, color: Colors.white, fontWeight: FontWeight.w600),
        children: [
          TextSpan(text: value),
          if (unit != null)
            TextSpan(text: ' $unit', style: TextStyle(color: AppColors.graphite, fontSize: size * 0.85)),
        ],
      ),
    );
  }
}

// polish pass 3

// polish pass 11

// polish pass 19

// polish pass 27
