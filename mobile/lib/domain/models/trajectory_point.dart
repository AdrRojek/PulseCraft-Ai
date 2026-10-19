class TrajectoryPoint {
  const TrajectoryPoint({
    required this.t,
    required this.x,
    required this.y,
    this.velocity = 0,
    this.z = 0,
  });

  final double t;
  final double x;
  final double y;
  /// Depth proxy from torso scale (0–1), not true metric depth.
  final double z;
  final double velocity;

  TrajectoryPoint copyWith({
    double? t,
    double? x,
    double? y,
    double? z,
    double? velocity,
  }) =>
      TrajectoryPoint(
        t: t ?? this.t,
        x: x ?? this.x,
        y: y ?? this.y,
        z: z ?? this.z,
        velocity: velocity ?? this.velocity,
      );

  Map<String, dynamic> toJson() => {
        't': t,
        'x': x,
        'y': y,
        'z': z,
        'velocity': velocity,
      };

  factory TrajectoryPoint.fromJson(Map<String, dynamic> json) => TrajectoryPoint(
        t: (json['t'] as num).toDouble(),
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        z: (json['z'] as num?)?.toDouble() ?? 0,
        velocity: (json['velocity'] as num?)?.toDouble() ?? 0,
      );
}
