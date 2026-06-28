import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/technical_grid_background.dart';
import '../../widgets/pulse_button.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TechnicalGridBackground(
        spacing: 23,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(21.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PulseCraft', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                Text('Precision Gym Lab', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Container(
                  width: 48,
                  height: 3,
                  color: AppColors.acidLime,
                ),
                const Spacer(),
                Text('AI form tracking with live sticking-point detection.', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                PulseButton(label: 'Start live session', icon: Icons.videocam_outlined, onPressed: () => context.go('/live')),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: () => context.go('/dashboard'), child: const Text('Open trajectory lab')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
