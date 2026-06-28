import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TrajectoryDashboardScreen extends StatefulWidget {
  const TrajectoryDashboardScreen({super.key});

  @override
  State<TrajectoryDashboardScreen> createState() => _TrajectoryDashboardScreenState();
}

class _TrajectoryDashboardScreenState extends State<TrajectoryDashboardScreen> {
  double _scrub = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trajectory Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(color: AppColors.gridLine, strokeWidth: 1),
                  ),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(20, (i) => FlSpot(i.toDouble(), (i / 5) + (i.isEven ? 0.2 : 0))),
                      isCurved: true,
                      color: AppColors.acidLime,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            Slider(value: _scrub, onChanged: (v) => setState(() => _scrub = v)),
            TextButton(
              onPressed: () {
                final label = _scrub.toStringAsFixed(2);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sticking point @ $label')));
              },
              child: const Text('Mark sticking point'),
            ),
          ],
        ),
      ),
    );
  }
}
