import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/pose_service.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc({PoseService? poseService})
      : _pose = poseService ?? PoseService(),
        super(const CameraState()) {
    on<CameraStarted>(_onStarted);
    on<CameraFrameCaptured>(_onFrame);
    on<CameraStopped>(_onStopped);
  }

  final PoseService _pose;

  Future<void> _onStarted(CameraStarted event, Emitter<CameraState> emit) async {
    emit(state.copyWith(status: CameraStatus.streaming));
  }

  Future<void> _onFrame(CameraFrameCaptured event, Emitter<CameraState> emit) async {
    emit(state.copyWith(status: CameraStatus.processingFrame));
    await _pose.estimateAngles(event.bytes);
    emit(state.copyWith(status: CameraStatus.streaming));
  }

  void _onStopped(CameraStopped event, Emitter<CameraState> emit) {
    emit(const CameraState());
  }
}
