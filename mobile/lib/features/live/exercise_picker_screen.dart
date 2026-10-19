import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/exercise_type.dart';

class ExercisePickerScreen extends StatelessWidget {
  const ExercisePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.steel900,
      appBar: AppBar(title: const Text('Choose lift')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Live session',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pick the movement. PulseCraft tracks bar path, sticking, and reps on-device.',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          for (final e in ExerciseType.values) ...[
            _LiftCard(
              exercise: e,
              onTap: () => context.go('/live?exercise=${e.id}'),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _LiftCard extends StatelessWidget {
  const _LiftCard({required this.exercise, required this.onTap});

  final ExerciseType exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.steel800,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.steel700),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 42,
                color: AppColors.acidLime,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.blurb,
                      style: const TextStyle(color: AppColors.graphite, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.graphite),
            ],
          ),
        ),
      ),
    );
  }
}
