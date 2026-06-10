class EmotionLog {
  EmotionLog({
    required this.id,
    required this.emotionType,
    required this.intensity,
    this.createdAt,
  });

  final int id;
  final String emotionType;
  final int intensity;
  final DateTime? createdAt;

  factory EmotionLog.fromJson(Map<String, dynamic> json) {
    return EmotionLog(
      id: _int(json['id']),
      emotionType: json['emotion_type']?.toString() ?? '',
      intensity: _int(json['intensity']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

int _int(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
