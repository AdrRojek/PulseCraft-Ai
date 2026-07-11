import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/camera/camera_bloc.dart';
import '../../../bloc/camera/camera_event.dart';
import '../../../bloc/camera/camera_state.dart';
import '../../../bloc/workout/workout_session_cubit.dart';
import '../../../widgets/metric_mono.dart';
import '../../../widgets/velocity_ribbon.dart';
import 'widgets/score_ring.dart';
import 'widgets/skeleton_overlay.dart';
import 'widgets/sticking_pulse.dart';

class CameraHudScreen extends StatelessWidget {
  const CameraHudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CameraBloc()..add(const CameraStarted())),
        BlocProvider(create: (_) => WorkoutSessionCubit()),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Live HUD'), backgroundColor: const Color(0xFF1A222C)),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFF0F141A)),
            const SkeletonOverlay(joints: [Offset(100, 120), Offset(140, 180), Offset(120, 240)]),
            Positioned(
              top: 19,
              right: 16,
              child: const ScoreRing(score: 0.82),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  MetricMono(value: '1.24', unit: 'm/s', size: 16),
                  SizedBox(height: 8),
                  VelocityRibbon(velocity: 1.24, max: 2),
                  SizedBox(height: 12),
                  StickingPulse(active: true),
                ],
              ),
            ),
            BlocBuilder<CameraBloc, CameraState>(
              builder: (context, state) => Positioned(
                top: 16,
                left: 16,
                child: Text(state.status.name, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
