import '../domain/models/joint_angles.dart';

class PoseService {
  Future<JointAngles?> estimateAngles(List<int> frameBytes) async {
    await Future<void>.delayed(const Duration(milliseconds: 8));
    return const JointAngles(elbow: 92, shoulder: 44, hip: 12, knee: 78);
  }
}
