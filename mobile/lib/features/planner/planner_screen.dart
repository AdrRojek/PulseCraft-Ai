import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Week Planner')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12),
        itemCount: days.length,
        itemBuilder: (context, i) {
          return DragTarget<String>(
            onAcceptWithDetails: (d) {},
            builder: (context, candidate, rejected) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.steel800,
                  border: Border.all(color: candidate.isNotEmpty ? AppColors.acidLime : AppColors.steel700),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(days[i], style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Draggable<String>(
                      data: 'squat-focus',
                      feedback: Material(
                        color: Colors.transparent,
                        child: Chip(label: const Text('Squat focus'), backgroundColor: AppColors.acidLime),
                      ),
                      child: const Chip(label: Text('Squat focus')),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
