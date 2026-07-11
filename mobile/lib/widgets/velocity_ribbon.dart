import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class VelocityRibbon extends StatelessWidget {
  const VelocityRibbon({super.key, required this.velocity, this.max = 2.0});

  final double velocity;
  final double max;

  @override
  Widget build(BuildContext context) {
    final t = (velocity / max).clamp(0.0, 1.0);
    return Container(
      height: 6,
      decoration: BoxDecoration(color: AppColors.steel700, borderRadius: BorderRadius.circular(3)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: t,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.acidLime.withValues(alpha: 0.7), AppColors.acidLime]),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}

// polish pass 4
