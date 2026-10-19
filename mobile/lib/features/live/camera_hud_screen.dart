import 'dart:async';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../bloc/workout/workout_session_cubit.dart';
import '../../boot_log.dart';
import '../../core/theme/pulse_colors.dart';
import '../../domain/models/exercise_type.dart';
import '../../domain/models/rep.dart';
import '../../domain/models/workout_session.dart';
import '../../services/live_capture_service.dart';
import '../../services/plan_adjuster.dart';
import '../../services/session_repository.dart';
import '../../widgets/metric_mono.dart';
import '../../widgets/velocity_ribbon.dart';
import 'widgets/camera_viewport.dart';
import 'widgets/mock_camera_plane.dart';
import 'widgets/score_ring.dart';
import 'widgets/skeleton_overlay.dart';
import 'widgets/sticking_pulse.dart';
import 'widgets/trajectory_painter.dart';

class CameraHudScreen extends StatelessWidget {
  const CameraHudScreen({super.key, this.exercise = ExerciseType.squat});

  final ExerciseType exercise;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkoutSessionCubit(),
      child: _LiveHudBody(exercise: exercise),
    );
  }
}

class _LiveHudBody extends StatefulWidget {
  const _LiveHudBody({required this.exercise});

  final ExerciseType exercise;

  @override
  State<_LiveHudBody> createState() => _LiveHudBodyState();
}

class _LiveHudBodyState extends State<_LiveHudBody> {
  late final LiveCaptureService _capture;
  late final WorkoutSession _session;
  StreamSubscription<LiveMetrics>? _sub;
  StreamSubscription<String>? _statusSub;
  StreamSubscription<Rep>? _repSub;

  LiveMetrics _metrics = const LiveMetrics();
  String _status = 'starting';
  String? _error;
  bool _ready = false;
  bool _switching = false;
  bool _stickPulseSent = false;
  bool _ending = false;
  WorkoutSessionCubit? _workout;

  @override
  void initState() {
    super.initState();
    _capture = LiveCaptureService(exercise: widget.exercise);
    _session = WorkoutSession(
      id: const Uuid().v4(),
      exercise: widget.exercise,
      startedAt: DateTime.now(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _workout = context.read<WorkoutSessionCubit>();
      _boot();
    });
  }

  Future<void> _boot() async {
    if (kIsWeb) {
      setState(() => _error = 'Live camera needs a real device (iOS/Android).');
      return;
    }
    try {
      _sub = _capture.metrics.listen((m) {
        if (!mounted) return;
        setState(() => _metrics = m);
        if (m.sticking && !_stickPulseSent) {
          _stickPulseSent = true;
          _workout?.onStickingPointDetected();
        } else if (!m.sticking) {
          _stickPulseSent = false;
        }
      });
      _statusSub = _capture.status.listen((s) {
        if (!mounted) return;
        setState(() => _status = s);
      });
      _repSub = _capture.completedReps.listen((rep) {
        _session.reps.add(rep);
        _workout?.onRepCompleted(rep);
        if (mounted) setState(() {});
      });

      await _capture.start(preferFront: false);
      await _capture.enablePose(true);
      if (!mounted) return;
      setState(() => _ready = true);
    } catch (e, st) {
      BootLog.logSync('HUD boot failed: $e\n$st');
      if (!mounted) return;
      setState(() => _error = 'Camera error: $e');
    }
  }

  Future<void> _flipCamera() async {
    if (!_ready || _switching) return;
    setState(() {
      _switching = true;
      _ready = false;
      _error = null;
    });
    try {
      await _capture.switchCamera();
      await _capture.enablePose(true);
      if (!mounted) return;
      setState(() {
        _ready = true;
        _switching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _switching = false;
        _error = 'Flip failed: $e';
      });
    }
  }

  Future<void> _endSession() async {
    if (_ending) return;
    setState(() => _ending = true);
    _session.endedAt = DateTime.now();
    final plan = await SessionRepository.instance.loadPlan();
    final adjusted = const PlanAdjuster().apply(plan, _session);
    await SessionRepository.instance.savePlan(adjusted);
    await SessionRepository.instance.saveSession(_session);
    await _capture.stop();
    if (!mounted) return;
    context.go('/summary?id=${_session.id}');
  }

  @override
  void dispose() {
    _sub?.cancel();
    _statusSub?.cancel();
    _repSub?.cancel();
    _capture.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _capture.controller;
    final live = _status == 'streaming' || _status == 'preview' || _metrics.hasPerson;
    final reps = _metrics.repCount > 0 ? _metrics.repCount : _session.repCount;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_ready && ctrl != null)
            ValueListenableBuilder<ui.Image?>(
              valueListenable: _capture.previewFrame,
              builder: (context, frame, _) {
                if (frame == null) {
                  return const ColoredBox(
                    color: Color(0xFF101820),
                    child: Center(
                      child: Text('Starting camera…', style: TextStyle(color: Colors.white54)),
                    ),
                  );
                }
                return CameraViewport(
                  image: frame,
                  sensorOrientation: ctrl.description.sensorOrientation,
                  mirror: ctrl.description.lensDirection == CameraLensDirection.front,
                );
              },
            )
          else
            const MockCameraPlane(),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.22),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),
          ),
          if (_metrics.trajectory.length >= 2)
            CustomPaint(
              painter: TrajectoryPainter(points: _metrics.trajectory),
              size: Size.infinite,
              child: const SizedBox.expand(),
            ),
          if (_metrics.joints.isNotEmpty)
            SkeletonOverlay(joints: _metrics.joints, normalized: true),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: PulseColors.primary.withValues(alpha: 0.72),
                      border: Border.all(color: PulseColors.steel),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: live ? PulseColors.lime : PulseColors.warn,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.exercise.label.toUpperCase()} · $reps REP',
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.0,
                            color: PulseColors.mist,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _IconBtn(
                    icon: Icons.cameraswitch_rounded,
                    active: _capture.isFront,
                    busy: _switching,
                    onTap: _flipCamera,
                  ),
                  const SizedBox(width: 8),
                  _IconBtn(
                    icon: Icons.stop_circle_outlined,
                    active: true,
                    busy: _ending,
                    onTap: _endSession,
                  ),
                  const SizedBox(width: 8),
                  ScoreRing(score: _metrics.formScore == 0 ? 0.01 : _metrics.formScore, size: 84),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 56,
            left: 16,
            right: 16,
            child: Text(
              _error ?? (_ready ? _metrics.hint : 'Starting camera…'),
              style: TextStyle(
                color: _error != null ? PulseColors.danger : Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'BAR V',
                      style: TextStyle(
                        color: PulseColors.lime.withValues(alpha: 0.85),
                        fontSize: 11,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(width: 12),
                    MetricMono(value: _metrics.barVelocity.toStringAsFixed(2), unit: 'u/s', size: 22),
                    const Spacer(),
                    Text(
                      'FORM',
                      style: TextStyle(
                        color: PulseColors.mist.withValues(alpha: 0.8),
                        fontSize: 11,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                VelocityRibbon(velocity: _metrics.barVelocity, max: 2),
                const SizedBox(height: 14),
                Row(
                  children: [
                    StickingPulse(active: _metrics.sticking),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _metrics.hint,
                        style: TextStyle(
                          color: _metrics.sticking ? PulseColors.warn : PulseColors.mist,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.busy = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PulseColors.primary.withValues(alpha: 0.72),
      shape: const CircleBorder(side: BorderSide(color: PulseColors.steel)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: busy ? null : onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: busy
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2, color: PulseColors.lime),
                )
              : Icon(icon, color: active ? PulseColors.lime : PulseColors.mist, size: 22),
        ),
      ),
    );
  }
}
