import '../domain/models/week_plan.dart';
import '../domain/models/workout_session.dart';

/// Rule-based adaptation of the week plan from the latest live session.
class PlanAdjuster {
  const PlanAdjuster();

  WeekPlan apply(WeekPlan plan, WorkoutSession session) {
    final notes = <String>[];
    final next = WeekPlan(
      days: plan.days
          .map((d) => DayPlan(day: d.day, focuses: List<String>.from(d.focuses)))
          .toList(),
      lastAdaptation: '',
    );

    final lift = session.exercise.label;
    final avg = session.avgScore;
    final stick = session.primaryStickingAt;

    // Prefer next training day after today (simple: first empty weekday or Wed).
    final target = next.days.firstWhere(
      (d) => d.focuses.isEmpty,
      orElse: () => next.days[2],
    );

    if (avg > 0 && avg < 0.65) {
      final tip = '$lift · technique volume (−load, +reps)';
      _pushFocus(target, tip);
      notes.add('Form avg ${(avg * 100).round()}% — reduced intensity cue on ${target.day}.');
    } else if (stick != null) {
      final pct = (stick * 100).round();
      final tip = '$lift · pause @ ~$pct% ROM';
      _pushFocus(target, tip);
      notes.add('Sticking ~$pct% ROM — added pause work on ${target.day}.');
    } else if (avg >= 0.85 && session.repCount >= 3) {
      final tip = '$lift · +2.5% load next';
      _pushFocus(target, tip);
      notes.add('Strong session — progression cue on ${target.day}.');
    } else {
      final tip = '$lift · keep current block';
      _pushFocus(target, tip);
      notes.add('Session logged — maintained plan focus on ${target.day}.');
    }

    // Speed drop across reps → fatigue note.
    if (session.reps.length >= 3) {
      final first = session.reps.first.peakVelocity;
      final last = session.reps.last.peakVelocity;
      if (first > 0.05 && last < first * 0.7) {
        final tip = 'Recovery · cut set or rest +30s';
        final fri = next.days.firstWhere((d) => d.day == 'Fri', orElse: () => target);
        _pushFocus(fri, tip);
        notes.add('Concentric speed dropped >30% — recovery cue on ${fri.day}.');
      }
    }

    next.lastAdaptation = notes.join(' ');
    session.coachingNotes = notes;
    return next;
  }

  void _pushFocus(DayPlan day, String focus) {
    if (!day.focuses.contains(focus)) {
      day.focuses.add(focus);
    }
  }
}
