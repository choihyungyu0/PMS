import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/api_exception.dart';
import '../models/cycle.dart';
import '../models/sleep_log.dart';
import '../services/record_api.dart';

class RecordController extends ChangeNotifier {
  RecordController(this._recordApi);

  final RecordApi _recordApi;

  bool loading = false;
  String? errorMessage;
  String? successMessage;
  CycleLog? latestCycle;
  SleepLog? latestSleep;

  static const unsupportedBodySymptomsKey = 'more_cycle_body_symptoms';

  Future<void> loadLatestCycle() async {
    try {
      latestCycle = await _recordApi.latestCycle();
      notifyListeners();
    } catch (_) {
      // Home can render without record data.
    }
  }

  Future<void> loadLatestSleep() async {
    try {
      final logs = await _recordApi.sleepLogs();
      if (logs.isEmpty) {
        latestSleep = null;
      } else {
        logs.sort((a, b) => b.sleepStart.compareTo(a.sleepStart));
        latestSleep = logs.first;
      }
      notifyListeners();
    } catch (_) {
      // Home can render without sleep data.
    }
  }

  Future<bool> createCycle(String startDate, String? endDate, String? memo) {
    return _submit(() async {
      latestCycle = await _recordApi.createCycle(
        startDate: startDate,
        endDate: endDate,
        memo: memo,
      );
      return '생리 주기 기록을 저장했어요.';
    });
  }

  Future<bool> createEmotion(String emotionType, int intensity) {
    return _submit(() async {
      await _recordApi.createEmotion(
        emotionType: emotionType,
        intensity: intensity,
      );
      return '감정 기록을 저장했어요.';
    });
  }

  Future<bool> createSleep(
    DateTime start,
    DateTime end,
    double hours,
    int qualityScore,
  ) {
    return _submit(() async {
      latestSleep = await _recordApi.createSleep(
        sleepStart: start,
        sleepEnd: end,
        sleepHours: hours,
        qualityScore: qualityScore,
      );
      return '수면 기록을 저장했어요.';
    });
  }

  Future<bool> createPain(String painType, int painScore, String? memo) {
    return _submit(() async {
      await _recordApi.createPain(
        painType: painType,
        painScore: painScore,
        memo: memo,
      );
      return '통증 기록을 저장했어요.';
    });
  }

  Future<bool> createConditionRecords({
    required String recordDate,
    required List<ConditionPainDraft> painDrafts,
    required List<ConditionEmotionDraft> emotionDrafts,
    required List<ConditionUnsupportedSymptomDraft> unsupportedSymptoms,
  }) async {
    loading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      if (unsupportedSymptoms.isNotEmpty) {
        await _saveUnsupportedBodySymptoms(recordDate, unsupportedSymptoms);
      }
      for (final draft in painDrafts) {
        await _recordApi.createPain(
          painType: draft.painType,
          painScore: draft.painScore,
          memo: draft.memo,
        );
      }
      for (final draft in emotionDrafts) {
        await _recordApi.createEmotion(
          emotionType: draft.emotionType,
          intensity: draft.intensity,
        );
      }
      successMessage = '오늘의 컨디션이 저장되었어요.';
      loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = '컨디션 저장에 실패했어요. 잠시 후 다시 시도해주세요.';
    }

    loading = false;
    notifyListeners();
    return false;
  }

  Future<void> _saveUnsupportedBodySymptoms(
    String recordDate,
    List<ConditionUnsupportedSymptomDraft> symptoms,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getString(unsupportedBodySymptomsKey);
    final entries = <Map<String, dynamic>>[];
    if (storedValue != null && storedValue.isNotEmpty) {
      final decoded = jsonDecode(storedValue);
      if (decoded is List) {
        entries.addAll(
          decoded.whereType<Map>().map((item) {
            return item.map((key, value) => MapEntry(key.toString(), value));
          }),
        );
      }
    }
    entries.add({
      'record_date': recordDate,
      'symptoms': symptoms
          .map((symptom) => {'id': symptom.id, 'label': symptom.label})
          .toList(),
      'saved_at': DateTime.now().toIso8601String(),
    });
    await prefs.setString(unsupportedBodySymptomsKey, jsonEncode(entries));
  }

  Future<bool> _submit(Future<String> Function() action) async {
    loading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
    try {
      successMessage = await action();
      loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = '기록 저장에 실패했어요. 서버 상태를 확인해주세요.';
    }
    loading = false;
    notifyListeners();
    return false;
  }
}

class ConditionPainDraft {
  const ConditionPainDraft({
    required this.painType,
    required this.painScore,
    this.memo,
  });

  final String painType;
  final int painScore;
  final String? memo;
}

class ConditionEmotionDraft {
  const ConditionEmotionDraft({
    required this.emotionType,
    required this.intensity,
  });

  final String emotionType;
  final int intensity;
}

class ConditionUnsupportedSymptomDraft {
  const ConditionUnsupportedSymptomDraft({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}
