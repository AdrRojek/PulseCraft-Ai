import 'package:flutter/material.dart';
import 'easeOutCubic.dart';

Widget fadeSlideIn({required Widget child, required Animation<double> anim}) {
  return FadeTransition(
    opacity: anim,
    child: SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
          .animate(CurvedAnimation(parent: anim, curve: easeOutCubic)),
      child: child,
    ),
  );
}
