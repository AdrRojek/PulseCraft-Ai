import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteFormScoreService {
  Interpreter? _interpreter;

  Future<void> load({String asset = 'assets/models/form_score.tflite'}) async {
    _interpreter = await Interpreter.fromAsset(asset);
  }

  /// features: [meanKnee, hipRiseEarly, barPathDev, peakVel, speedDrop]
  Future<({double score, List<double> errors})> predict(List<double> features) async {
    final interp = _interpreter;
    if (interp == null) {
      throw StateError('TFLite model not loaded');
    }
    final input = [features];
    final scoreOut = [List<double>.filled(1, 0.0)];
    final errOut = [List<double>.filled(3, 0.0)];
    interp.runForMultipleInputs([input], {0: scoreOut, 1: errOut});
    return (score: scoreOut[0][0] * 100.0, errors: List<double>.from(errOut[0]));
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
