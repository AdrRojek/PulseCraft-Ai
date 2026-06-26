import 'rep.dart';

class WorkoutSet {
  const WorkoutSet({required this.label, required this.reps, this.targetReps = 8});

  final String label;
  final List<Rep> reps;
  final int targetReps;

  int get completed => reps.length;
  double get avgScore => reps.isEmpty ? 0 : reps.map((r) => r.score.overall).reduce((a, b) => a + b) / reps.length;
}
