import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class XaiSheet extends StatelessWidget {
  const XaiSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.steel800,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Form insight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Sticking point detected at 62% ROM — reduce load 5% next set.'),
        ],
      ),
    );
  }
}
