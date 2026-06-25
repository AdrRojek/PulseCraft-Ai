class TrajectoryPoint {
  const TrajectoryPoint({required this.t, required this.x, required this.y, this.velocity = 0});

  final double t;
  final double x;
  final double y;
  final double velocity;

  TrajectoryPoint copyWith({double? t, double? x, double? y, double? velocity}) =>
      TrajectoryPoint(t: t ?? this.t, x: x ?? this.x, y: y ?? this.y, velocity: velocity ?? this.velocity);
}
