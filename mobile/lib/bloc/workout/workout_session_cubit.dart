import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/rep.dart';
import '../../services/haptics_service.dart';

enum WorkoutSideEffect { none, repStarted, stickingPointDetected, repCompleted, formBreakdownFailure }

class WorkoutSessionState {
  const WorkoutSessionState({this.reps = const [], this.sideEffect = WorkoutSideEffect.none});

  final List<Rep> reps;
  final WorkoutSideEffect sideEffect;

  WorkoutSessionState copyWith({List<Rep>? reps, WorkoutSideEffect? sideEffect}) =>
      WorkoutSessionState(reps: reps ?? this.reps, sideEffect: sideEffect ?? WorkoutSideEffect.none);
}

class WorkoutSessionCubit extends Cubit<WorkoutSessionState> {
  WorkoutSessionCubit({HapticsService? haptics})
      : _haptics = haptics ?? HapticsService(),
        super(const WorkoutSessionState());

  final HapticsService _haptics;

  void onRepStarted() {
    emit(state.copyWith(sideEffect: WorkoutSideEffect.repStarted));
    _clearSideEffect();
  }

  void onStickingPointDetected() async {
    await _haptics.stickingDetected();
    emit(state.copyWith(sideEffect: WorkoutSideEffect.stickingPointDetected));
    _clearSideEffect();
  }

  void onRepCompleted(Rep rep) async {
    await _haptics.repCompleted();
    emit(state.copyWith(reps: [...state.reps, rep], sideEffect: WorkoutSideEffect.repCompleted));
    _clearSideEffect();
  }

  void onFormBreakdownFailure() async {
    await _haptics.formBreakdown();
    emit(state.copyWith(sideEffect: WorkoutSideEffect.formBreakdownFailure));
    _clearSideEffect();
  }

  void _clearSideEffect() {
    emit(state.copyWith(sideEffect: WorkoutSideEffect.none));
  }
}
