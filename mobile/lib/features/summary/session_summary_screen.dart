import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/workout_session.dart';
import '../../services/session_repository.dart';
import '../../widgets/metric_mono.dart';
import 'xai_sheet.dart';

class SessionSummaryScreen extends StatefulWidget {
  const SessionSummaryScreen({super.key, this.sessionId});

  final String? sessionId;

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  WorkoutSession? _session;
  String _adaptation = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.sessionId;
    WorkoutSession? session;
    if (id != null) {
      session = await SessionRepository.instance.getSession(id);
    }
    final plan = await SessionRepository.instance.loadPlan();
    if (!mounted) return;
    setState(() {
      _session = session;
      _adaptation = plan.lastAdaptation;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final s = _session;
    if (s == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Session Summary')),
        body: const Center(child: Text('No session data', style: TextStyle(color: Colors.white70))),
      );
    }

    final scorePct = (s.avgScore * 100).round();
    final trail = s.allTrajectory;
    final spots = <FlSpot>[];
    for (var i = 0; i < trail.length; i++) {
      spots.add(FlSpot(i.toDouble(), 1 - trail[i].y));
    }

    return Scaffold(
      backgroundColor: AppColors.steel900,
      appBar: AppBar(title: Text('${s.exercise.label} summary')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          MetricMono(value: '$scorePct', unit: 'form', size: 48),
          const SizedBox(height: 8),
          Text(
            '${s.repCount} reps · ${s.primaryStickingAt == null ? 'no sticking flagged' : 'sticking ~${(s.primaryStickingAt! * 100).round()}% ROM'}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          const Text('Bar path (session)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: spots.length < 2
                ? const Center(child: Text('Not enough trajectory samples', style: TextStyle(color: Colors.white38)))
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
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
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          ...s.reps.map(
            (r) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Rep ${r.index}', style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                r.score.notes,
                style: const TextStyle(color: AppColors.graphite, fontSize: 12),
              ),
              trailing: Text(
                '${(r.score.overall * 100).round()}',
                style: const TextStyle(color: AppColors.acidLime, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          if (_adaptation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.steel800,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.steel700),
              ),
              child: Text(
                'Plan updated: $_adaptation',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              backgroundColor: AppColors.steel800,
              builder: (_) => XaiSheet(session: s),
            ),
            child: const Text('Explain coaching'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => context.go('/planner'),
            child: const Text('Open week planner'),
          ),
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Home'),
          ),
        ],
      ),
    );
  }
}
