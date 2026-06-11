import '../../models/cycle.dart';

enum CycleDayType { normal, period, fertile, ovulation, expected }

class CycleDayInfo {
  const CycleDayInfo({required this.date, required this.type});

  final DateTime date;
  final CycleDayType type;
}

class CycleDateSummary {
  const CycleDateSummary({
    required this.phaseLabel,
    required this.hasCycleData,
  });

  final String phaseLabel;
  final bool hasCycleData;
}

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

List<DateTime?> buildMonthCells(DateTime month) {
  final firstDay = DateTime(month.year, month.month);
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final leadingBlanks = firstDay.weekday % 7;
  final usedCells = leadingBlanks + daysInMonth;
  final totalCells = ((usedCells + 6) ~/ 7) * 7;

  return List<DateTime?>.generate(totalCells, (index) {
    final dayNumber = index - leadingBlanks + 1;
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return null;
    }
    return DateTime(month.year, month.month, dayNumber);
  });
}

CycleDayInfo buildCycleDayInfo(CycleLog? latestCycle, DateTime date) {
  return CycleDayInfo(
    date: dateOnly(date),
    type: cycleDayType(latestCycle, date),
  );
}

CycleDayType cycleDayType(CycleLog? latestCycle, DateTime date) {
  if (latestCycle == null) {
    return CycleDayType.normal;
  }

  final current = dateOnly(date);
  final start = dateOnly(latestCycle.startDate);
  final periodLength = _periodLength(latestCycle);
  final actualPeriodEnd = start.add(Duration(days: periodLength - 1));

  if (_isBetweenInclusive(current, start, actualPeriodEnd)) {
    return CycleDayType.period;
  }

  final cycleLength = latestCycle.cycleLength ?? 28;
  for (final expectedStart in _candidateExpectedStarts(
    start,
    cycleLength,
    current,
  )) {
    final expectedEnd = expectedStart.add(Duration(days: periodLength - 1));
    final ovulationDay = expectedStart.subtract(const Duration(days: 14));
    final fertileStart = ovulationDay.subtract(const Duration(days: 5));

    if (isSameDay(current, ovulationDay)) {
      return CycleDayType.ovulation;
    }
    if (_isBetweenInclusive(current, fertileStart, ovulationDay)) {
      return CycleDayType.fertile;
    }
    if (_isBetweenInclusive(current, expectedStart, expectedEnd)) {
      return CycleDayType.expected;
    }
  }

  return CycleDayType.normal;
}

CycleDateSummary summarizeCycleDate(CycleLog? latestCycle, DateTime date) {
  if (latestCycle == null) {
    return const CycleDateSummary(
      phaseLabel: '생리 주기 기록이 부족해요',
      hasCycleData: false,
    );
  }

  final current = dateOnly(date);
  final start = dateOnly(latestCycle.startDate);
  final periodLength = _periodLength(latestCycle);
  final actualPeriodEnd = start.add(Duration(days: periodLength - 1));
  if (_isBetweenInclusive(current, start, actualPeriodEnd)) {
    return CycleDateSummary(
      phaseLabel: '생리 기간 ${current.difference(start).inDays + 1}일차',
      hasCycleData: true,
    );
  }

  final cycleLength = latestCycle.cycleLength ?? 28;
  for (final expectedStart in _candidateExpectedStarts(
    start,
    cycleLength,
    current,
  )) {
    final expectedEnd = expectedStart.add(Duration(days: periodLength - 1));
    final ovulationDay = expectedStart.subtract(const Duration(days: 14));
    final fertileStart = ovulationDay.subtract(const Duration(days: 5));

    if (isSameDay(current, ovulationDay)) {
      return const CycleDateSummary(phaseLabel: '배란일 예상', hasCycleData: true);
    }
    if (_isBetweenInclusive(current, fertileStart, ovulationDay)) {
      return CycleDateSummary(
        phaseLabel: '가임기 ${current.difference(fertileStart).inDays + 1}일차',
        hasCycleData: true,
      );
    }
    if (_isBetweenInclusive(current, expectedStart, expectedEnd)) {
      return CycleDateSummary(
        phaseLabel: '예정일 ${current.difference(expectedStart).inDays + 1}일차',
        hasCycleData: true,
      );
    }
  }

  return const CycleDateSummary(phaseLabel: '주기 관찰일', hasCycleData: true);
}

int _periodLength(CycleLog cycle) {
  final start = dateOnly(cycle.startDate);
  final end = cycle.endDate == null ? null : dateOnly(cycle.endDate!);
  if (end == null || end.isBefore(start)) {
    return 5;
  }
  return end.difference(start).inDays + 1;
}

List<DateTime> _candidateExpectedStarts(
  DateTime latestStart,
  int cycleLength,
  DateTime targetDate,
) {
  final safeCycleLength = cycleLength.clamp(15, 60).toInt();
  final daysFromStart = targetDate.difference(latestStart).inDays;
  final approximateIndex = (daysFromStart / safeCycleLength).floor();
  final starts = <DateTime>[];

  for (
    var index = approximateIndex - 2;
    index <= approximateIndex + 3;
    index++
  ) {
    if (index < 1) {
      continue;
    }
    starts.add(latestStart.add(Duration(days: safeCycleLength * index)));
  }
  return starts;
}

bool _isBetweenInclusive(DateTime date, DateTime start, DateTime end) {
  return !date.isBefore(start) && !date.isAfter(end);
}
