import 'package:flutter/services.dart';

class HapticsService {
  Future<void> repCompleted() => HapticFeedback.mediumImpact();
  Future<void> stickingDetected() => HapticFeedback.heavyImpact();
  Future<void> formBreakdown() => HapticFeedback.vibrate();
}
