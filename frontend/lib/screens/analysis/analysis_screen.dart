import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../state/analysis_controller.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({
    super.key,
    required this.controller,
    this.onOpenCareRecommendations,
  });

  final AnalysisController controller;
  final VoidCallback? onOpenCareRecommendations;

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          return RefreshIndicator(
            color: AppColors.primaryPurple,
            onRefresh: widget.controller.refresh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = (constraints.maxWidth * 0.045)
                    .clamp(16.0, 24.0)
                    .toDouble();
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    14,
                    horizontalPadding,
                    24,
                  ),
                  child: _OuterPanel(
                    child: Column(
                      children: [
                        _PeriodTabBar(
                          selectedMode: widget.controller.mode,
                          onChanged: widget.controller.setMode,
                        ),
                        const SizedBox(height: 26),
                        _DateNavigationRow(
                          title: widget.controller.periodLabel,
                          canGoNext: widget.controller.canGoNext,
                          onPrevious: widget.controller.previousPeriod,
                          onNext: widget.controller.nextPeriod,
                        ),
                        const SizedBox(height: 28),
                        if (widget.controller.loading)
                          const LinearProgressIndicator(
                            minHeight: 3,
                            color: AppColors.primaryPurple,
                            backgroundColor: Color(0xFFEDE5FF),
                          ),
                        if (widget.controller.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          _SoftMessage(text: widget.controller.errorMessage!),
                        ],
                        const SizedBox(height: 18),
                        _SymptomTrendCard(
                          summary: widget.controller.summary,
                          loading: widget.controller.loading,
                        ),
                        const SizedBox(height: 18),
                        _MetricCards(summary: widget.controller.summary),
                        const SizedBox(height: 22),
                        _DownloadReportButton(onTap: _showDownloadNotice),
                        const SizedBox(height: 12),
                        _CareRecommendationButton(
                          onTap: _openCareRecommendations,
                        ),
                        const SizedBox(height: 14),
                        const _DisclaimerText(),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDownloadNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('리포트 다운로드 기능은 준비 중이에요.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openCareRecommendations() {
    final onOpenCareRecommendations = widget.onOpenCareRecommendations;
    if (onOpenCareRecommendations != null) {
      onOpenCareRecommendations();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('맞춤 케어 추천 화면은 리포트 화면에서 확인할 수 있어요.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _OuterPanel extends StatelessWidget {
  const _OuterPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE3D8F7), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepPurple.withValues(alpha: 0.06),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        child: child,
      ),
    );
  }
}

class _PeriodTabBar extends StatelessWidget {
  const _PeriodTabBar({required this.selectedMode, required this.onChanged});

  final AnalysisPeriodMode selectedMode;
  final ValueChanged<AnalysisPeriodMode> onChanged;

  static const _items = [
    _PeriodItem(mode: AnalysisPeriodMode.weekly, label: '주간'),
    _PeriodItem(mode: AnalysisPeriodMode.monthly, label: '월간'),
    _PeriodItem(mode: AnalysisPeriodMode.threeMonths, label: '3개월'),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _items.indexWhere(
      (item) => item.mode == selectedMode,
    );
    return SizedBox(
      height: 94,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / _items.length;
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 13,
                child: Container(height: 1.2, color: const Color(0xFFE0DAEA)),
              ),
              Positioned(
                left: itemWidth * selectedIndex,
                bottom: 13,
                child: Container(
                  width: itemWidth,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.deepPurple,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: _items.map((item) {
                  final selected = item.mode == selectedMode;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(item.mode),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 74,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          border: selected
                              ? Border.all(
                                  color: const Color(0xFFE0D4F6),
                                  width: 1.4,
                                )
                              : null,
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryPurple.withValues(
                                      alpha: 0.11,
                                    ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          style: TextStyle(
                            color: selected
                                ? AppColors.deepPurple
                                : const Color(0xFF4A4A4F),
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PeriodItem {
  const _PeriodItem({required this.mode, required this.label});

  final AnalysisPeriodMode mode;
  final String label;
}

class _DateNavigationRow extends StatelessWidget {
  const _DateNavigationRow({
    required this.title,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final String title;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleArrowButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
        _CircleArrowButton(
          icon: Icons.chevron_right_rounded,
          onTap: canGoNext ? onNext : null,
        ),
      ],
    );
  }
}

class _CircleArrowButton extends StatelessWidget {
  const _CircleArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: enabled ? 5 : 0,
      shadowColor: AppColors.primaryPurple.withValues(alpha: 0.16),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE3D5F9), width: 1.4),
          ),
          child: Icon(
            icon,
            color: enabled ? AppColors.deepPurple : const Color(0xFFBEB7D4),
            size: 42,
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    required this.padding,
    this.borderRadius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFFE5DDF5), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SymptomTrendCard extends StatelessWidget {
  const _SymptomTrendCard({required this.summary, required this.loading});

  final AnalysisSummary summary;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: SizedBox(
        height: 430,
        child: Stack(
          children: [
            const Positioned(
              left: 24,
              top: 34,
              child: Text(
                '증상 변화 추이',
                style: TextStyle(
                  color: Color(0xFF111033),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                  height: 1,
                ),
              ),
            ),
            Positioned(
              right: 24,
              top: 22,
              child: Image.asset(
                AppAssets.analysisChartIcon,
                width: 112,
                height: 112,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 24,
              top: 126,
              child: SymptomTrendChart(
                points: summary.trendPoints,
                xLabels: summary.xLabels,
                minY: 0,
                maxY: 40,
              ),
            ),
            if (!loading && summary.trendPoints.isEmpty)
              const Positioned(
                left: 34,
                right: 34,
                bottom: 116,
                child: _EmptyChartMessage(),
              ),
          ],
        ),
      ),
    );
  }
}

class SymptomTrendChart extends StatelessWidget {
  const SymptomTrendChart({
    super.key,
    required this.points,
    required this.xLabels,
    required this.minY,
    required this.maxY,
  });

  final List<TrendPoint> points;
  final List<String> xLabels;
  final double minY;
  final double maxY;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrendChartPainter(
        points: points,
        xLabels: xLabels,
        minY: minY,
        maxY: maxY,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  const _TrendChartPainter({
    required this.points,
    required this.xLabels,
    required this.minY,
    required this.maxY,
  });

  final List<TrendPoint> points;
  final List<String> xLabels;
  final double minY;
  final double maxY;

  @override
  void paint(Canvas canvas, Size size) {
    final leftPadding = size.width * 0.13;
    final rightPadding = size.width * 0.05;
    const topPadding = 12.0;
    const bottomPadding = 48.0;

    final chartLeft = leftPadding;
    const chartTop = topPadding;
    final chartRight = size.width - rightPadding;
    final chartBottom = size.height - bottomPadding;
    final chartWidth = math.max(1.0, chartRight - chartLeft);
    final chartHeight = math.max(1.0, chartBottom - chartTop);
    final range = math.max(1.0, maxY - minY);

    double yToDy(double value) {
      final ratio = ((value - minY) / range).clamp(0.0, 1.0);
      return chartBottom - (ratio * chartHeight);
    }

    double indexToDx(int index) {
      if (xLabels.length <= 1) {
        return chartLeft + (chartWidth / 2);
      }
      return chartLeft + (chartWidth / (xLabels.length - 1)) * index;
    }

    final dashedLinePaint = Paint()
      ..color = const Color(0xFFCFC3ED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    for (final yValue in const [10, 15, 20, 25, 30, 35]) {
      final y = yToDy(yValue.toDouble());
      if (yValue == 10) {
        canvas.drawLine(
          Offset(chartLeft, y),
          Offset(chartRight, y),
          Paint()
            ..color = const Color(0xFFD7D0E9)
            ..strokeWidth = 1.2,
        );
      } else {
        _drawDashedLine(
          canvas: canvas,
          start: Offset(chartLeft, y),
          end: Offset(chartRight, y),
          paint: dashedLinePaint,
        );
      }
      _drawText(
        canvas,
        '$yValue',
        Offset(chartLeft - 24, y),
        const TextStyle(
          color: Color(0xFF626268),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        anchor: _TextAnchor.centerRight,
      );
    }

    for (var i = 0; i < xLabels.length; i++) {
      _drawText(
        canvas,
        xLabels[i],
        Offset(indexToDx(i), chartBottom + 31),
        const TextStyle(
          color: Color(0xFF444448),
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        anchor: _TextAnchor.center,
      );
    }

    if (points.isEmpty) {
      return;
    }

    final offsets = points
        .map((point) => Offset(indexToDx(point.index), yToDy(point.value)))
        .toList();

    if (offsets.length > 1) {
      final areaPath = Path()
        ..moveTo(offsets.first.dx, chartBottom)
        ..lineTo(offsets.first.dx, offsets.first.dy);
      for (final offset in offsets.skip(1)) {
        areaPath.lineTo(offset.dx, offset.dy);
      }
      areaPath
        ..lineTo(offsets.last.dx, chartBottom)
        ..close();
      canvas.drawPath(
        areaPath,
        Paint()
          ..shader =
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryPurple.withValues(alpha: 0.25),
                  AppColors.primaryPurple.withValues(alpha: 0.10),
                  AppColors.primaryPurple.withValues(alpha: 0),
                ],
              ).createShader(
                Rect.fromLTRB(chartLeft, chartTop, chartRight, chartBottom),
              ),
      );

      final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (final offset in offsets.skip(1)) {
        linePath.lineTo(offset.dx, offset.dy);
      }

      canvas.save();
      canvas.translate(0, 5);
      canvas.drawPath(
        linePath,
        Paint()
          ..color = AppColors.primaryPurple.withValues(alpha: 0.32)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8),
      );
      canvas.restore();

      canvas.drawPath(
        linePath,
        Paint()
          ..shader =
              const LinearGradient(
                colors: [
                  Color(0xFF7D4CF4),
                  Color(0xFF5126D9),
                  Color(0xFF7B45F2),
                ],
              ).createShader(
                Rect.fromLTRB(chartLeft, chartTop, chartRight, chartBottom),
              )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    for (final point in offsets) {
      canvas.drawCircle(
        Offset(point.dx, point.dy + 4),
        9,
        Paint()
          ..color = AppColors.primaryPurple.withValues(alpha: 0.18)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
      );
      canvas.drawCircle(point, 9, Paint()..color = Colors.white);
      canvas.drawCircle(
        point,
        9,
        Paint()
          ..color = AppColors.primaryPurple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
    }
  }

  void _drawDashedLine({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required Paint paint,
  }) {
    const dashWidth = 7.0;
    const dashSpace = 7.0;
    var currentX = start.dx;
    while (currentX < end.dx) {
      canvas.drawLine(
        Offset(currentX, start.dy),
        Offset(math.min(currentX + dashWidth, end.dx), end.dy),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    _TextAnchor anchor = _TextAnchor.topLeft,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final paintOffset = switch (anchor) {
      _TextAnchor.topLeft => offset,
      _TextAnchor.center => Offset(
        offset.dx - (textPainter.width / 2),
        offset.dy - (textPainter.height / 2),
      ),
      _TextAnchor.centerRight => Offset(
        offset.dx - textPainter.width,
        offset.dy - (textPainter.height / 2),
      ),
    };
    textPainter.paint(canvas, paintOffset);
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.xLabels != xLabels ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY;
  }
}

enum _TextAnchor { topLeft, center, centerRight }

class _EmptyChartMessage extends StatelessWidget {
  const _EmptyChartMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7DDFC)),
      ),
      child: const Text(
        '아직 분석할 기록이 부족해요.\n오늘의 컨디션을 기록하면 변화 추이를 확인할 수 있어요.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
      ),
    );
  }
}

class _MetricCards extends StatelessWidget {
  const _MetricCards({required this.summary});

  final AnalysisSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          Expanded(
            child: _StatCard(
              title: '평균 수면 시간',
              imagePath: AppAssets.analysisSleepMoon,
              value: _sleepValue(summary.averageSleepHours),
              valueColor: Colors.black,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: _StatCard(
              title: '평균 스트레스',
              imagePath: AppAssets.analysisStressCalm,
              value: _stressValue(summary.stressLevel),
              valueColor: const Color(0xFFF5A623),
            ),
          ),
        ];
        if (constraints.maxWidth < 340) {
          return Column(
            children: [
              _StatCard(
                title: '평균 수면 시간',
                imagePath: AppAssets.analysisSleepMoon,
                value: _sleepValue(summary.averageSleepHours),
                valueColor: Colors.black,
              ),
              const SizedBox(height: 14),
              _StatCard(
                title: '평균 스트레스',
                imagePath: AppAssets.analysisStressCalm,
                value: _stressValue(summary.stressLevel),
                valueColor: const Color(0xFFF5A623),
              ),
            ],
          );
        }
        return Row(children: cards);
      },
    );
  }

  String _sleepValue(double? hours) {
    if (hours == null) {
      return '기록 없음';
    }
    final minutes = (hours * 60).round();
    return '${minutes ~/ 60}h ${minutes % 60}m';
  }

  String _stressValue(StressLevel? level) {
    return switch (level) {
      StressLevel.low => '낮음',
      StressLevel.medium => '보통',
      StressLevel.high => '높음',
      null => '기록 없음',
    };
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.imagePath,
    required this.value,
    required this.valueColor,
  });

  final String title;
  final String imagePath;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(14, 24, 14, 22),
      borderRadius: 22,
      child: SizedBox(
        height: 240,
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: valueColor,
                  fontSize: value == '기록 없음' ? 26 : 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadReportButton extends StatelessWidget {
  const _DownloadReportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '리포트 다운로드',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Ink(
            height: 82,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF7335F2),
                  Color(0xFF843BFF),
                  Color(0xFF562BE8),
                ],
              ),
              border: Border.all(color: const Color(0xFFC8AFFF), width: 1.6),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF562BE8).withValues(alpha: 0.30),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 30),
                Image.asset(
                  AppAssets.analysisReportDownload,
                  width: 66,
                  height: 66,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 18),
                const Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '리포트 다운로드',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CareRecommendationButton extends StatelessWidget {
  const _CareRecommendationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '맞춤 케어 추천',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            height: 74,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2FF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD8C7FF), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepPurple.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 24),
                Image.asset(
                  AppAssets.aiReportCareHeart,
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '맞춤 케어 추천',
                      style: TextStyle(
                        color: AppColors.deepPurple,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.deepPurple,
                  size: 28,
                ),
                const SizedBox(width: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftMessage extends StatelessWidget {
  const _SoftMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DisclaimerText extends StatelessWidget {
  const _DisclaimerText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '이 분석은 진단이나 치료가 아닌 건강 관리 참고 정보입니다.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
    );
  }
}
