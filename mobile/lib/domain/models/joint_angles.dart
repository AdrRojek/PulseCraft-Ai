class JointAngles {
  const JointAngles({required this.elbow, required this.shoulder, required this.hip, required this.knee});

  final double elbow;
  final double shoulder;
  final double hip;
  final double knee;

  double get sum => elbow + shoulder + hip + knee;
}
