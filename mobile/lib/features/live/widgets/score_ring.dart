import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ScoreRing extends StatelessWidget {
  const ScoreRing({super.key, required this.score, this.size = 120});

  final double score;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(score: score),
        child: Center(
          child: Text('${(score * 100).round()}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.score});
  final double score;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * score;
    final bg = Paint()..color = AppColors.steel700..style = PaintingStyle.stroke..strokeWidth = 10;
    final fg = Paint()..color = AppColors.acidLime..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(8), 0, 2 * math.pi, false, bg);
    canvas.drawArc(rect.deflate(8), start, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.score != score;
}

// polish pass 5

// polish pass 13
