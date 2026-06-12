// ignore_for_file: unused_element

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
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
              colors: [Color(0xFFFFFFFF), Color(0xFFFCF8FF), Color(0xFFF7F0FF)],
              stops: [0, 0.52, 1],
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                right: -78,
                top: 94,
                child: _SoftBackgroundOrb(size: 148),
              ),
              const Positioned(
                left: -96,
                bottom: 126,
                child: _SoftBackgroundOrb(size: 190),
              ),
              SafeArea(
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
                      final horizontalPadding = (constraints.maxWidth * 0.045)
                          .clamp(18.0, 22.0);
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
                                  const SnackBar(
                                    content: Text('알림 기능은 준비 중이에요.'),
                                  ),
                                );
                              },
                              onCalendar: onOpenRecord,
                            ),
                            const SizedBox(height: 44),
                            Text(
                              '안녕하세요, $displayName님 👋',
                              style: const TextStyle(
                                color: Color(0xFF190B2C),
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                                height: 1.08,
                                shadows: [
                                  Shadow(
                                    color: Color(0x337B35E8),
                                    blurRadius: 12,
                                    offset: Offset(0, 3),
                                  ),
                                ],
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
                            const SizedBox(height: 44),
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
            ],
          ),
        );
      },
    );
  }
}

class _SoftBackgroundOrb extends StatelessWidget {
  const _SoftBackgroundOrb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.92),
            const Color(0xFFF3E7FF).withValues(alpha: 0.62),
            const Color(0x00F3E7FF),
          ],
        ),
      ),
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
        const SizedBox(width: 12),
        Tooltip(
          message: '알림',
          child: _TopIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: onNotification,
          ),
        ),
        const SizedBox(width: 12),
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
      color: const Color(0xFFF8F5FF),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2D8F3), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB992E9).withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1F1730),
            size: 28,
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
      color: const Color(0xFFFBFAFF),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      shadowColor: const Color(0xFF8455D6).withValues(alpha: 0.35),
      elevation: 8,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: const Color(0xFF151226), size: 29),
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
      color: const Color(0xFFFBFAFF),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      shadowColor: const Color(0xFF8455D6).withValues(alpha: 0.35),
      elevation: 8,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox(
          width: 52,
          height: 52,
          child: Center(
            child: SizedBox(
              width: 29,
              height: 29,
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
      ..color = const Color(0xFF151226)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dotPaint = Paint()
      ..color = const Color(0xFF151226)
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
    final useReferenceSnapshot =
        cycle == null && report == null && sleep == null;
    final cycleSummary = cycle == null
        ? const _CycleSummary(title: '가임기 5일차', subtitle: '다음 생리 예정 6.24 (D-3)')
        : _cycleSummary(cycle);
    final pmsLabel = useReferenceSnapshot
        ? '보통'
        : _riskLabel(report?.riskLevel);
    final sleepLabel = useReferenceSnapshot ? '6h 30m' : _sleepLabel(sleep);

    return LayoutBuilder(
      builder: (context, constraints) {
        final innerWidth = (constraints.maxWidth - 32).clamp(
          0.0,
          double.infinity,
        );
        final cycleCardHeight = (innerWidth / 2.06).clamp(154.0, 190.0);
        final miniCardWidth = (innerWidth - 12) / 2;
        final miniCardHeight = (miniCardWidth / 1.30).clamp(122.0, 148.0);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE4DDF0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF835AD9).withValues(alpha: 0.10),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    Text(
                      '오늘의 건강 요약',
                      style: TextStyle(
                        color: Color(0xFF121324),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '✦',
                      style: TextStyle(
                        color: Color(0xFFC698F5),
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _CycleStatusPanel(summary: cycleSummary, height: cycleCardHeight),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MiniHealthCard(
                      height: miniCardHeight,
                      label: 'PMS 예측',
                      value: pmsLabel,
                      labelColor: const Color(0xFF17151C),
                      valueColor: const Color(0xFFFF8A1F),
                      arrowColor: const Color(0xFFFF9A27),
                      borderColor: const Color(0xFFF5D8C8),
                      decoration: _MiniDecoration.pms,
                      gradientColors: const [
                        Color(0xFFFFFCF8),
                        Color(0xFFFFF0E4),
                      ],
                      onTap: onOpenReport,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniHealthCard(
                      height: miniCardHeight,
                      label: '수면 시간',
                      value: sleepLabel,
                      labelColor: const Color(0xFF2D6EBE),
                      valueColor: const Color(0xFF2E79DF),
                      arrowColor: const Color(0xFF74A7EE),
                      borderColor: const Color(0xFFD2DDF4),
                      decoration: _MiniDecoration.sleep,
                      gradientColors: const [
                        Color(0xFFFBFDFF),
                        Color(0xFFEAF4FF),
                      ],
                      onTap: onOpenRecord,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CycleStatusPanel extends StatelessWidget {
  const _CycleStatusPanel({required this.summary, required this.height});

  final _CycleSummary summary;
  final double height;

  @override
  Widget build(BuildContext context) {
    final titleFontSize = summary.isPlaceholder ? 31.0 : 34.0;
    final ringSize = (height * 0.64).clamp(96.0, 116.0);
    final textRightInset = ringSize + 38;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFCF8FF), Color(0xFFF2E6FF), Color(0xFFEEDFFF)],
        ),
        border: Border.all(color: const Color(0xFFE5CFFF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9864E9).withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                AppAssets.homeCycleCardBg,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          Positioned(
            right: 24,
            top: height * 0.16,
            child: SizedBox(
              width: ringSize,
              height: ringSize,
              child: const CustomPaint(painter: _CycleRingPainter()),
            ),
          ),
          Positioned(
            left: 24,
            top: 22,
            right: textRightInset,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '생리 주기',
                  style: TextStyle(
                    color: Color(0xFF843CF0),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    height: 1,
                  ),
                ),
                SizedBox(height: height * 0.04),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    summary.title,
                    maxLines: 1,
                    style: TextStyle(
                      color: const Color(0xFF5524B7),
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                      height: 1,
                      shadows: const [
                        Shadow(
                          color: Color(0x339C63F2),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * 0.11),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    summary.subtitle,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color(0xFF15151D),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            top: 10,
            child: Icon(
              Icons.close_rounded,
              color: const Color(0xFF7E56DD).withValues(alpha: 0.9),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleRingPainter extends CustomPainter {
  const _CycleRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.36;
    final shadowPaint = Paint()
      ..color = const Color(0xFF7B35E8).withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center.translate(0, 7), radius, shadowPaint);

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFBF7FF);
    canvas.drawCircle(center, radius, basePaint);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [
          Color(0xFFEBCBFF),
          Color(0xFFBC6FFF),
          Color(0xFF7C35F1),
          Color(0xFFEBCBFF),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.42,
      false,
      arcPaint,
    );

    final shinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.72);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + size.width * 0.09),
      -math.pi * 0.65,
      math.pi * 0.48,
      false,
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CycleRingPainter oldDelegate) {
    return false;
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
    required this.borderColor,
    required this.decoration,
    required this.gradientColors,
    required this.onTap,
  });

  final double height;
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final Color arrowColor;
  final Color borderColor;
  final _MiniDecoration decoration;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPlaceholderValue = value.contains('전') || value.contains('없음');
    final valueFontSize = isPlaceholderValue ? 27.0 : 34.0;
    final valueTop = (height * 0.43).clamp(48.0, 54.0);
    final arrowSize = (height * 0.34).clamp(42.0, 46.0);
    final arrowTop = (height * 0.42).clamp(50.0, 54.0);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          height: height,
          padding: const EdgeInsets.fromLTRB(18, 20, 14, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.24),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    decoration.assetPath,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    height: 1,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 50,
                top: valueTop,
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                      height: 1,
                      shadows: [
                        Shadow(
                          color: valueColor.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                top: arrowTop,
                child: Container(
                  width: arrowSize,
                  height: arrowSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.72),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: arrowColor.withValues(alpha: 0.14),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: arrowColor,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MiniDecoration {
  pms(AppAssets.homePmsCardBg),
  sleep(AppAssets.homeSleepCardBg);

  const _MiniDecoration(this.assetPath);

  final String assetPath;
}

class _TodayMissionCard extends StatelessWidget {
  const _TodayMissionCard({required this.mission, required this.onTap});

  final String mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE4DDF0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF835AD9).withValues(alpha: 0.09),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Text(
                  '오늘의 미션',
                  style: TextStyle(
                    color: Color(0xFF121324),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    height: 1,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  '✦',
                  style: TextStyle(
                    color: Color(0xFFF178A0),
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
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
          height: 142,
          padding: const EdgeInsets.fromLTRB(16, 18, 12, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF6BDC8), width: 1.1),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFFFF7F8), Color(0xFFFFEDEF), Color(0xFFFFF5F6)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: -2,
                bottom: 10,
                child: SizedBox(
                  width: 156,
                  height: 104,
                  child: Image.asset(
                    AppAssets.homeMissionTea,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              Positioned(
                left: 168,
                top: 31,
                right: 52,
                child: Text(
                  mission,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF3A2721),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    height: 1.35,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 38,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.58),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF7D95).withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFE95478),
                    size: 36,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CycleSummary {
  const _CycleSummary({
    required this.title,
    required this.subtitle,
    this.isPlaceholder = false,
  });

  final String title;
  final String subtitle;
  final bool isPlaceholder;
}

_CycleSummary _cycleSummary(CycleLog? cycle) {
  if (cycle == null) {
    return const _CycleSummary(
      title: '기록 전',
      subtitle: '생리 시작일을 기록하면 주기 요약을 볼 수 있어요.',
      isPlaceholder: true,
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
    return '기록 전';
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
