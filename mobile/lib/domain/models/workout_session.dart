import 'exercise_type.dart';
import 'form_score.dart';
import 'rep.dart';
import 'trajectory_point.dart';

class WorkoutSession {
  WorkoutSession({
    required this.id,
    required this.exercise,
    required this.startedAt,
    this.endedAt,
    List<Rep>? reps,
    this.coachingNotes = const [],
  }) : reps = reps ?? [];

  final String id;
  final ExerciseType exercise;
  final DateTime startedAt;
  DateTime? endedAt;
  final List<Rep> reps;
  List<String> coachingNotes;

  bool get isComplete => endedAt != null;
  int get repCount => reps.length;

  double get avgScore {
    if (reps.isEmpty) return 0;
    final sum = reps.fold<double>(0, (a, r) => a + r.score.overall);
    return sum / reps.length;
  }

  double? get primaryStickingAt {
    final withStick = reps.where((r) => r.stickingAt != null).toList();
    if (withStick.isEmpty) return null;
    final sum = withStick.fold<double>(0, (a, r) => a + r.stickingAt!);
    return sum / withStick.length;
  }

  List<TrajectoryPoint> get allTrajectory =>
      reps.expand((r) => r.points).toList(growable: false);

  Map<String, dynamic> toJson() => {
        'id': id,
        'exercise': exercise.id,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'coachingNotes': coachingNotes,
        'reps': reps.map((r) => r.toJson()).toList(),
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      exercise: ExerciseType.fromId(json['exercise'] as String?),
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt'] as String) : null,
      coachingNotes: (json['coachingNotes'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      reps: (json['reps'] as List<dynamic>? ?? const [])
          .map((e) => Rep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  FormScore get summaryScore => FormScore(
        overall: avgScore,
        stability: avgScore,
        range: avgScore,
        notes: coachingNotes.isEmpty ? '' : coachingNotes.first,
      );
}
