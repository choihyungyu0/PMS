class HealthReport {
  HealthReport({
    required this.id,
    required this.pmsScore,
    required this.healthScore,
    required this.riskLevel,
    required this.confidence,
    required this.summary,
    required this.mainFactors,
    required this.careTips,
    required this.disclaimer,
    this.recommendedCategory,
    this.createdAt,
  });

  final int id;
  final int pmsScore;
  final int healthScore;
  final String riskLevel;
  final String confidence;
  final String summary;
  final List<String> mainFactors;
  final List<String> careTips;
  final String? recommendedCategory;
  final String disclaimer;
  final DateTime? createdAt;

  factory HealthReport.fromJson(Map<String, dynamic> json) {
    return HealthReport(
      id: _int(json['id']),
      pmsScore: _int(json['pms_score']),
      healthScore: _int(json['health_score']),
      riskLevel: json['risk_level']?.toString() ?? 'low',
      confidence: json['confidence']?.toString() ?? 'low',
      summary: json['summary']?.toString() ?? '',
      mainFactors: _stringList(json['main_factors']),
      careTips: _stringList(json['care_tips']),
      recommendedCategory: json['recommended_category']?.toString(),
      disclaimer: json['disclaimer']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

int _int(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  return const [];
}
