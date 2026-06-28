import 'package:flutter/material.dart';
import '../../widgets/metric_mono.dart';
import 'xai_sheet.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MetricMono(value: '86', unit: 'score'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => showModalBottomSheet(context: context, builder: (_) => const XaiSheet()),
              child: const Text('Explain with XAI'),
            ),
          ],
        ),
      ),
    );
  }
}
