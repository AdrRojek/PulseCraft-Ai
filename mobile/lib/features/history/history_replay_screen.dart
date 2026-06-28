import 'package:flutter/material.dart';
import '../live/widgets/skeleton_overlay.dart';
import '../../core/theme/app_colors.dart';

class HistoryReplayScreen extends StatefulWidget {
  const HistoryReplayScreen({super.key});

  @override
  State<HistoryReplayScreen> createState() => _HistoryReplayScreenState();
}

class _HistoryReplayScreenState extends State<HistoryReplayScreen> {
  double _t = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Replay')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(color: AppColors.steel900),
                SkeletonOverlay(joints: [Offset(80 + _t * 40, 140), Offset(120, 200), Offset(100, 260)]),
              ],
            ),
          ),
          Slider(value: _t, onChanged: (v) => setState(() => _t = v)),
        ],
      ),
    );
  }
}
