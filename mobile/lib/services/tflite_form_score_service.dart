import '../domain/models/form_score.dart';
import '../domain/models/joint_angles.dart';

class TfliteFormScoreService {
  Future<FormScore> score(JointAngles angles) async {
    final stability = (angles.sum / 400).clamp(0.0, 1.0);
    return FormScore(overall: stability, stability: stability, range: 0.8, notes: 'on-device');
  }
}
