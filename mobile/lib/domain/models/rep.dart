import 'trajectory_point.dart';
import 'form_score.dart';

class Rep {
  const Rep({required this.index, required this.points, required this.score, this.stickingAt});

  final int index;
  final List<TrajectoryPoint> points;
  final FormScore score;
  final double? stickingAt;
}
