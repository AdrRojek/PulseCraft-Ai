class FormScore {
  const FormScore({
    required this.overall,
    required this.stability,
    required this.range,
    this.notes = '',
  });

  final double overall;
  final double stability;
  final double range;
  final String notes;

  bool get isPassing => overall >= 0.72;

  Map<String, dynamic> toJson() => {
        'overall': overall,
        'stability': stability,
        'range': range,
        'notes': notes,
      };

  factory FormScore.fromJson(Map<String, dynamic> json) => FormScore(
        overall: (json['overall'] as num).toDouble(),
        stability: (json['stability'] as num).toDouble(),
        range: (json['range'] as num).toDouble(),
        notes: json['notes'] as String? ?? '',
      );
}
