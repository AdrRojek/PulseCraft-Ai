enum ExerciseType {
  squat,
  deadlift,
  bench;

  String get id => name;

  String get label => switch (this) {
        ExerciseType.squat => 'Squat',
        ExerciseType.deadlift => 'Deadlift',
        ExerciseType.bench => 'Bench press',
      };

  String get blurb => switch (this) {
        ExerciseType.squat => 'Knees + hips · bar over mid-foot',
        ExerciseType.deadlift => 'Hinge · lockout without hyperextension',
        ExerciseType.bench => 'Elbow path · controlled touch',
      };

  static ExerciseType fromId(String? id) {
    return ExerciseType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => ExerciseType.squat,
    );
  }
}
