class MedicalInstitution {
  MedicalInstitution({
    required this.id,
    required this.institutionName,
    required this.serviceCategory,
    this.institutionType,
    this.department,
    this.address,
    this.sigungu,
    this.phone,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  final int id;
  final String institutionName;
  final String? institutionType;
  final String? department;
  final String serviceCategory;
  final String? address;
  final String? sigungu;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;

  factory MedicalInstitution.fromJson(Map<String, dynamic> json) {
    return MedicalInstitution(
      id: _int(json['id']),
      institutionName: json['institution_name']?.toString() ?? '',
      institutionType: json['institution_type']?.toString(),
      department: json['department']?.toString(),
      serviceCategory: json['service_category']?.toString() ?? '',
      address: json['address']?.toString(),
      sigungu: json['sigungu']?.toString(),
      phone: json['phone']?.toString(),
      latitude: _nullableDouble(json['latitude']),
      longitude: _nullableDouble(json['longitude']),
      distanceKm: _nullableDouble(json['distance_km']),
    );
  }
}

class InstitutionRecommendation {
  InstitutionRecommendation({
    this.category,
    required this.reason,
    required this.disclaimer,
    required this.availabilityNotice,
    required this.items,
  });

  final String? category;
  final String reason;
  final String disclaimer;
  final String availabilityNotice;
  final List<MedicalInstitution> items;

  factory InstitutionRecommendation.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return InstitutionRecommendation(
      category: json['category']?.toString(),
      reason: json['reason']?.toString() ?? '',
      disclaimer: json['disclaimer']?.toString() ?? '',
      availabilityNotice: json['availability_notice']?.toString() ?? '',
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(MedicalInstitution.fromJson)
                .toList()
          : const [],
    );
  }
}

int _int(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
double? _nullableDouble(dynamic value) => value == null
    ? null
    : (value is num ? value.toDouble() : double.tryParse('$value'));
