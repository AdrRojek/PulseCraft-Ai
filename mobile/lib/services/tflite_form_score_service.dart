/// Stub while tflite_flutter is disabled for launch diagnosis.
class TfliteFormScoreService {
  Future<void> load({String asset = 'assets/models/form_score.tflite'}) async {}

  Future<({double score, List<double> errors})> predict(List<double> features) async {
    return (score: 72.0, errors: const [0.2, 0.1, 0.1]);
  }

  void close() {}
}
