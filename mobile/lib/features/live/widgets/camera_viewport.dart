import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Draws camera frames from the image stream.
///
/// After [CameraController.lockCaptureOrientation], iOS often delivers buffers
/// already in portrait (h > w). Applying [sensorOrientation] again would show
/// the feed sideways — so we only rotate when the buffer is still landscape.
class CameraViewport extends StatelessWidget {
  const CameraViewport({
    super.key,
    required this.image,
    required this.sensorOrientation,
    this.mirror = false,
  });

  final ui.Image image;
  final int sensorOrientation;
  final bool mirror;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF101820),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _FramePainter(
              image: image,
              sensorOrientation: sensorOrientation,
              mirror: mirror,
            ),
          );
        },
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  _FramePainter({
    required this.image,
    required this.sensorOrientation,
    required this.mirror,
  });

  final ui.Image image;
  final int sensorOrientation;
  final bool mirror;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final srcW = image.width.toDouble();
    final srcH = image.height.toDouble();
    final bufferIsPortrait = srcH >= srcW;

    // Portrait buffer → draw upright. Landscape buffer → apply sensor rotation.
    final turns = bufferIsPortrait
        ? 0
        : ((sensorOrientation / 90).round() % 4 + 4) % 4;

    final contentW = turns.isOdd ? srcH : srcW;
    final contentH = turns.isOdd ? srcW : srcH;

    final scale = math.max(size.width / contentW, size.height / contentH);
    final dw = contentW * scale;
    final dh = contentH * scale;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    if (mirror) canvas.scale(-1, 1);
    if (turns != 0) canvas.rotate(turns * (math.pi / 2));

    final drawW = turns.isOdd ? dh : dw;
    final drawH = turns.isOdd ? dw : dh;
    final dest = Rect.fromCenter(center: Offset.zero, width: drawW, height: drawH);
    final src = Rect.fromLTWH(0, 0, srcW, srcH);
    canvas.drawImageRect(
      image,
      src,
      dest,
      Paint()
        ..filterQuality = FilterQuality.low
        ..isAntiAlias = false,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FramePainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.sensorOrientation != sensorOrientation ||
        oldDelegate.mirror != mirror;
  }
}
