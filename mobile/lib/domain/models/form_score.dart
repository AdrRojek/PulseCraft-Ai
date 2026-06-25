class FormScore {
  const FormScore({required this.overall, required this.stability, required this.range, this.notes = ''});

  final double overall;
  final double stability;
  final double range;
  final String notes;

  bool get isPassing => overall >= 0.72;
}
