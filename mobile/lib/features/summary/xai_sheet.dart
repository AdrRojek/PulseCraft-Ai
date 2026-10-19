import 'package:flutter/material.dart';

import '../../domain/models/workout_session.dart';

class XaiSheet extends StatelessWidget {
  const XaiSheet({super.key, this.session});

  final WorkoutSession? session;

  @override
  Widget build(BuildContext context) {
    final s = session;
    final lines = <String>[
      if (s == null) 'No session context.',
      if (s != null) ...[
        'Lift: ${s.exercise.label}',
        'Reps: ${s.repCount}',
        'Avg form: ${(s.avgScore * 100).round()}%',
        if (s.primaryStickingAt != null)
          'Primary sticking ~${(s.primaryStickingAt! * 100).round()}% of ROM (velocity trough on bar proxy).'
        else
          'No clear sticking trough — velocity stayed healthier across reps.',
        ...s.coachingNotes,
        'Depth uses a torso-scale proxy (not metric 3D). Treat path as coaching signal, not lab capture.',
      ],
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coaching rationale',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (final line in lines) ...[
            Text(line, style: const TextStyle(color: Colors.white70, height: 1.4)),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
