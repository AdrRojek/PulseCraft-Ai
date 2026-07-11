import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class TechnicalGridBackground extends StatelessWidget {
  const TechnicalGridBackground({super.key, this.child, this.spacing = 25});

  final Widget? child;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(spacing: spacing),
      child: child,
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.spacing});
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gridLine.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
