import 'package:equatable/equatable.dart';

enum CameraStatus { initial, streaming, processingFrame, error }

class CameraState extends Equatable {
  const CameraState({this.status = CameraStatus.initial, this.message});

  final CameraStatus status;
  final String? message;

  CameraState copyWith({CameraStatus? status, String? message}) =>
      CameraState(status: status ?? this.status, message: message ?? this.message);

  @override
  List<Object?> get props => [status, message];
}
