import 'dart:math' as math;
import 'dart:ui';

import '../domain/models/exercise_type.dart';
import '../domain/models/form_score.dart';
import '../domain/models/rep.dart';
import '../domain/models/trajectory_point.dart';

class AnalysisTick {
  const AnalysisTick({
    required this.joints,
    required this.formScore,
    required this.barVelocity,
    required this.sticking,
    required this.hint,
    required this.hasPerson,
    required this.trajectory,
    required this.repCount,
    this.completedRep,
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
  final Rep? completedRep;
  final Offset? barPoint;
}

enum _LiftPhase { idle, down, up }

/// On-device rep machine + bar-proxy trajectory + sticking (2D, depth proxy).
class PoseSessionAnalyzer {
  PoseSessionAnalyzer({this.exercise = ExerciseType.squat});

  ExerciseType exercise;

  _LiftPhase _phase = _LiftPhase.idle;
  final List<TrajectoryPoint> _repBuf = [];
  final List<double> _yBuf = [];
  int _repIndex = 0;
  double _t0 = 0;
  Offset? _lastBar;
  DateTime? _lastTs;
  double _peakDownY = 0;
  double _minUpY = 1;

  void reset() {
    _phase = _LiftPhase.idle;
    _repBuf.clear();
    _yBuf.clear();
    _repIndex = 0;
    _t0 = 0;
    _lastBar = null;
    _lastTs = null;
    _peakDownY = 0;
    _minUpY = 1;
  }

  AnalysisTick feed(List<Offset> joints, DateTime now) {
    if (joints.length < 13) {
      return AnalysisTick(
        joints: joints,
        formScore: 0,
        barVelocity: 0,
        sticking: false,
        hint: 'Tracking…',
        hasPerson: false,
        trajectory: List.unmodifiable(_repBuf),
        repCount: _repIndex,
      );
    }

    final bar = _barProxy(joints);
    final depth = _depthProxy(joints);
    final t = now.millisecondsSinceEpoch / 1000.0;
    if (_t0 == 0) _t0 = t;

    var vel = 0.0;
    if (_lastBar != null && _lastTs != null) {
      final dt = now.difference(_lastTs!).inMilliseconds / 1000.0;
      if (dt > 0.008) {
        vel = (bar.dy - _lastBar!.dy).abs() / dt;
      }
    }
    _lastBar = bar;
    _lastTs = now;

    final point = TrajectoryPoint(
      t: t - _t0,
      x: bar.dx,
      y: bar.dy,
      z: depth,
      velocity: vel,
    );
    _repBuf.add(point);
    if (_repBuf.length > 240) _repBuf.removeAt(0);
    _yBuf.add(bar.dy);
    if (_yBuf.length > 240) _yBuf.removeAt(0);

    final signal = _primarySignal(joints);
    Rep? completed;
    final phaseBefore = _phase;
    _advancePhase(signal);
    if (phaseBefore == _LiftPhase.up && _phase == _LiftPhase.idle) {
      completed = _finalizeRep();
    }

    final form = _formScore(joints, vel);
    final sticking = _liveSticking(vel, signal);
    final hint = sticking
        ? 'sticking · drive through'
        : (_hintForExercise(joints, form.overall));

    return AnalysisTick(
      joints: joints,
      formScore: form.overall,
      barVelocity: vel.clamp(0.0, 3.0),
      sticking: sticking,
      hint: hint,
      hasPerson: true,
      trajectory: List.unmodifiable(_repBuf),
      repCount: _repIndex,
      completedRep: completed,
      barPoint: bar,
    );
  }

  /// Mid-wrist = bar proxy (or mid-shoulder for bodyline lifts).
  Offset _barProxy(List<Offset> j) {
    switch (exercise) {
      case ExerciseType.bench:
        return Offset((j[5].dx + j[6].dx) / 2, (j[5].dy + j[6].dy) / 2); // wrists
      case ExerciseType.deadlift:
      case ExerciseType.squat:
        // Prefer wrists if visible, else mid-hip.
        final w = Offset((j[5].dx + j[6].dx) / 2, (j[5].dy + j[6].dy) / 2);
        if (w.dx > 0.02 && w.dy > 0.02) return w;
        return Offset((j[7].dx + j[8].dx) / 2, (j[7].dy + j[8].dy) / 2);
    }
  }

  double _depthProxy(List<Offset> j) {
    // Shoulder width / torso height as crude scale (pseudo-depth).
    final shoulder = (j[1] - j[2]).distance;
    final torso = (Offset((j[1].dx + j[2].dx) / 2, (j[1].dy + j[2].dy) / 2) -
            Offset((j[7].dx + j[8].dx) / 2, (j[7].dy + j[8].dy) / 2))
        .distance;
    if (torso < 1e-3) return 0;
    return (shoulder / torso).clamp(0.0, 1.0);
  }

  /// Signal increases as athlete goes "down" in the lift.
  double _primarySignal(List<Offset> j) {
    switch (exercise) {
      case ExerciseType.squat:
        return _angle(j[7], j[9], j[11]); // knee — lower angle = deeper
      case ExerciseType.deadlift:
        final hip = Offset((j[7].dx + j[8].dx) / 2, (j[7].dy + j[8].dy) / 2);
        return hip.dy; // hip drop
      case ExerciseType.bench:
        return _angle(j[1], j[3], j[5]); // elbow
    }
  }

  void _advancePhase(double signal) {
    switch (exercise) {
      case ExerciseType.squat:
        // Knee angle: ~170 standing, ~80 deep.
        if (_phase == _LiftPhase.idle && signal < 140) {
          _phase = _LiftPhase.down;
          _peakDownY = signal;
        } else if (_phase == _LiftPhase.down) {
          if (signal < _peakDownY) _peakDownY = signal;
          if (signal > _peakDownY + 25) {
            _phase = _LiftPhase.up;
            _minUpY = signal;
          }
        } else if (_phase == _LiftPhase.up) {
          if (signal > _minUpY) _minUpY = signal;
          if (signal > 155) _phase = _LiftPhase.idle;
        }
      case ExerciseType.deadlift:
        if (_phase == _LiftPhase.idle && signal > 0.55) {
          _phase = _LiftPhase.down;
          _peakDownY = signal;
        } else if (_phase == _LiftPhase.down) {
          if (signal > _peakDownY) _peakDownY = signal;
          if (signal < _peakDownY - 0.08) {
            _phase = _LiftPhase.up;
            _minUpY = signal;
          }
        } else if (_phase == _LiftPhase.up) {
          if (signal < _minUpY) _minUpY = signal;
          if (signal < 0.48) _phase = _LiftPhase.idle;
        }
      case ExerciseType.bench:
        // Elbow closes on way down.
        if (_phase == _LiftPhase.idle && signal < 130) {
          _phase = _LiftPhase.down;
          _peakDownY = signal;
        } else if (_phase == _LiftPhase.down) {
          if (signal < _peakDownY) _peakDownY = signal;
          if (signal > _peakDownY + 20) {
            _phase = _LiftPhase.up;
            _minUpY = signal;
          }
        } else if (_phase == _LiftPhase.up) {
          if (signal > _minUpY) _minUpY = signal;
          if (signal > 150) _phase = _LiftPhase.idle;
        }
    }
  }

  Rep? _finalizeRep() {
    if (_repBuf.length < 8) {
      _repBuf.clear();
      _yBuf.clear();
      return null;
    }
    final pts = List<TrajectoryPoint>.from(_repBuf);
    final stickIdx = _stickingIndex(pts);
    double? stickAt;
    if (stickIdx != null && pts.length > 1) {
      stickAt = stickIdx / (pts.length - 1);
    }
    final peak = pts.fold<double>(0, (a, p) => math.max(a, p.velocity));
    final score = _scoreFromRep(pts, stickAt);
    _repIndex += 1;
    final rep = Rep(
      index: _repIndex,
      points: pts,
      score: score,
      stickingAt: stickAt,
      peakVelocity: peak,
    );
    _repBuf.clear();
    _yBuf.clear();
    return rep;
  }

  int? _stickingIndex(List<TrajectoryPoint> pts) {
    if (pts.length < 5) return null;
    final vs = pts.map((p) => p.velocity).toList();
    final maxV = vs.reduce(math.max) + 1e-9;
    int? best;
    var bestVal = 1.0;
    for (var i = 1; i < vs.length - 1; i++) {
      final n = vs[i] / maxV;
      if (n < 0.18 && vs[i] <= vs[i - 1] && vs[i] <= vs[i + 1] && n < bestVal) {
        bestVal = n;
        best = i;
      }
    }
    return best;
  }

  FormScore _scoreFromRep(List<TrajectoryPoint> pts, double? stickAt) {
    var overall = 0.9;
    if (stickAt != null) overall -= 0.12;
    final xs = pts.map((p) => p.x);
    final drift = (xs.reduce(math.max) - xs.reduce(math.min)).clamp(0.0, 0.4);
    overall -= drift;
    overall = overall.clamp(0.05, 0.98);
    return FormScore(
      overall: overall,
      stability: (1 - drift).clamp(0.0, 1.0),
      range: 0.8,
      notes: stickAt != null ? 'sticking @ ${(stickAt * 100).round()}% ROM' : 'clean rep',
    );
  }

  FormScore _formScore(List<Offset> j, double vel) {
    final knee = (_angle(j[7], j[9], j[11]) + _angle(j[8], j[10], j[12])) / 2;
    final midHip = Offset((j[7].dx + j[8].dx) / 2, (j[7].dy + j[8].dy) / 2);
    final midShoulder = Offset((j[1].dx + j[2].dx) / 2, (j[1].dy + j[2].dy) / 2);
    final lean = (midShoulder.dx - midHip.dx).abs();
    var score = 1.0;
    if (exercise == ExerciseType.squat && (knee < 55 || knee > 178)) score -= 0.2;
    score -= (lean * 1.6).clamp(0.0, 0.35);
    return FormScore(overall: score.clamp(0.05, 0.98), stability: 1 - lean, range: knee / 180);
  }

  bool _liveSticking(double vel, double signal) {
    switch (exercise) {
      case ExerciseType.squat:
        return vel < 0.18 && signal > 70 && signal < 130;
      case ExerciseType.deadlift:
        return vel < 0.16 && signal > 0.5 && signal < 0.7;
      case ExerciseType.bench:
        return vel < 0.16 && signal > 70 && signal < 120;
    }
  }

  String _hintForExercise(List<Offset> j, double score) {
    final midHip = Offset((j[7].dx + j[8].dx) / 2, (j[7].dy + j[8].dy) / 2);
    final midShoulder = Offset((j[1].dx + j[2].dx) / 2, (j[1].dy + j[2].dy) / 2);
    final lean = (midShoulder.dx - midHip.dx).abs();
    if (lean > 0.12) return 'torso leaning forward';
    if (score > 0.85) return 'live pose · solid';
    return 'live pose · ${exercise.label.toLowerCase()}';
  }

  double _angle(Offset a, Offset b, Offset c) {
    final ba = a - b;
    final bc = c - b;
    final mag = ba.distance * bc.distance;
    if (mag < 1e-6) return 180;
    final cos = ((ba.dx * bc.dx + ba.dy * bc.dy) / mag).clamp(-1.0, 1.0);
    return math.acos(cos) * 180 / math.pi;
  }
}
