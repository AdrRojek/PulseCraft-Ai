import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SkeletonOverlay extends StatelessWidget {
  const SkeletonOverlay({super.key, this.joints = const []});

  final List<Offset> joints;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SkeletonPainter(joints: joints), size: Size.infinite);
  }
}

class _SkeletonPainter extends CustomPainter {
  _SkeletonPainter({required this.joints});
  final List<Offset> joints;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.acidLime.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < joints.length - 1; i++) {
      canvas.drawLine(joints[i], joints[i + 1], paint);
    }
    for (final j in joints) {
      canvas.drawCircle(j, 4, Paint()..color = AppColors.acidLime);
    }
  }

  @override
  bool shouldRepaint(covariant _SkeletonPainter oldDelegate) => true;
}

// polish pass 6

// polish pass 14

// polish pass 22
