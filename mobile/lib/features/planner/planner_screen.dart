import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/week_plan.dart';
import '../../services/session_repository.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  WeekPlan _plan = WeekPlan();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final plan = await SessionRepository.instance.loadPlan();
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _loading = false;
    });
  }

  Future<void> _persist() async {
    await SessionRepository.instance.savePlan(_plan);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.steel900,
      appBar: AppBar(
        title: const Text('Week Planner'),
        actions: [
          TextButton(onPressed: () => context.go('/'), child: const Text('Home')),
        ],
      ),
      body: Column(
        children: [
          if (_plan.lastAdaptation.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.steel800,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.acidLime.withValues(alpha: 0.4)),
              ),
              child: Text(
                _plan.lastAdaptation,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemCount: _plan.days.length,
              itemBuilder: (context, i) {
                final day = _plan.days[i];
                return DragTarget<String>(
                  onAcceptWithDetails: (d) {
                    setState(() {
                      if (!day.focuses.contains(d.data)) day.focuses.add(d.data);
                    });
                    _persist();
                  },
                  builder: (context, candidate, rejected) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.steel800,
                        border: Border.all(
                          color: candidate.isNotEmpty ? AppColors.acidLime : AppColors.steel700,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(day.day, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView(
                              children: [
                                for (final f in day.focuses)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(f, style: const TextStyle(color: AppColors.graphite, fontSize: 12)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Wrap(
              spacing: 8,
              children: [
                for (final chip in const ['Squat focus', 'Deadlift volume', 'Bench technique', 'Recovery'])
                  Draggable<String>(
                    data: chip,
                    feedback: Material(
                      color: AppColors.acidLime,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text(chip, style: const TextStyle(color: AppColors.steel900)),
                      ),
                    ),
                    child: Chip(label: Text(chip)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
