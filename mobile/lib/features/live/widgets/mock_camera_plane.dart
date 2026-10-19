import 'package:flutter/material.dart';
import '../../../core/theme/pulse_colors.dart';

/// Full-bleed visual stand-in for the camera when preview isn't available (e.g. web).
class MockCameraPlane extends StatelessWidget {
  const MockCameraPlane({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1B2430),
                Color(0xFF0C1016),
                Color(0xFF151A12),
              ],
            ),
          ),
        ),
        CustomPaint(painter: _GymFloorPainter()),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.1),
              radius: 1.1,
              colors: [
                Colors.transparent,
                PulseColors.surface.withValues(alpha: 0.55),
                PulseColors.surface.withValues(alpha: 0.92),
              ],
              stops: const [0.35, 0.75, 1],
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.72),
          child: Container(
            width: 220,
            height: 10,
            decoration: BoxDecoration(
              color: PulseColors.steel.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: PulseColors.lime.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GymFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = PulseColors.lime.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, size.height * 0.45), Offset(x, size.height), grid);
    }
    for (double y = size.height * 0.45; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
