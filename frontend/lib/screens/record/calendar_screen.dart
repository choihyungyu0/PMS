import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/cycle_calendar_utils.dart';
import '../../models/cycle.dart';
import '../../models/health_report.dart';
import '../../state/record_controller.dart';
import '../../state/report_controller.dart';
import 'record_complete_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    required this.recordController,
    required this.reportController,
    required this.initialSelectedDate,
    this.completedRecordDate,
    this.onOpenReport,
    this.onComplete,
  });

  final RecordController recordController;
  final ReportController reportController;
  final DateTime initialSelectedDate;
  final DateTime? completedRecordDate;
  final VoidCallback? onOpenReport;
  final VoidCallback? onComplete;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;
  Set<String> _unsupportedRecordDates = const {};

  @override
  void initState() {
    super.initState();
    _selectedDate = dateOnly(widget.initialSelectedDate);
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _load();
  }

  Future<void> _load() async {
    await Future.wait([
      widget.recordController.loadCalendarData(),
      widget.reportController.load(),
      _loadUnsupportedRecordDates(),
    ]);
  }

  Future<void> _loadUnsupportedRecordDates() async {
    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getString(
      RecordController.unsupportedBodySymptomsKey,
    );
    final dates = <String>{};
    if (storedValue != null && storedValue.isNotEmpty) {
      try {
        final decoded = jsonDecode(storedValue);
        if (decoded is List) {
          for (final item in decoded.whereType<Map>()) {
            final date = item['record_date']?.toString();
            if (date != null && date.isNotEmpty) {
              dates.add(date);
            }
          }
        }
      } catch (_) {
        // Local unsupported symptom history is optional for the calendar.
      }
    }
    if (!mounted) {
      return;
    }
    setState(() => _unsupportedRecordDates = dates);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.recordController,
        widget.reportController,
      ]),
      builder: (context, _) {
        final loading =
            widget.recordController.calendarLoading ||
            widget.reportController.loading;

        return Scaffold(
          backgroundColor: const Color(0xFFFCFAFF),
          body: Stack(
            children: [
              const Positioned.fill(child: _SoftBackground()),
              SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  color: AppColors.primaryPurple,
                  onRefresh: _load,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final horizontalPadding = (constraints.maxWidth * 0.030)
                          .clamp(12.0, 22.0)
                          .toDouble();
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          18,
                          horizontalPadding,
                          28,
                        ),
                        child: Column(
                          children: [
                            _Header(
                              month: _visibleMonth,
                              onBack: _handleBack,
                              onHelp: _showHelpDialog,
                            ),
                            const SizedBox(height: 22),
                            if (loading)
                              const LinearProgressIndicator(
                                minHeight: 3,
                                color: AppColors.primaryPurple,
                                backgroundColor: Color(0xFFEDE7FF),
                              ),
                            if (loading) const SizedBox(height: 14),
                            _CalendarCard(
                              visibleMonth: _visibleMonth,
                              selectedDate: _selectedDate,
                              latestCycle: widget.recordController.latestCycle,
                              onDateSelected: (date) {
                                setState(() => _selectedDate = dateOnly(date));
                              },
                            ),
                            if (widget.recordController.calendarErrorMessage !=
                                null) ...[
                              const SizedBox(height: 12),
                              _SoftNotice(
                                message: widget
                                    .recordController
                                    .calendarErrorMessage!,
                              ),
                            ],
                            const SizedBox(height: 20),
                            _DetailPanel(
                              selectedDate: _selectedDate,
                              phaseLabel: summarizeCycleDate(
                                widget.recordController.latestCycle,
                                _selectedDate,
                              ).phaseLabel,
                              pmsLabel: _pmsLabel(
                                widget.reportController.latestReport,
                              ),
                              conditionLabel: _conditionLabel(_selectedDate),
                              hasConditionRecord: _hasConditionRecord(
                                _selectedDate,
                              ),
                              onPhaseTap: _showPhaseDialog,
                              onPmsTap: _openReport,
                              onConditionTap: _handleConditionRowTap,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _BottomCompleteBar(onTap: _openCompleteScreen),
        );
      },
    );
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _openReport() {
    final onOpenReport = widget.onOpenReport;
    if (onOpenReport == null) {
      return;
    }
    onOpenReport();
    _handleBack();
  }

  void _handleConditionRowTap() {
    if (_hasConditionRecord(_selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미 기록이 완료되었어요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _handleBack();
  }

  void _openCompleteScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => RecordCompleteScreen(
          onGoHome: () {
            widget.recordController.loadLatestCycle();
            widget.recordController.loadLatestSleep();
            widget.onComplete?.call();
          },
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캘린더 안내'),
        content: const Text(
          '생리 기간: 입력한 생리 기록\n'
          '가임기: 생리주기 기반 예상 기간\n'
          '배란일: 생리주기 기반 예상일\n'
          '예정일: 다음 생리 예상일\n\n'
          '캘린더 예측은 진단이나 임신 목적이 아닌 건강관리 참고 정보입니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showPhaseDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('주기 예상 안내'),
        content: const Text(
          '가임기와 배란일은 입력한 생리주기를 바탕으로 계산한 예상 기간입니다. '
          '진단이나 치료, 임신 여부 판단을 대신하지 않아요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  bool _hasConditionRecord(DateTime date) {
    final completedRecordDate = widget.completedRecordDate;
    if (completedRecordDate != null && isSameDay(completedRecordDate, date)) {
      return true;
    }
    final key = _dateKey(date);
    if (_unsupportedRecordDates.contains(key)) {
      return true;
    }
    final painLogged = widget.recordController.painLogs.any(
      (log) =>
          log.createdAt != null && isSameDay(log.createdAt!.toLocal(), date),
    );
    final emotionLogged = widget.recordController.emotionLogs.any(
      (log) =>
          log.createdAt != null && isSameDay(log.createdAt!.toLocal(), date),
    );
    final sleepLogged = widget.recordController.sleepLogs.any(
      (log) => isSameDay(log.sleepStart.toLocal(), date),
    );
    return painLogged || emotionLogged || sleepLogged;
  }

  String _conditionLabel(DateTime date) {
    final hasRecord = _hasConditionRecord(date);
    final today = dateOnly(DateTime.now());
    if (hasRecord && isSameDay(date, today)) {
      return '오늘 컨디션 기록 완료';
    }
    if (hasRecord) {
      return '컨디션 기록 완료';
    }
    if (isSameDay(date, today)) {
      return '오늘 컨디션 기록하기';
    }
    return '컨디션 기록 없음';
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.month,
    required this.onBack,
    required this.onHelp,
  });

  final DateTime month;
  final VoidCallback onBack;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _HeaderCircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              tooltip: '뒤로가기',
              onTap: onBack,
            ),
          ),
          Text(
            '${month.year}년 ${month.month}월',
            style: const TextStyle(
              color: Color(0xFF161129),
              fontSize: 27,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              height: 1,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _HeaderCircleButton(
              icon: Icons.question_mark_rounded,
              tooltip: '캘린더 안내',
              onTap: onHelp,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.96),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Icon(icon, color: const Color(0xFF5B2DF2), size: 31),
          ),
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.visibleMonth,
    required this.selectedDate,
    required this.latestCycle,
    required this.onDateSelected,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final CycleLog? latestCycle;
  final ValueChanged<DateTime> onDateSelected;

  static const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    final cells = buildMonthCells(visibleMonth);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5E0F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: _weekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: Color(0xFF656176),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 48,
              crossAxisSpacing: 4,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final date = cells[index];
              if (date == null) {
                return const SizedBox.shrink();
              }
              final info = buildCycleDayInfo(latestCycle, date);
              return _DayCell(
                date: date,
                type: info.type,
                selected: isSameDay(date, selectedDate),
                onTap: () => onDateSelected(date),
              );
            },
          ),
          const SizedBox(height: 16),
          const _Legend(),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final CycleDayType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _dayStyle(type, selected);
    return Semantics(
      button: true,
      selected: selected,
      label: '${date.month}월 ${date.day}일',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: style.backgroundColor,
                border: Border.all(
                  color: style.borderColor,
                  width: selected && type != CycleDayType.ovulation ? 1.8 : 0,
                ),
                boxShadow: style.shadow,
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: style.textColor,
                    fontSize: 20,
                    fontWeight: selected || type != CycleDayType.normal
                        ? FontWeight.w900
                        : FontWeight.w600,
                    letterSpacing: 0,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 7,
      alignment: WrapAlignment.center,
      children: const [
        _LegendChip(label: '생리 기간', color: Color(0xFFF97792)),
        _LegendChip(label: '가임기', color: Color(0xFF4FD6B0)),
        _LegendChip(label: '배란일', color: Color(0xFF6D4AFF)),
        _LegendChip(label: '예정일', color: Color(0xFFC8B4FF)),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9FE),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF242133),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.selectedDate,
    required this.phaseLabel,
    required this.pmsLabel,
    required this.conditionLabel,
    required this.hasConditionRecord,
    required this.onPhaseTap,
    required this.onPmsTap,
    required this.onConditionTap,
  });

  final DateTime selectedDate;
  final String phaseLabel;
  final String pmsLabel;
  final String conditionLabel;
  final bool hasConditionRecord;
  final VoidCallback onPhaseTap;
  final VoidCallback onPmsTap;
  final VoidCallback onConditionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F3FF), Color(0xFFF0E8FF)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE1D4FF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.10),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatSelectedDate(selectedDate),
                  style: const TextStyle(
                    color: Color(0xFF151029),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    height: 1,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF4E4866),
                size: 34,
              ),
            ],
          ),
          const SizedBox(height: 22),
          _DetailRow(
            assetPath: AppAssets.calendarFertileCycle,
            label: phaseLabel,
            onTap: onPhaseTap,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            assetPath: AppAssets.calendarPmsBell,
            label: pmsLabel,
            onTap: onPmsTap,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            assetPath: AppAssets.calendarConditionDone,
            label: conditionLabel,
            onTap: onConditionTap,
            muted: !hasConditionRecord,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.assetPath,
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  final String assetPath;
  final String label;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          height: 90,
          padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              Opacity(
                opacity: muted ? 0.68 : 1,
                child: Image.asset(
                  assetPath,
                  width: 66,
                  height: 66,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: muted
                        ? AppColors.textSecondary
                        : const Color(0xFF171425),
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    height: 1.15,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFC6BEE2),
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftNotice extends StatelessWidget {
  const _SoftNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE3B8)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF6E5A3D),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
      ),
    );
  }
}

class _BottomCompleteBar extends StatelessWidget {
  const _BottomCompleteBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF5EEFF).withValues(alpha: 0.96),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 14),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Ink(
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF7A35F4),
                      AppColors.primaryPurple,
                      AppColors.deepPurple,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.24),
                      blurRadius: 20,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '완료하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftBackground extends StatelessWidget {
  const _SoftBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFFCFAFF), Color(0xFFF5EEFF)],
        ),
      ),
      child: CustomPaint(painter: _BottomWavePainter()),
    );
  }
}

class _BottomWavePainter extends CustomPainter {
  const _BottomWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8D9FF).withValues(alpha: 0.42)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * 0.87)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.80,
        size.width * 0.34,
        size.height * 0.98,
        size.width * 0.56,
        size.height * 0.90,
      )
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.84,
        size.width * 0.86,
        size.height * 0.88,
        size.width,
        size.height * 0.82,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BottomWavePainter oldDelegate) => false;
}

class _DayStyle {
  const _DayStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.shadow,
  });

  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final List<BoxShadow> shadow;
}

_DayStyle _dayStyle(CycleDayType type, bool selected) {
  const transparent = Colors.transparent;
  final selectedBorder = selected ? AppColors.primaryPurple : transparent;
  return switch (type) {
    CycleDayType.period => _DayStyle(
      backgroundColor: const Color(0xFFFFE3EC),
      textColor: const Color(0xFFF05D7B),
      borderColor: selectedBorder,
      shadow: const [],
    ),
    CycleDayType.fertile => _DayStyle(
      backgroundColor: const Color(0xFFE7FFF7),
      textColor: const Color(0xFF23B88F),
      borderColor: selectedBorder,
      shadow: const [],
    ),
    CycleDayType.ovulation => _DayStyle(
      backgroundColor: AppColors.primaryPurple,
      textColor: Colors.white,
      borderColor: transparent,
      shadow: [
        BoxShadow(
          color: AppColors.primaryPurple.withValues(alpha: 0.28),
          blurRadius: selected ? 18 : 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    CycleDayType.expected => _DayStyle(
      backgroundColor: const Color(0xFFEEE8FF),
      textColor: AppColors.primaryPurple,
      borderColor: selectedBorder,
      shadow: const [],
    ),
    CycleDayType.normal => _DayStyle(
      backgroundColor: selected ? Colors.white : transparent,
      textColor: selected ? AppColors.primaryPurple : const Color(0xFF3C3948),
      borderColor: selectedBorder,
      shadow: const [],
    ),
  };
}

String _pmsLabel(HealthReport? report) {
  if (report == null) {
    return 'PMS 분석 전';
  }
  return 'PMS 예측 ${_riskLabel(report.riskLevel)}';
}

String _riskLabel(String riskLevel) {
  return switch (riskLevel) {
    'high' => '높음',
    'medium' => '보통',
    _ => '낮음',
  };
}

String _formatSelectedDate(DateTime date) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  return '${date.month}월 ${date.day}일 (${weekdays[date.weekday - 1]})';
}
