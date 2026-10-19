import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/workout_session.dart';
import '../../services/session_repository.dart';

class TrajectoryDashboardScreen extends StatefulWidget {
  const TrajectoryDashboardScreen({super.key});

  @override
  State<TrajectoryDashboardScreen> createState() => _TrajectoryDashboardScreenState();
}

class _TrajectoryDashboardScreenState extends State<TrajectoryDashboardScreen> {
  List<WorkoutSession> _sessions = [];
  WorkoutSession? _selected;
  double _scrub = 0.5;
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
      _scrub = _selected?.primaryStickingAt ?? 0.5;
      _loading = false;
    });
  }

  List<FlSpot> _spotsFor(WorkoutSession? s) {
    final trail = s?.allTrajectory ?? const [];
    if (trail.length < 2) return const [];
    return [
      for (var i = 0; i < trail.length; i++) FlSpot(i.toDouble(), 1 - trail[i].y),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final sel = _selected;
    final spots = _spotsFor(sel);

    return Scaffold(
      backgroundColor: AppColors.steel900,
      appBar: AppBar(
        title: const Text('Trajectory lab'),
        actions: [
          TextButton(onPressed: () => context.go('/'), child: const Text('Home')),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_sessions.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No sessions yet — finish a Live set to populate the lab.',
                    style: TextStyle(color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else ...[
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final s = _sessions[i];
                    return ChoiceChip(
                      selected: s.id == sel?.id,
                      label: Text(
                        '${s.exercise.label} · ${DateFormat('MM/dd').format(s.startedAt)}',
                      ),
                      onSelected: (_) => setState(() {
                        _selected = s;
                        _scrub = s.primaryStickingAt ?? 0.5;
                      }),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (sel != null)
                Text(
                  '${sel.repCount} reps · avg ${(sel.avgScore * 100).round()} · '
                  'stick ${sel.primaryStickingAt == null ? '—' : '${(sel.primaryStickingAt! * 100).round()}%'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: spots.length < 2
                    ? const Center(
                        child: Text('Not enough path samples', style: TextStyle(color: Colors.white38)),
                      )
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) =>
                                FlLine(color: AppColors.gridLine, strokeWidth: 1),
                          ),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: AppColors.acidLime,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                          extraLinesData: ExtraLinesData(
                            verticalLines: [
                              VerticalLine(
                                x: _scrub * (spots.length - 1).clamp(1, spots.length),
                                color: Colors.orangeAccent.withValues(alpha: 0.7),
                                strokeWidth: 1.5,
                                dashArray: [4, 4],
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              Slider(
                value: _scrub.clamp(0, 1),
                onChanged: (v) => setState(() => _scrub = v),
              ),
              Text(
                'Sticking marker @ ${(_scrub * 100).round()}% ROM',
                style: const TextStyle(color: AppColors.graphite, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
