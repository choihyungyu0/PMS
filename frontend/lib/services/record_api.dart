import '../core/api/api_client.dart';
import '../models/cycle.dart';
import '../models/emotion_log.dart';
import '../models/pain_log.dart';
import '../models/sleep_log.dart';

class RecordApi {
  RecordApi(this._client);

  final ApiClient _client;

  Future<List<CycleLog>> cycles() async {
    final json = await _client.get('/api/cycles') as List<dynamic>;
    return json
        .whereType<Map<String, dynamic>>()
        .map(CycleLog.fromJson)
        .toList();
  }

  Future<CycleLog?> latestCycle() async {
    final json = await _client.get('/api/cycles/latest');
    if (json == null) return null;
    return CycleLog.fromJson(json as Map<String, dynamic>);
  }

  Future<CycleLog> createCycle({
    required String startDate,
    String? endDate,
    String? memo,
  }) async {
    final json =
        await _client.post(
              '/api/cycles',
              body: {
                'start_date': startDate,
                if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
                if (memo != null && memo.isNotEmpty) 'memo': memo,
              },
            )
            as Map<String, dynamic>;
    return CycleLog.fromJson(json);
  }

  Future<EmotionLog> createEmotion({
    required String emotionType,
    required int intensity,
  }) async {
    final json =
        await _client.post(
              '/api/emotions',
              body: {'emotion_type': emotionType, 'intensity': intensity},
            )
            as Map<String, dynamic>;
    return EmotionLog.fromJson(json);
  }

  Future<List<EmotionLog>> emotionLogs() async {
    final json = await _client.get('/api/emotions') as List<dynamic>;
    return json
        .whereType<Map<String, dynamic>>()
        .map(EmotionLog.fromJson)
        .toList();
  }

  Future<SleepLog> createSleep({
    required DateTime sleepStart,
    required DateTime sleepEnd,
    required double sleepHours,
    required int qualityScore,
  }) async {
    final json =
        await _client.post(
              '/api/sleep',
              body: {
                'sleep_start': sleepStart.toIso8601String(),
                'sleep_end': sleepEnd.toIso8601String(),
                'sleep_hours': sleepHours,
                'quality_score': qualityScore,
              },
            )
            as Map<String, dynamic>;
    return SleepLog.fromJson(json);
  }

  Future<List<SleepLog>> sleepLogs() async {
    final json = await _client.get('/api/sleep') as List<dynamic>;
    return json
        .whereType<Map<String, dynamic>>()
        .map(SleepLog.fromJson)
        .toList();
  }

  Future<PainLog> createPain({
    required String painType,
    required int painScore,
    String? memo,
  }) async {
    final json =
        await _client.post(
              '/api/pain',
              body: {
                'pain_type': painType,
                'pain_score': painScore,
                if (memo != null && memo.isNotEmpty) 'memo': memo,
              },
            )
            as Map<String, dynamic>;
    return PainLog.fromJson(json);
  }

  Future<List<PainLog>> painLogs() async {
    final json = await _client.get('/api/pain') as List<dynamic>;
    return json
        .whereType<Map<String, dynamic>>()
        .map(PainLog.fromJson)
        .toList();
  }
}
