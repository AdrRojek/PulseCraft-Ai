import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class PulseButton extends StatefulWidget {
  const PulseButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  State<PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<PulseButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120), lowerBound: 0.96, upperBound: 1);
    _ctrl.value = 1;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _ctrl,
      child: FilledButton.icon(
        onPressed: widget.onPressed == null
            ? null
            : () {
                _ctrl.reverse().then((_) => _ctrl.forward());
                widget.onPressed!();
              },
        icon: Icon(widget.icon ?? Icons.play_arrow_rounded),
        label: Text(widget.label),
        style: FilledButton.styleFrom(backgroundColor: AppColors.acidLime, foregroundColor: AppColors.steel900),
      ),
    );
  }
}
