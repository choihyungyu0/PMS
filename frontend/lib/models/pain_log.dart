class PainLog {
  PainLog({
    required this.id,
    required this.painType,
    required this.painScore,
    this.memo,
    this.createdAt,
  });

  final int id;
  final String painType;
  final int painScore;
  final String? memo;
  final DateTime? createdAt;

  factory PainLog.fromJson(Map<String, dynamic> json) {
    return PainLog(
      id: _int(json['id']),
      painType: json['pain_type']?.toString() ?? '',
      painScore: _int(json['pain_score']),
      memo: json['memo']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

int _int(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
