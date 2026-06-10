import '../core/api/api_client.dart';
import '../models/health_report.dart';

class ReportApi {
  ReportApi(this._client);

  final ApiClient _client;

  Future<HealthReport?> latest() async {
    final json = await _client.get('/api/reports/latest');
    if (json == null) return null;
    return HealthReport.fromJson(json as Map<String, dynamic>);
  }

  Future<HealthReport> generate() async {
    final json =
        await _client.post('/api/reports/generate') as Map<String, dynamic>;
    return HealthReport.fromJson(json);
  }

  Future<List<HealthReport>> history() async {
    final json = await _client.get('/api/reports/history') as List<dynamic>;
    return json
        .whereType<Map<String, dynamic>>()
        .map(HealthReport.fromJson)
        .toList();
  }
}
