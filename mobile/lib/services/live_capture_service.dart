import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../boot_log.dart';
import '../domain/models/exercise_type.dart';
import '../domain/models/rep.dart';
import '../domain/models/trajectory_point.dart';
import 'pose_session_analyzer.dart';

class LiveMetrics {
  const LiveMetrics({
    this.joints = const [],
    this.formScore = 0,
    this.barVelocity = 0,
    this.sticking = false,
    this.hint = 'Point camera at your full body',
    this.hasPerson = false,
    this.trajectory = const [],
    this.repCount = 0,
    this.barPoint,
  });

  final List<Offset> joints;
  final double formScore;
  final double barVelocity;
  final bool sticking;
  final String hint;
  final bool hasPerson;
  final List<TrajectoryPoint> trajectory;
  final int repCount;
  final Offset? barPoint;
}

/// Camera capture. Preview = software frames from the image stream
/// (native CameraPreview Texture is black with custom FlutterEngine).
class LiveCaptureService {
  LiveCaptureService({ExerciseType exercise = ExerciseType.squat})
      : _analyzer = PoseSessionAnalyzer(exercise: exercise);

  CameraController? controller;
  PoseDetector? _detector;
  final PoseSessionAnalyzer _analyzer;
  bool _busy = false;
  bool _running = false;
  bool _streamingImages = false;
  bool _poseEnabled = false;
  bool _preferFront = false;
  int frameCount = 0;
  int previewPaintCount = 0;
  String lastError = '';
  double lastLuma = -1;
  ui.Image? _previewFrame;
  final List<ui.Image> _pendingDispose = [];

  final _metrics = StreamController<LiveMetrics>.broadcast();
  final _status = StreamController<String>.broadcast();
  final _reps = StreamController<Rep>.broadcast();
  final previewFrame = ValueNotifier<ui.Image?>(null);

  Stream<LiveMetrics> get metrics => _metrics.stream;
  Stream<String> get status => _status.stream;
  Stream<Rep> get completedReps => _reps.stream;
  bool get isFront =>
      controller?.description.lensDirection == CameraLensDirection.front;
  bool get isStreaming => _streamingImages;
  bool get isPoseEnabled => _poseEnabled;

  set exercise(ExerciseType value) {
    _analyzer.exercise = value;
    _analyzer.reset();
  }

  Future<void> start({bool preferFront = false}) async {
    if (kIsWeb) {
      _status.add('web_unsupported');
      throw UnsupportedError('Live capture requires iOS/Android');
    }
    _preferFront = preferFront;
    _status.add('initializing');
    BootLog.logSync('cam: start preferFront=$preferFront');

    try {
      final cameras = await availableCameras();
      BootLog.logSync('cam: found ${cameras.length} cameras');
      for (final c in cameras) {
        BootLog.logSync('cam:  - ${c.name} ${c.lensDirection.name} ori=${c.sensorOrientation}');
      }
      if (cameras.isEmpty) {
        _status.add('no_camera');
        throw StateError('No cameras available');
      }

      final cam = cameras.firstWhere(
        (c) => preferFront
            ? c.lensDirection == CameraLensDirection.front
            : c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      BootLog.logSync('cam: using ${cam.lensDirection.name} ${cam.name}');

      final ctrl = CameraController(
        cam,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.nv21,
      );

      BootLog.logSync('cam: initialize()…');
      await ctrl.initialize();
      final ps = ctrl.value.previewSize;
      BootLog.logSync(
        'cam: OK init=${ctrl.value.isInitialized} '
        'preview=${ps?.width.toInt()}x${ps?.height.toInt()} '
        'aspect=${ctrl.value.aspectRatio.toStringAsFixed(3)} '
        'tex=${ctrl.cameraId} err=${ctrl.value.errorDescription}',
      );

      try {
        await ctrl.lockCaptureOrientation(DeviceOrientation.portraitUp);
      } catch (_) {}

      controller = ctrl;
      _running = true;
      _status.add('preview');

      // Stream is required for visible preview (Texture is black).
      await _startImageStream();
      // Pose tracking is the default product mode.
      await enablePose(true);
    } catch (e, st) {
      lastError = '$e';
      BootLog.logSync('cam: START FAILED: $e');
      BootLog.logSync('$st');
      rethrow;
    }
  }

  Future<void> switchCamera() async {
    final pose = _poseEnabled;
    BootLog.logSync('cam: switchCamera pose=$pose');
    await _teardownCapture();
    await start(preferFront: !_preferFront);
    if (pose) await enablePose(true);
  }

  Future<void> _startImageStream() async {
    final ctrl = controller;
    if (!_running || ctrl == null || _streamingImages) return;
    _streamingImages = true;
    BootLog.logSync('cam: startImageStream (for software preview)…');
    await ctrl.startImageStream(_onFrame);
    BootLog.logSync('cam: imageStream STARTED');
    _status.add('streaming');
  }

  Future<void> enablePose(bool enabled) async {
    _poseEnabled = enabled;
    BootLog.logSync('cam: pose enabled=$_poseEnabled');
    if (enabled) {
      _detector ??= PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.stream,
          model: PoseDetectionModel.base,
        ),
      );
      if (!_streamingImages) await _startImageStream();
    } else {
      _metrics.add(const LiveMetrics(hint: 'preview · pose off'));
    }
  }

  Future<void> _teardownCapture() async {
    BootLog.logSync('cam: teardown');
    _running = false;
    _streamingImages = false;
    _poseEnabled = false;
    try {
      if (controller?.value.isStreamingImages ?? false) {
        await controller?.stopImageStream();
      }
    } catch (e) {
      BootLog.logSync('cam: teardown stopStream: $e');
    }
    await controller?.dispose();
    controller = null;
    await _detector?.close();
    _detector = null;
    _clearPreviewFrame();
    frameCount = 0;
    previewPaintCount = 0;
  }

  Future<void> stop() async {
    await _teardownCapture();
    _status.add('stopped');
  }

  Future<void> dispose() async {
    await stop();
    await _metrics.close();
    await _status.close();
    await _reps.close();
    previewFrame.dispose();
  }

  void _clearPreviewFrame() {
    final cur = _previewFrame;
    _previewFrame = null;
    try {
      previewFrame.value = null;
    } catch (_) {}
    cur?.dispose();
    for (final img in _pendingDispose) {
      img.dispose();
    }
    _pendingDispose.clear();
  }

  Future<void> _onFrame(CameraImage image) async {
    if (!_running || _busy || controller == null) return;
    _busy = true;
    frameCount++;
    try {
      // Always refresh software preview.
      if (frameCount <= 5 || frameCount.isEven) {
        await _publishPreviewFrame(image);
      }

      if (!_poseEnabled || _detector == null) return;

      final input = _toInputImage(image, controller!.description);
      if (input == null) return;
      final poses = await _detector!.processImage(input);
      if (poses.isEmpty) {
        _metrics.add(const LiveMetrics(hint: 'No person in frame — step back'));
        return;
      }
      final size = input.metadata?.size ?? Size(image.width.toDouble(), image.height.toDouble());
      final joints = _normalizedJoints(poses.first, size, controller!.description.lensDirection);
      final tick = _analyzer.feed(joints, DateTime.now());
      _metrics.add(LiveMetrics(
        joints: tick.joints,
        formScore: tick.formScore,
        barVelocity: tick.barVelocity,
        sticking: tick.sticking,
        hint: tick.hint,
        hasPerson: tick.hasPerson,
        trajectory: tick.trajectory,
        repCount: tick.repCount,
        barPoint: tick.barPoint,
      ));
      if (tick.completedRep != null) {
        _reps.add(tick.completedRep!);
      }
    } catch (e, st) {
      lastError = '$e';
      if (frameCount < 5 || frameCount % 30 == 0) {
        BootLog.logSync('cam: frame err: $e');
      }
      debugPrint('pose frame error: $e\n$st');
    } finally {
      _busy = false;
    }
  }

  Future<void> _publishPreviewFrame(CameraImage image) async {
    if (!Platform.isIOS) return;
    if (image.planes.isEmpty) return;
    final plane = image.planes.first;
    final row = plane.bytesPerRow;
    final w = image.width;
    final h = image.height;
    if (row < w * 4) {
      BootLog.logSync('cam: bad stride row=$row w=$w');
      return;
    }

    final bytes = Uint8List.fromList(plane.bytes);

    // Luminance sample + force opaque alpha.
    var sum = 0;
    var samples = 0;
    for (var y = 0; y < h; y += 8) {
      final base = y * row;
      for (var x = 0; x < w; x += 8) {
        final i = base + x * 4;
        final b = bytes[i];
        final g = bytes[i + 1];
        final r = bytes[i + 2];
        sum += (r + g + b) ~/ 3;
        samples++;
        bytes[i + 3] = 0xFF;
      }
    }
    // Fill remaining alphas.
    for (var y = 0; y < h; y++) {
      final base = y * row;
      for (var x = 0; x < w; x++) {
        bytes[base + x * 4 + 3] = 0xFF;
      }
    }
    lastLuma = samples == 0 ? 0 : sum / samples;
    if (previewPaintCount < 3 || previewPaintCount % 30 == 0) {
      BootLog.logSync(
        'cam: paint#${previewPaintCount + 1} ${w}x$h luma=${lastLuma.toStringAsFixed(1)}',
      );
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      bytes,
      w,
      h,
      ui.PixelFormat.bgra8888,
      completer.complete,
      rowBytes: row,
    );
    final next = await completer.future;
    final prev = _previewFrame;
    _previewFrame = next;
    previewFrame.value = next;
    previewPaintCount++;

    if (prev != null) {
      _pendingDispose.add(prev);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        for (final img in _pendingDispose) {
          img.dispose();
        }
        _pendingDispose.clear();
      });
    }
  }

  InputImage? _toInputImage(CameraImage image, CameraDescription desc) {
    final rotation =
        InputImageRotationValue.fromRawValue(desc.sensorOrientation) ?? InputImageRotation.rotation0deg;

    if (Platform.isIOS) {
      final plane = image.planes.first;
      final bytes = Uint8List.fromList(plane.bytes);
      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.bgra8888,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    }

    final write = WriteBuffer();
    for (final p in image.planes) {
      write.putUint8List(p.bytes);
    }
    final bytes = write.done().buffer.asUint8List();
    final format = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  static const _order = <PoseLandmarkType>[
    PoseLandmarkType.nose,
    PoseLandmarkType.leftShoulder,
    PoseLandmarkType.rightShoulder,
    PoseLandmarkType.leftElbow,
    PoseLandmarkType.rightElbow,
    PoseLandmarkType.leftWrist,
    PoseLandmarkType.rightWrist,
    PoseLandmarkType.leftHip,
    PoseLandmarkType.rightHip,
    PoseLandmarkType.leftKnee,
    PoseLandmarkType.rightKnee,
    PoseLandmarkType.leftAnkle,
    PoseLandmarkType.rightAnkle,
  ];

  List<Offset> _normalizedJoints(Pose pose, Size size, CameraLensDirection lens) {
    final out = <Offset>[];
    for (final type in _order) {
      final lm = pose.landmarks[type];
      if (lm == null || lm.likelihood < 0.2) {
        out.add(Offset.zero);
        continue;
      }
      var x = lm.x / size.width;
      final y = lm.y / size.height;
      if (lens == CameraLensDirection.front) x = 1.0 - x;
      out.add(Offset(x.clamp(0.0, 1.0), y.clamp(0.0, 1.0)));
    }
    return out;
  }

}
