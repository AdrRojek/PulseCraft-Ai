import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/week_plan.dart';
import '../../domain/models/workout_session.dart';
import '../../services/session_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  WorkoutSession? _last;
  WeekPlan? _plan;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _load();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sessions = await SessionRepository.instance.loadSessions();
    final plan = await SessionRepository.instance.loadPlan();
    if (!mounted) return;
    setState(() {
      _last = sessions.isEmpty ? null : sessions.first;
      _plan = plan;
    });
  }

  @override
  Widget build(BuildContext context) {
    final last = _last;
    final adaptation = _plan?.lastAdaptation ?? '';
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.steel900,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _HomeAtmosphere(),
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) => CustomPaint(
              painter: _BarPathPainter(phase: _pulse.value),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: top + 220,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.steel900.withValues(alpha: 0.85),
                    AppColors.steel900.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 320 + bottom,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.steel900,
                    AppColors.steel900.withValues(alpha: 0.92),
                    AppColors.steel900.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PULSECRAFT',
                              style: TextStyle(
                                color: AppColors.acidLime.withValues(alpha: 0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 3.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'PulseCraft',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                height: 0.95,
                                letterSpacing: -1.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Precision Gym Lab',
                              style: TextStyle(
                                color: AppColors.graphite,
                                fontSize: 15,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, _) {
                          final on = _pulse.value > 0.45;
                          return Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.steel700),
                              color: AppColors.steel800.withValues(alpha: 0.7),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: on ? AppColors.acidLime : AppColors.graphite,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  'LIVE READY',
                                  style: TextStyle(
                                    color: on ? AppColors.acidLime : AppColors.graphite,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (last != null) ...[
                    _LastSessionStrip(session: last),
                    const SizedBox(height: 14),
                  ],
                  Text(
                    adaptation.isNotEmpty
                        ? adaptation
                        : 'Camera on. Track squat, deadlift, or bench — bar path, sticking, then an adaptive week plan.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () => context.go('/pick'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.acidLime,
                        foregroundColor: AppColors.steel900,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam_outlined, size: 22),
                          SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'Start live session',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _NavTile(
                          label: 'Trajectory',
                          onTap: () => context.go('/dashboard'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _NavTile(
                          label: 'Planner',
                          onTap: () => context.go('/planner'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _NavTile(
                          label: 'History',
                          onTap: () => context.go('/history'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LastSessionStrip extends StatelessWidget {
  const _LastSessionStrip({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.acidLime.withValues(alpha: 0.85), width: 3),
        ),
        color: AppColors.steel800.withValues(alpha: 0.55),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LAST SET · ${DateFormat('MMM d').format(session.startedAt).toUpperCase()}',
                  style: const TextStyle(
                    color: AppColors.graphite,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.exercise.label} · ${session.repCount} reps',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(session.avgScore * 100).round()}',
            style: const TextStyle(
              color: AppColors.acidLime,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'FORM',
            style: TextStyle(
              color: AppColors.graphite,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.steel700),
            color: AppColors.steel800.withValues(alpha: 0.35),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeAtmosphere extends StatelessWidget {
  const _HomeAtmosphere();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _GridFadePainter(),
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.55, -0.35),
            radius: 1.15,
            colors: [
              Color(0xFF1A2614),
              AppColors.steel900,
              Color(0xFF0A0E12),
            ],
            stops: [0, 0.45, 1],
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _GridFadePainter extends CustomPainter {
  const _GridFadePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gridLine.withValues(alpha: 0.28)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height * 0.72), paint);
    }
    for (double y = 0; y < size.height * 0.72; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Soft animated bar-path silhouette — visual product cue, not data.
class _BarPathPainter extends CustomPainter {
  _BarPathPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final amp = 18 + phase * 10;
    path.moveTo(w * 0.18, h * 0.22);
    for (var i = 0; i <= 48; i++) {
      final t = i / 48;
      final x = w * (0.18 + t * 0.64);
      final y = h * (0.22 + t * 0.38) + math.sin(t * math.pi * 2 + phase * math.pi) * amp * (1 - (t - 0.5).abs());
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.acidLime.withValues(alpha: 0.14 + phase * 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    // sticking marker
    final sx = w * 0.52;
    final sy = h * 0.38 + math.sin(phase * math.pi) * 6;
    canvas.drawCircle(
      Offset(sx, sy),
      5,
      Paint()..color = const Color(0xFFFF8A4A).withValues(alpha: 0.35 + phase * 0.25),
    );
  }

  @override
  bool shouldRepaint(covariant _BarPathPainter oldDelegate) => oldDelegate.phase != phase;
}
