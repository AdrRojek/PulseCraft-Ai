import 'package:flutter/material.dart';
import '../../../core/theme/pulse_colors.dart';

/// Stick-figure overlay. Joints are normalized 0..1 when [normalized] is true.
///
/// Expected order from LiveCaptureService:
/// 0 nose, 1 L shoulder, 2 R shoulder, 3 L elbow, 4 R elbow,
/// 5 L wrist, 6 R wrist, 7 L hip, 8 R hip, 9 L knee, 10 R knee, 11 L ankle, 12 R ankle
class SkeletonOverlay extends StatelessWidget {
  const SkeletonOverlay({
    super.key,
    this.joints = const [],
    this.normalized = true,
  });

  final List<Offset> joints;
  final bool normalized;

  static const bones = <(int, int)>[
    (0, 1),
    (0, 2),
    (1, 2),
    (1, 3),
    (2, 4),
    (3, 5),
    (4, 6),
    (5, 6), // bar / hands
    (1, 7),
    (2, 8),
    (7, 8),
    (7, 9),
    (8, 10),
    (9, 11),
    (10, 12),
  ];

  @override
  Widget build(BuildContext context) {
    if (joints.isEmpty) return const SizedBox.shrink();
    return CustomPaint(
      painter: _SkeletonPainter(joints: joints, normalized: normalized),
      size: Size.infinite,
    );
  }
}

class _SkeletonPainter extends CustomPainter {
  _SkeletonPainter({required this.joints, required this.normalized});

  final List<Offset> joints;
  final bool normalized;

  Offset _map(Offset j, Size size) {
    if (!normalized) return j;
    if (j == Offset.zero) return Offset(-100, -100);
    return Offset(j.dx * size.width, j.dy * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (joints.length < 2) return;
    final mapped = joints.map((j) => _map(j, size)).toList();

    final bone = Paint()
      ..color = PulseColors.lime.withValues(alpha: 0.92)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final glow = Paint()
      ..color = PulseColors.lime.withValues(alpha: 0.22)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final (a, b) in SkeletonOverlay.bones) {
      if (a >= mapped.length || b >= mapped.length) continue;
      if (mapped[a].dx < 0 || mapped[b].dx < 0) continue;
      canvas.drawLine(mapped[a], mapped[b], glow);
      canvas.drawLine(mapped[a], mapped[b], bone);
    }

    for (final p in mapped) {
      if (p.dx < 0) continue;
      canvas.drawCircle(p, 7, Paint()..color = PulseColors.lime.withValues(alpha: 0.25));
      canvas.drawCircle(p, 3.4, Paint()..color = PulseColors.ink);
      canvas.drawCircle(p, 2.2, Paint()..color = PulseColors.lime);
    }
  }

  @override
  bool shouldRepaint(covariant _SkeletonPainter oldDelegate) =>
      oldDelegate.joints != joints || oldDelegate.normalized != normalized;
}
