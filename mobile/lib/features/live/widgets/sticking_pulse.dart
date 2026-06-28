import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StickingPulse extends StatefulWidget {
  const StickingPulse({super.key, required this.active});

  final bool active;

  @override
  State<StickingPulse> createState() => _StickingPulseState();
}

class _StickingPulseState extends State<StickingPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();
    return ScaleTransition(
      scale: Tween(begin: 0.85, end: 1.15).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle, boxShadow: [
          BoxShadow(color: AppColors.danger.withValues(alpha: 0.45), blurRadius: 12),
        ]),
      ),
    );
  }
}
