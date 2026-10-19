import 'form_score.dart';
import 'trajectory_point.dart';

class Rep {
  const Rep({
    required this.index,
    required this.points,
    required this.score,
    this.stickingAt,
    this.peakVelocity = 0,
  });

  final int index;
  final List<TrajectoryPoint> points;
  final FormScore score;
  /// Normalized ROM position (0 top → 1 bottom of concentric path) of sticking.
  final double? stickingAt;
  final double peakVelocity;

  Map<String, dynamic> toJson() => {
        'index': index,
        'stickingAt': stickingAt,
        'peakVelocity': peakVelocity,
        'score': score.toJson(),
        'points': points.map((p) => p.toJson()).toList(),
      };

  factory Rep.fromJson(Map<String, dynamic> json) => Rep(
        index: json['index'] as int,
        stickingAt: (json['stickingAt'] as num?)?.toDouble(),
        peakVelocity: (json['peakVelocity'] as num?)?.toDouble() ?? 0,
        score: FormScore.fromJson(json['score'] as Map<String, dynamic>),
        points: (json['points'] as List<dynamic>? ?? const [])
            .map((e) => TrajectoryPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
