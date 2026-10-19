import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/workout_session.dart';
import '../../services/session_repository.dart';
import '../live/widgets/trajectory_painter.dart';

class HistoryReplayScreen extends StatefulWidget {
  const HistoryReplayScreen({super.key});

  @override
  State<HistoryReplayScreen> createState() => _HistoryReplayScreenState();
}

class _HistoryReplayScreenState extends State<HistoryReplayScreen> {
  List<WorkoutSession> _sessions = [];
  WorkoutSession? _selected;
  double _t = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await SessionRepository.instance.loadSessions();
    if (!mounted) return;
    setState(() {
      _sessions = list;
      _selected = list.isEmpty ? null : list.first;
      _loading = false;
      _t = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final sel = _selected;
    final trail = sel?.allTrajectory ?? const [];
    final slice = trail.isEmpty
        ? trail
        : trail.sublist(0, (1 + _t * (trail.length - 1)).round().clamp(1, trail.length));

    return Scaffold(
      backgroundColor: AppColors.steel900,
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          TextButton(onPressed: () => context.go('/'), child: const Text('Home')),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 120,
            child: _sessions.isEmpty
                ? const Center(
                    child: Text('No sessions yet — finish a Live set', style: TextStyle(color: Colors.white54)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: _sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final s = _sessions[i];
                      final selected = s.id == sel?.id;
                      return ChoiceChip(
                        selected: selected,
                        label: Text(
                          '${s.exercise.label} · ${DateFormat('MM/dd HH:mm').format(s.startedAt)}',
                        ),
                        onSelected: (_) => setState(() {
                          _selected = s;
                          _t = 0;
                        }),
                      );
                    },
                  ),
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Color(0xFF0C1016)),
                if (slice.length >= 2)
                  CustomPaint(painter: TrajectoryPainter(points: slice), child: const SizedBox.expand()),
                if (sel != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 16,
                    child: Text(
                      '${sel.exercise.label} · ${sel.repCount} reps · avg ${(sel.avgScore * 100).round()}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
              ],
            ),
          ),
          if (trail.length >= 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Slider(
                value: _t,
                onChanged: (v) => setState(() => _t = v),
              ),
            ),
        ],
      ),
    );
  }
}
