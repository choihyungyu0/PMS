import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../models/emotion_log.dart';
import '../models/health_report.dart';
import '../models/pain_log.dart';
import '../models/sleep_log.dart';
import '../services/record_api.dart';
import '../services/report_api.dart';

enum AnalysisPeriodMode { weekly, monthly, threeMonths }

class TrendPoint {
  const TrendPoint({required this.index, required this.value});

  final int index;
  final double value;
}

class AnalysisSummary {
  const AnalysisSummary({
    required this.trendPoints,
    required this.xLabels,
    required this.averageSleepHours,
    required this.stressLevel,
    required this.hasAnyRecord,
  });

  final List<TrendPoint> trendPoints;
  final List<String> xLabels;
  final double? averageSleepHours;
  final StressLevel? stressLevel;
  final bool hasAnyRecord;

  static const empty = AnalysisSummary(
    trendPoints: [],
    xLabels: ['월', '화', '수', '목', '금', '토', '일'],
    averageSleepHours: null,
    stressLevel: null,
    hasAnyRecord: false,
  );
}

enum StressLevel { low, medium, high }

class AnalysisController extends ChangeNotifier {
  AnalysisController({
    required ReportApi reportApi,
    required RecordApi recordApi,
  }) : _reportApi = reportApi,
       _recordApi = recordApi {
    _anchorDate = _today();
    _summary = _buildSummary();
  }

  final ReportApi _reportApi;
  final RecordApi _recordApi;

  AnalysisPeriodMode mode = AnalysisPeriodMode.weekly;
  bool loading = false;
  String? errorMessage;

  late DateTime _anchorDate;
  List<HealthReport> _reports = const [];
  List<SleepLog> _sleepLogs = const [];
  List<EmotionLog> _emotionLogs = const [];
  List<PainLog> _painLogs = const [];
  AnalysisSummary _summary = AnalysisSummary.empty;

  AnalysisSummary get summary => _summary;

  String get periodLabel {
    final range = _currentRange();
    return switch (mode) {
      AnalysisPeriodMode.weekly =>
        '${_monthDay(range.start)} - ${_monthDay(range.end)}',
      AnalysisPeriodMode.monthly =>
        '${range.start.year}.${_twoDigits(range.start.month)}',
      AnalysisPeriodMode.threeMonths =>
        '${range.start.year}.${_twoDigits(range.start.month)} - '
            '${range.end.year}.${_twoDigits(range.end.month)}',
    };
  }

  bool get canGoNext {
    final nextRange = _rangeFor(_shiftAnchor(1));
    return !nextRange.start.isAfter(_today());
  }

  Future<void> load() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    var failedRequests = 0;
    _reports = await _loadSafely(_reportApi.history, () => failedRequests++);
    _sleepLogs = await _loadSafely(
      _recordApi.sleepLogs,
      () => failedRequests++,
    );
    _emotionLogs = await _loadSafely(
      _recordApi.emotionLogs,
      () => failedRequests++,
    );
    _painLogs = await _loadSafely(_recordApi.painLogs, () => failedRequests++);

    _summary = _buildSummary();
    if (failedRequests == 4) {
      errorMessage = '분석 데이터를 불러오지 못했어요. 잠시 후 다시 시도해주세요.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> refresh() => load();

  void setMode(AnalysisPeriodMode value) {
    if (mode == value) {
      return;
    }
    mode = value;
    _anchorDate = _today();
    _summary = _buildSummary();
    notifyListeners();
  }

  void previousPeriod() {
    _anchorDate = _shiftAnchor(-1);
    _summary = _buildSummary();
    notifyListeners();
  }

  void nextPeriod() {
    if (!canGoNext) {
      return;
    }
    _anchorDate = _shiftAnchor(1);
    _summary = _buildSummary();
    notifyListeners();
  }

  Future<List<T>> _loadSafely<T>(
    Future<List<T>> Function() loader,
    VoidCallback onError,
  ) async {
    try {
      return await loader();
    } on ApiException {
      onError();
    } catch (_) {
      onError();
    }
    return const [];
  }

  AnalysisSummary _buildSummary() {
    final range = _currentRange();
    final xLabels = _labelsFor(range);
    final trendPoints = _reportTrend(range, xLabels.length);
    final derivedTrend = trendPoints.isEmpty
        ? _derivedSymptomTrend(range, xLabels.length)
        : trendPoints;
    final sleepAverage = _averageSleep(range);
    final stress = _averageStress(range);

    return AnalysisSummary(
      trendPoints: derivedTrend,
      xLabels: xLabels,
      averageSleepHours: sleepAverage,
      stressLevel: stress,
      hasAnyRecord:
          derivedTrend.isNotEmpty || sleepAverage != null || stress != null,
    );
  }

  List<TrendPoint> _reportTrend(_DateRange range, int bucketCount) {
    final sums = List<double>.filled(bucketCount, 0);
    final counts = List<int>.filled(bucketCount, 0);
    for (final report in _reports) {
      final createdAt = report.createdAt;
      if (createdAt == null || !_contains(range, createdAt)) {
        continue;
      }
      final bucket = _bucketIndex(range, createdAt, bucketCount);
      if (bucket == null) {
        continue;
      }
      sums[bucket] += report.pmsScore.clamp(0, 100).toDouble() * 0.4;
      counts[bucket]++;
    }
    return _pointsFromBuckets(sums, counts);
  }

  List<TrendPoint> _derivedSymptomTrend(_DateRange range, int bucketCount) {
    final painSums = List<double>.filled(bucketCount, 0);
    final painCounts = List<int>.filled(bucketCount, 0);
    final emotionSums = List<double>.filled(bucketCount, 0);
    final emotionCounts = List<int>.filled(bucketCount, 0);

    for (final pain in _painLogs) {
      final createdAt = pain.createdAt;
      if (createdAt == null || !_contains(range, createdAt)) {
        continue;
      }
      final bucket = _bucketIndex(range, createdAt, bucketCount);
      if (bucket == null) {
        continue;
      }
      painSums[bucket] += pain.painScore.clamp(0, 10).toDouble();
      painCounts[bucket]++;
    }

    for (final emotion in _emotionLogs) {
      final createdAt = emotion.createdAt;
      if (createdAt == null ||
          !_contains(range, createdAt) ||
          !_negativeEmotions.contains(emotion.emotionType)) {
        continue;
      }
      final bucket = _bucketIndex(range, createdAt, bucketCount);
      if (bucket == null) {
        continue;
      }
      emotionSums[bucket] += emotion.intensity.clamp(0, 5).toDouble();
      emotionCounts[bucket]++;
    }

    final points = <TrendPoint>[];
    for (var i = 0; i < bucketCount; i++) {
      if (painCounts[i] == 0 && emotionCounts[i] == 0) {
        continue;
      }
      final painScore = painCounts[i] == 0 ? 0 : painSums[i] / painCounts[i];
      final emotionScore = emotionCounts[i] == 0
          ? 0
          : emotionSums[i] / emotionCounts[i];
      // Display-only condition trend: pain contributes up to 20 and negative
      // emotion intensity contributes up to 20. This is not a diagnosis.
      final displayScore = (painScore * 2) + (emotionScore * 4);
      points.add(
        TrendPoint(index: i, value: displayScore.clamp(0, 40).toDouble()),
      );
    }
    return points;
  }

  List<TrendPoint> _pointsFromBuckets(List<double> sums, List<int> counts) {
    final points = <TrendPoint>[];
    for (var i = 0; i < sums.length; i++) {
      if (counts[i] == 0) {
        continue;
      }
      points.add(TrendPoint(index: i, value: sums[i] / counts[i]));
    }
    return points;
  }

  double? _averageSleep(_DateRange range) {
    final values = _sleepLogs
        .where((log) => _contains(range, log.sleepStart) && log.sleepHours > 0)
        .map((log) => log.sleepHours)
        .toList();
    if (values.isEmpty) {
      return null;
    }
    return values.reduce((a, b) => a + b) / values.length;
  }

  StressLevel? _averageStress(_DateRange range) {
    final values = <double>[];
    for (final emotion in _emotionLogs) {
      final createdAt = emotion.createdAt;
      if (createdAt == null || !_contains(range, createdAt)) {
        continue;
      }
      final intensity = emotion.intensity.clamp(0, 5).toDouble();
      if (_negativeEmotions.contains(emotion.emotionType)) {
        values.add(intensity);
      } else if (emotion.emotionType == 'calm' ||
          emotion.emotionType == 'happy') {
        values.add(math.max(0, 2 - (intensity * 0.4)));
      }
    }
    if (values.isEmpty) {
      return null;
    }
    final average = values.reduce((a, b) => a + b) / values.length;
    if (average < 1.8) {
      return StressLevel.low;
    }
    if (average < 3.4) {
      return StressLevel.medium;
    }
    return StressLevel.high;
  }

  List<String> _labelsFor(_DateRange range) {
    return switch (mode) {
      AnalysisPeriodMode.weekly => const ['월', '화', '수', '목', '금', '토', '일'],
      AnalysisPeriodMode.monthly => const ['1주', '2주', '3주', '4주', '5주'],
      AnalysisPeriodMode.threeMonths => List.generate(3, (index) {
        final date = DateTime(range.start.year, range.start.month + index);
        return '${date.month}월';
      }),
    };
  }

  int? _bucketIndex(_DateRange range, DateTime value, int bucketCount) {
    final date = _dateOnly(value);
    final index = switch (mode) {
      AnalysisPeriodMode.weekly => date.difference(range.start).inDays,
      AnalysisPeriodMode.monthly => math.min(
        ((date.day - 1) / 7).floor(),
        bucketCount - 1,
      ),
      AnalysisPeriodMode.threeMonths =>
        ((date.year - range.start.year) * 12) + date.month - range.start.month,
    };
    return index >= 0 && index < bucketCount ? index : null;
  }

  _DateRange _currentRange() => _rangeFor(_anchorDate);

  _DateRange _rangeFor(DateTime anchor) {
    final date = _dateOnly(anchor);
    return switch (mode) {
      AnalysisPeriodMode.weekly => _DateRange(
        start: _weekStart(date),
        end: _weekStart(date).add(const Duration(days: 6)),
      ),
      AnalysisPeriodMode.monthly => _DateRange(
        start: DateTime(date.year, date.month),
        end: DateTime(date.year, date.month + 1, 0),
      ),
      AnalysisPeriodMode.threeMonths => _DateRange(
        start: DateTime(date.year, date.month - 2),
        end: DateTime(date.year, date.month + 1, 0),
      ),
    };
  }

  DateTime _shiftAnchor(int direction) {
    return switch (mode) {
      AnalysisPeriodMode.weekly => _anchorDate.add(
        Duration(days: direction * 7),
      ),
      AnalysisPeriodMode.monthly => DateTime(
        _anchorDate.year,
        _anchorDate.month + direction,
      ),
      AnalysisPeriodMode.threeMonths => DateTime(
        _anchorDate.year,
        _anchorDate.month + (direction * 3),
      ),
    };
  }

  bool _contains(_DateRange range, DateTime value) {
    final date = _dateOnly(value);
    return !date.isBefore(range.start) && !date.isAfter(range.end);
  }

  DateTime _weekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - DateTime.monday));
  }

  DateTime _today() => _dateOnly(DateTime.now());

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _monthDay(DateTime value) {
    return '${value.month}.${_twoDigits(value.day)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _DateRange {
  const _DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

const _negativeEmotions = {'anxious', 'sad', 'angry', 'irritated', 'tired'};
