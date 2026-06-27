import 'package:equatable/equatable.dart';

sealed class CameraEvent extends Equatable {
  const CameraEvent();
  @override
  List<Object?> get props => [];
}

class CameraStarted extends CameraEvent {
  const CameraStarted();
}

class CameraFrameCaptured extends CameraEvent {
  const CameraFrameCaptured(this.bytes);
  final List<int> bytes;
  @override
  List<Object?> get props => [bytes];
}

class CameraStopped extends CameraEvent {
  const CameraStopped();
}
