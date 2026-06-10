import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../models/cycle.dart';
import '../services/record_api.dart';

class RecordController extends ChangeNotifier {
  RecordController(this._recordApi);

  final RecordApi _recordApi;

  bool loading = false;
  String? errorMessage;
  String? successMessage;
  CycleLog? latestCycle;

  Future<void> loadLatestCycle() async {
    try {
      latestCycle = await _recordApi.latestCycle();
      notifyListeners();
    } catch (_) {
      // Home can render without record data.
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
      await _recordApi.createSleep(
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
