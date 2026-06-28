import 'package:flutter/material.dart';
import '../../../domain/models/trajectory_point.dart';
import '../../../core/theme/app_colors.dart';

class TrajectoryPainter extends CustomPainter {
  TrajectoryPainter({required this.points});
  final List<TrajectoryPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final p = Offset(points[i].x * size.width, (1 - points[i].y) * size.height);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.acidLime
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant TrajectoryPainter oldDelegate) => true;
}
