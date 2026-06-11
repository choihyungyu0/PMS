import 'package:flutter_test/flutter_test.dart';
import 'package:more_cycle/core/utils/cycle_calendar_utils.dart';
import 'package:more_cycle/models/cycle.dart';

void main() {
  test('month cells align to a Sunday-start calendar', () {
    final cells = buildMonthCells(DateTime(2026, 6));

    expect(cells.length, 35);
    expect(cells.first, isNull);
    expect(cells[1], DateTime(2026, 6));
    expect(cells[30], DateTime(2026, 6, 30));
  });

  test('cycle day type uses latest cycle and estimated windows', () {
    final cycle = CycleLog(
      id: 1,
      startDate: DateTime(2026, 5, 29),
      endDate: DateTime(2026, 6, 2),
      cycleLength: 28,
    );

    expect(cycleDayType(cycle, DateTime(2026, 5, 30)), CycleDayType.period);
    expect(cycleDayType(cycle, DateTime(2026, 6, 7)), CycleDayType.fertile);
    expect(cycleDayType(cycle, DateTime(2026, 6, 12)), CycleDayType.ovulation);
    expect(cycleDayType(cycle, DateTime(2026, 6, 26)), CycleDayType.expected);
  });

  test('selected date summary stays non-diagnostic', () {
    final cycle = CycleLog(
      id: 1,
      startDate: DateTime(2026, 5, 29),
      endDate: DateTime(2026, 6, 2),
      cycleLength: 28,
    );

    final summary = summarizeCycleDate(cycle, DateTime(2026, 6, 7));

    expect(summary.phaseLabel, '가임기 1일차');
    expect(summary.phaseLabel.contains('확진'), isFalse);
    expect(summary.hasCycleData, isTrue);
  });
}
