import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../models/health_report.dart';
import '../services/report_api.dart';

class ReportController extends ChangeNotifier {
  ReportController(this._reportApi);

  final ReportApi _reportApi;

  bool loading = false;
  String? errorMessage;
  HealthReport? latestReport;
  List<HealthReport> history = const [];

  Future<void> load() async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      latestReport = await _reportApi.latest();
      history = await _reportApi.history();
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = '건강 리포트를 불러오지 못했어요.';
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> generate() async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      latestReport = await _reportApi.generate();
      history = await _reportApi.history();
      loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = '건강 리포트 생성에 실패했어요.';
    }
    loading = false;
    notifyListeners();
    return false;
  }
}
