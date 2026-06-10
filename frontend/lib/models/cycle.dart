class CycleLog {
  CycleLog({
    required this.id,
    required this.startDate,
    this.endDate,
    this.cycleLength,
    this.memo,
    this.createdAt,
  });

  final int id;
  final DateTime startDate;
  final DateTime? endDate;
  final int? cycleLength;
  final String? memo;
  final DateTime? createdAt;

  factory CycleLog.fromJson(Map<String, dynamic> json) {
    return CycleLog(
      id: _int(json['id']),
      startDate:
          DateTime.tryParse(json['start_date']?.toString() ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? ''),
      cycleLength: json['cycle_length'] == null
          ? null
          : _int(json['cycle_length']),
      memo: json['memo']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

int _int(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
