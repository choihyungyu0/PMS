class SleepLog {
  SleepLog({
    required this.id,
    required this.sleepStart,
    required this.sleepEnd,
    required this.sleepHours,
    required this.qualityScore,
    this.createdAt,
  });

  final int id;
  final DateTime sleepStart;
  final DateTime sleepEnd;
  final double sleepHours;
  final int qualityScore;
  final DateTime? createdAt;

  factory SleepLog.fromJson(Map<String, dynamic> json) {
    return SleepLog(
      id: _int(json['id']),
      sleepStart:
          DateTime.tryParse(json['sleep_start']?.toString() ?? '') ??
          DateTime.now(),
      sleepEnd:
          DateTime.tryParse(json['sleep_end']?.toString() ?? '') ??
          DateTime.now(),
      sleepHours: _double(json['sleep_hours']),
      qualityScore: _int(json['quality_score']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

int _int(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
double _double(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
