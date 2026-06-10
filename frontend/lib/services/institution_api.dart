import '../core/api/api_client.dart';
import '../models/medical_institution.dart';

class InstitutionApi {
  InstitutionApi(this._client);

  final ApiClient _client;

  Future<List<String>> categories() async {
    final json =
        await _client.get('/api/institutions/categories')
            as Map<String, dynamic>;
    final items = json['items'];
    return items is List
        ? items.map((item) => item.toString()).toList()
        : const [];
  }

  Future<List<MedicalInstitution>> search({
    String? serviceCategory,
    String? sigungu,
    String? keyword,
    int limit = 20,
  }) async {
    final json =
        await _client.get(
              '/api/institutions/search',
              query: {
                'service_category': serviceCategory,
                'sigungu': sigungu,
                'keyword': keyword,
                'limit': limit,
              },
            )
            as List<dynamic>;
    return json
        .whereType<Map<String, dynamic>>()
        .map(MedicalInstitution.fromJson)
        .toList();
  }

  Future<InstitutionRecommendation> recommend({
    String? symptom,
    String? serviceCategory,
    String? sigungu,
    int limit = 10,
  }) async {
    final json =
        await _client.get(
              '/api/institutions/recommend',
              query: {
                'symptom': symptom,
                'service_category': serviceCategory,
                'sigungu': sigungu,
                'limit': limit,
              },
            )
            as Map<String, dynamic>;
    return InstitutionRecommendation.fromJson(json);
  }
}
