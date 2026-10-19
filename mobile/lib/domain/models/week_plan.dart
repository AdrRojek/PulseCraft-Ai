class DayPlan {
  DayPlan({required this.day, List<String>? focuses}) : focuses = focuses ?? [];

  final String day;
  final List<String> focuses;

  Map<String, dynamic> toJson() => {'day': day, 'focuses': focuses};

  factory DayPlan.fromJson(Map<String, dynamic> json) => DayPlan(
        day: json['day'] as String,
        focuses: (json['focuses'] as List<dynamic>? ?? const []).map((e) => e as String).toList(),
      );
}

class WeekPlan {
  WeekPlan({List<DayPlan>? days, this.lastAdaptation = ''})
      : days = days ??
            [
              for (final d in const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])
                DayPlan(day: d, focuses: d == 'Mon' ? ['Squat focus'] : []),
            ];

  final List<DayPlan> days;
  String lastAdaptation;

  Map<String, dynamic> toJson() => {
        'days': days.map((d) => d.toJson()).toList(),
        'lastAdaptation': lastAdaptation,
      };

  factory WeekPlan.fromJson(Map<String, dynamic> json) => WeekPlan(
        days: (json['days'] as List<dynamic>)
            .map((e) => DayPlan.fromJson(e as Map<String, dynamic>))
            .toList(),
        lastAdaptation: json['lastAdaptation'] as String? ?? '',
      );
}
