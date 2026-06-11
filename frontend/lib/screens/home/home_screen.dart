import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/cycle.dart';
import '../../models/health_report.dart';
import '../../models/sleep_log.dart';
import '../../state/auth_controller.dart';
import '../../state/record_controller.dart';
import '../../state/report_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.authController,
    required this.recordController,
    required this.reportController,
    required this.onOpenRecord,
    required this.onOpenReport,
    required this.onOpenMyPage,
  });

  final AuthController authController;
  final RecordController recordController;
  final ReportController reportController;
  final VoidCallback onOpenRecord;
  final VoidCallback onOpenReport;
  final VoidCallback onOpenMyPage;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        authController,
        recordController,
        reportController,
      ]),
      builder: (context, _) {
        final nickname = authController.user?.nickname.trim();
        final displayName = nickname == null || nickname.isEmpty
            ? '사용자'
            : nickname;
        final report = reportController.latestReport;
        final hasPartialError = reportController.errorMessage != null;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFFEFCFF), Color(0xFFF9F5FF)],
              stops: [0, 0.55, 1],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.primaryPurple,
              onRefresh: () async {
                await Future.wait([
                  recordController.loadLatestCycle(),
                  recordController.loadLatestSleep(),
                  reportController.load(),
                ]);
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = (constraints.maxWidth * 0.075)
                      .clamp(22.0, 34.0);
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      18,
                      horizontalPadding,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(
                          onBack: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).maybePop();
                            }
                          },
                          onSetting: onOpenMyPage,
                          onNotification: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('알림 기능은 준비 중이에요.')),
                            );
                          },
                          onCalendar: onOpenRecord,
                        ),
                        const SizedBox(height: 42),
                        Text(
                          '안녕하세요, $displayName님 👋',
                          style: const TextStyle(
                            color: Color(0xFF323337),
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                            height: 1.1,
                          ),
                        ),
                        if (hasPartialError) ...[
                          const SizedBox(height: 12),
                          const Text(
                            '일부 정보를 불러오지 못했어요. 잠시 후 다시 시도해주세요.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ],
                        const SizedBox(height: 42),
                        _HealthSummaryCard(
                          cycle: recordController.latestCycle,
                          report: report,
                          sleep: recordController.latestSleep,
                          onOpenReport: onOpenReport,
                          onOpenRecord: onOpenRecord,
                        ),
                        const SizedBox(height: 18),
                        _TodayMissionCard(
                          mission: _missionFromReport(report),
                          onTap: onOpenRecord,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onBack,
    required this.onSetting,
    required this.onNotification,
    required this.onCalendar,
  });

  final VoidCallback onBack;
  final VoidCallback onSetting;
  final VoidCallback onNotification;
  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: '뒤로가기',
          child: _CircleBackButton(onTap: onBack),
        ),
        const Spacer(),
        Tooltip(
          message: '마이페이지',
          child: _HexagonIconButton(onTap: onSetting),
        ),
        const SizedBox(width: 18),
        Tooltip(
          message: '알림',
          child: _TopIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: onNotification,
          ),
        ),
        const SizedBox(width: 18),
        Tooltip(
          message: '기록',
          child: _TopIconButton(
            icon: Icons.calendar_month_outlined,
            onTap: onCalendar,
          ),
        ),
      ],
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF2F0FA),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox(
          width: 52,
          height: 52,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF25252A),
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: const Color(0xFF555555), size: 32),
        ),
      ),
    );
  }
}

class _HexagonIconButton extends StatelessWidget {
  const _HexagonIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox(
          width: 38,
          height: 38,
          child: Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CustomPaint(painter: _HexagonPainter()),
            ),
          ),
        ),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  const _HexagonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dotPaint = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    final path = Path();

    for (var i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas
      ..drawPath(path, strokePaint)
      ..drawCircle(center, size.width * 0.075, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _HexagonPainter oldDelegate) => false;
}

class _HealthSummaryCard extends StatelessWidget {
  const _HealthSummaryCard({
    required this.cycle,
    required this.report,
    required this.sleep,
    required this.onOpenReport,
    required this.onOpenRecord,
  });

  final CycleLog? cycle;
  final HealthReport? report;
  final SleepLog? sleep;
  final VoidCallback onOpenReport;
  final VoidCallback onOpenRecord;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE0DDEB), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 건강 요약',
            style: TextStyle(
              color: Color(0xFF2D2D32),
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
              height: 1,
            ),
          ),
          const SizedBox(height: 24),
          _CycleStatusPanel(summary: _cycleSummary(cycle)),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE3E0EB), height: 1, thickness: 1),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _MiniHealthCard(
                  height: 108,
                  label: 'PMS 예측',
                  value: _riskLabel(report?.riskLevel),
                  labelColor: const Color(0xFF6C6B6F),
                  valueColor: const Color(0xFFFF8A1F),
                  arrowColor: const Color(0xFFFF9A27),
                  gradientColors: const [Color(0xFFFFF5E8), Color(0xFFFFF8EF)],
                  onTap: onOpenReport,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _MiniHealthCard(
                  height: 108,
                  label: '수면 시간',
                  value: _sleepLabel(sleep),
                  labelColor: const Color(0xFF2D6EBE),
                  valueColor: const Color(0xFF2E79DF),
                  arrowColor: const Color(0xFF74A7EE),
                  gradientColors: const [Color(0xFFEFF6FF), Color(0xFFEAF4FF)],
                  onTap: onOpenRecord,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CycleStatusPanel extends StatelessWidget {
  const _CycleStatusPanel({required this.summary});

  final _CycleSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 148),
      padding: const EdgeInsets.fromLTRB(26, 24, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFF3EAFE), Color(0xFFF4ECFF), Color(0xFFF7F1FF)],
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '생리 주기',
                  style: TextStyle(
                    color: Color(0xFF8C63E8),
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  summary.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF4F2DB8),
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  summary.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5E5E62),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 2,
            child: Icon(
              Icons.close_rounded,
              color: const Color(0xFF7E56DD).withValues(alpha: 0.9),
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniHealthCard extends StatelessWidget {
  const _MiniHealthCard({
    required this.height,
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
    required this.arrowColor,
    required this.gradientColors,
    required this.onTap,
  });

  final double height;
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final Color arrowColor;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          height: height,
          padding: const EdgeInsets.fromLTRB(20, 20, 12, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        value,
                        style: TextStyle(
                          color: valueColor,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: arrowColor, size: 38),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayMissionCard extends StatelessWidget {
  const _TodayMissionCard({required this.mission, required this.onTap});

  final String mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE0DDEB), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 미션',
            style: TextStyle(
              color: Color(0xFF2D2D32),
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
              height: 1,
            ),
          ),
          const SizedBox(height: 24),
          _MissionTile(mission: mission, onTap: onTap),
        ],
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({required this.mission, required this.onTap});

  final String mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          height: 116,
          padding: const EdgeInsets.fromLTRB(24, 20, 18, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFFFEDEE), Color(0xFFFFF1F1), Color(0xFFFFEDED)],
            ),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 82,
                height: 82,
                child: CustomPaint(painter: _MissionIllustrationPainter()),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  mission,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF3A3A3D),
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    height: 1.45,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFF08B91),
                size: 42,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionIllustrationPainter extends CustomPainter {
  const _MissionIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawCircle(
      Offset(w * 0.52, h * 0.50),
      w * 0.44,
      Paint()
        ..color = const Color(0xFFEFEAFA)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(w * 0.48, h * 0.42),
      w * 0.19,
      Paint()
        ..color = const Color(0xFF163D31)
        ..style = PaintingStyle.fill,
    );

    final applePaint = Paint()
      ..color = const Color(0xFFE9433E)
      ..style = PaintingStyle.fill;
    canvas
      ..drawCircle(Offset(w * 0.28, h * 0.62), w * 0.19, applePaint)
      ..drawCircle(Offset(w * 0.40, h * 0.58), w * 0.17, applePaint);

    final leafPath = Path()
      ..moveTo(w * 0.37, h * 0.36)
      ..cubicTo(w * 0.44, h * 0.26, w * 0.53, h * 0.31, w * 0.47, h * 0.42);
    canvas.drawPath(
      leafPath,
      Paint()
        ..color = const Color(0xFF3E8E4E)
        ..style = PaintingStyle.fill,
    );
    canvas.drawLine(
      Offset(w * 0.38, h * 0.42),
      Offset(w * 0.36, h * 0.32),
      Paint()
        ..color = const Color(0xFF7A5132)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    final slicedPaint = Paint()
      ..color = const Color(0xFFFFC27A)
      ..style = PaintingStyle.fill;
    final slicedInnerPaint = Paint()
      ..color = const Color(0xFFFFE0A9)
      ..style = PaintingStyle.fill;
    canvas
      ..drawCircle(Offset(w * 0.58, h * 0.65), w * 0.22, slicedPaint)
      ..drawCircle(Offset(w * 0.58, h * 0.65), w * 0.17, slicedInnerPaint)
      ..drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.58, h * 0.66),
          width: w * 0.035,
          height: h * 0.07,
        ),
        Paint()
          ..color = const Color(0xFF9A5833)
          ..style = PaintingStyle.fill,
      );

    final cupPaint = Paint()
      ..color = const Color(0xFFE7784B)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.58, h * 0.32, w * 0.32, h * 0.22),
        Radius.circular(w * 0.08),
      ),
      cupPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(w * 0.78, h * 0.35, w * 0.20, h * 0.18),
      -math.pi / 2,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFE7784B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MissionIllustrationPainter oldDelegate) {
    return false;
  }
}

class _CycleSummary {
  const _CycleSummary({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

_CycleSummary _cycleSummary(CycleLog? cycle) {
  if (cycle == null) {
    return const _CycleSummary(
      title: '기록이 필요해요',
      subtitle: '생리 시작일을 기록하면 주기 요약을 볼 수 있어요.',
    );
  }

  final today = DateTime.now();
  final currentDay = DateTime(today.year, today.month, today.day);
  final start = DateTime(
    cycle.startDate.year,
    cycle.startDate.month,
    cycle.startDate.day,
  );
  final end = cycle.endDate == null
      ? null
      : DateTime(cycle.endDate!.year, cycle.endDate!.month, cycle.endDate!.day);
  final daysSinceStart = currentDay.difference(start).inDays;

  final inPeriod =
      daysSinceStart >= 0 &&
      (end == null ? daysSinceStart <= 6 : !currentDay.isAfter(end));
  final title = inPeriod
      ? '생리 ${daysSinceStart + 1}일차'
      : daysSinceStart >= 10 && daysSinceStart <= 16
      ? '가임기 ${daysSinceStart - 9}일차'
      : '주기 ${math.max(daysSinceStart + 1, 1)}일차';

  final cycleLength = cycle.cycleLength ?? 28;
  var nextPeriod = start.add(Duration(days: cycleLength));
  while (!nextPeriod.isAfter(currentDay)) {
    nextPeriod = nextPeriod.add(Duration(days: cycleLength));
  }
  final daysUntil = nextPeriod.difference(currentDay).inDays;
  final dday = daysUntil == 0 ? 'D-day' : 'D-$daysUntil';

  return _CycleSummary(
    title: title,
    subtitle: '다음 생리 예정 ${nextPeriod.month}.${nextPeriod.day} ($dday)',
  );
}

String _riskLabel(String? riskLevel) {
  return switch (riskLevel) {
    'high' => '높음',
    'medium' => '보통',
    'low' => '낮음',
    _ => '분석 전',
  };
}

String _sleepLabel(SleepLog? sleep) {
  if (sleep == null || sleep.sleepHours <= 0) {
    return '기록 없음';
  }
  final totalMinutes = (sleep.sleepHours * 60).round();
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return '${hours}h ${minutes}m';
}

String _missionFromReport(HealthReport? report) {
  final tip = report?.careTips.isNotEmpty == true ? report!.careTips.first : '';
  if (tip.contains('수분')) {
    return '오늘은 수분 섭취를\n조금 더 챙겨보세요';
  }
  if (tip.contains('스트레칭')) {
    return '가벼운 스트레칭으로\n긴장을 풀어보세요';
  }
  if (tip.contains('수면') || tip.contains('잠')) {
    return '잠들기 전 화면 사용을\n조금 줄여보세요';
  }
  if (tip.contains('온찜질') || tip.contains('따뜻')) {
    return '따뜻한 차 한 잔으로\n몸을 편안하게';
  }
  return '따뜻한 차 한 잔으로\n몸을 편안하게';
}
