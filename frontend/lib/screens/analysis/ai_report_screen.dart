import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../models/health_report.dart';
import '../../state/analysis_controller.dart';
import '../../state/report_controller.dart';
import '../../widgets/loading_view.dart';
import 'analysis_screen.dart';

class AiReportScreen extends StatefulWidget {
  const AiReportScreen({
    super.key,
    required this.reportController,
    required this.analysisController,
  });

  final ReportController reportController;
  final AnalysisController analysisController;

  @override
  State<AiReportScreen> createState() => _AiReportScreenState();
}

class _AiReportScreenState extends State<AiReportScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await Future.wait([
      widget.reportController.load(),
      widget.analysisController.load(),
    ]);
  }

  Future<void> _generateReport() async {
    final success = await widget.reportController.generate();
    if (!mounted) {
      return;
    }
    if (success) {
      await widget.analysisController.refresh();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('건강 리포트를 생성했어요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.reportController.errorMessage ??
              '건강 리포트 생성에 실패했어요. 기록을 입력한 뒤 다시 시도해주세요.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openDetail() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnalysisScreen(controller: widget.analysisController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.reportController,
        widget.analysisController,
      ]),
      builder: (context, _) {
        final report = widget.reportController.latestReport;
        final isInitialLoading =
            widget.reportController.loading && report == null;

        if (isInitialLoading) {
          return const LoadingView(message: 'AI 분석 리포트를 불러오는 중이에요.');
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFFFFEFF), Color(0xFFFDF9FF)],
            ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primaryPurple,
              onRefresh: _load,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = (constraints.maxWidth * 0.055)
                      .clamp(18.0, 30.0)
                      .toDouble();

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      28,
                      horizontalPadding,
                      28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _ReportHeader(),
                        const SizedBox(height: 30),
                        if (widget.reportController.errorMessage != null &&
                            report == null)
                          _SoftMessage(
                            message: '리포트를 불러오지 못했어요. 잠시 후 다시 시도해주세요.',
                            onRetry: _load,
                          )
                        else if (report == null)
                          _EmptyReportCard(
                            loading: widget.reportController.loading,
                            onGenerate: _generateReport,
                          )
                        else ...[
                          if (widget.analysisController.loading)
                            const LinearProgressIndicator(
                              minHeight: 3,
                              color: AppColors.primaryPurple,
                              backgroundColor: Color(0xFFEDE5FF),
                            ),
                          if (widget.analysisController.loading)
                            const SizedBox(height: 18),
                          _PmsPredictionCard(report: report),
                          const SizedBox(height: 22),
                          _MainChangeCard(
                            summary: widget.analysisController.summary,
                            report: report,
                          ),
                          const SizedBox(height: 22),
                          _AiCareCard(report: report),
                          const SizedBox(height: 18),
                          _DisclaimerText(
                            text: report.disclaimer.isEmpty
                                ? _shortDisclaimer
                                : report.disclaimer,
                          ),
                          const SizedBox(height: 26),
                          _DetailReportButton(onTap: _openDetail),
                        ],
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

class _ReportHeader extends StatelessWidget {
  const _ReportHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 106,
          height: 106,
          child: Image.asset(AppAssets.aiReportAvatar, fit: BoxFit.contain),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'AI 분석 리포트',
                      style: TextStyle(
                        color: Color(0xFF121033),
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        height: 1.05,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '이번 주 건강 패턴 분석 결과예요.',
                    maxLines: 2,
                    style: TextStyle(
                      color: Color(0xFF3D3D42),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 8,
                top: -10,
                child: _Sparkle(size: 16, color: const Color(0xFFEDE5FF)),
              ),
              Positioned(
                right: -6,
                top: 44,
                child: _Sparkle(size: 21, color: const Color(0xFFA17AF8)),
              ),
              const Positioned(
                right: 24,
                bottom: -18,
                child: SizedBox(
                  width: 98,
                  height: 20,
                  child: CustomPaint(painter: _HeaderUnderlinePainter()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6DDF8), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PmsPredictionCard extends StatelessWidget {
  const _PmsPredictionCard({required this.report});

  final HealthReport report;

  @override
  Widget build(BuildContext context) {
    final risk = _riskPresentation(report);
    return _GlassCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 220,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 24,
              top: 32,
              right: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PMS 예측',
                    style: TextStyle(
                      color: Color(0xFF121033),
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 36),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${risk.label} (${risk.score10}/10)',
                      style: TextStyle(
                        color: risk.color,
                        fontSize: 39,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 120,
              bottom: 30,
              child: Text(
                _shortSummary(report),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF3F3F45),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                  height: 1.35,
                ),
              ),
            ),
            Positioned(
              right: -4,
              top: 28,
              child: Image.asset(
                AppAssets.aiReportBellHeart,
                width: 160,
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              right: -22,
              bottom: -8,
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF0E8FF).withValues(alpha: 0.75),
                ),
              ),
            ),
            Positioned(
              right: 42,
              bottom: 11,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF6F0FF).withValues(alpha: 0.8),
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 84,
              child: _Sparkle(size: 22, color: const Color(0xFF9C73F3)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainChangeCard extends StatelessWidget {
  const _MainChangeCard({required this.summary, required this.report});

  final AnalysisSummary summary;
  final HealthReport report;

  @override
  Widget build(BuildContext context) {
    final rows = _changeRows(summary, report);
    return _GlassCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 298,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 24,
              top: 24,
              child: Image.asset(
                AppAssets.aiReportChangeIcon,
                width: 82,
                height: 82,
                fit: BoxFit.contain,
              ),
            ),
            const Positioned(
              left: 126,
              top: 50,
              right: 18,
              child: Text(
                '주요 변화',
                style: TextStyle(
                  color: Color(0xFF121033),
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                  height: 1,
                ),
              ),
            ),
            Positioned(
              left: 26,
              top: 126,
              right: 150,
              child: Column(
                children: rows
                    .map(
                      (row) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _ChangeMetricRow(icon: row.icon, text: row.text),
                      ),
                    )
                    .toList(),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 12,
              child: Image.asset(
                AppAssets.aiReportGrowthGraph,
                width: 178,
                height: 190,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangeMetricRow extends StatelessWidget {
  const _ChangeMetricRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF9E79FF), Color(0xFF6B35F2)],
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF2E2E35),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _AiCareCard extends StatelessWidget {
  const _AiCareCard({required this.report});

  final HealthReport report;

  @override
  Widget build(BuildContext context) {
    final tips = _careTips(report);
    return _GlassCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 180,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 18,
              top: 20,
              child: Image.asset(
                AppAssets.aiReportCareHeart,
                width: 150,
                height: 135,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 166,
              top: 28,
              child: _Sparkle(size: 12, color: const Color(0xFFE3D5FF)),
            ),
            const Positioned(
              left: 184,
              top: 36,
              right: 18,
              child: Text(
                'AI 추천 케어',
                style: TextStyle(
                  color: Color(0xFF121033),
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                  height: 1,
                ),
              ),
            ),
            Positioned(
              left: 184,
              top: 84,
              right: 18,
              child: Column(
                children: tips
                    .take(2)
                    .map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _CareCheckRow(text: tip),
                      ),
                    )
                    .toList(),
              ),
            ),
            Positioned(
              left: 24,
              top: 22,
              child: _Sparkle(size: 19, color: const Color(0xFFA17AF8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareCheckRow extends StatelessWidget {
  const _CareCheckRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          AppAssets.aiReportCheck,
          width: 30,
          height: 30,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF2D2D32),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailReportButton extends StatelessWidget {
  const _DetailReportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '상세 리포트 보기',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(27),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(27),
          child: Ink(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF6E35F2),
                  Color(0xFFA13BFF),
                  Color(0xFF592BEB),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B35F2).withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFC4A9FF).withValues(alpha: 0.65),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 26),
                Image.asset(
                  AppAssets.aiReportDocument,
                  width: 54,
                  height: 54,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '상세 리포트 보기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 44,
                ),
                const SizedBox(width: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyReportCard extends StatelessWidget {
  const _EmptyReportCard({required this.loading, required this.onGenerate});

  final bool loading;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
      child: Column(
        children: [
          Image.asset(
            AppAssets.aiReportDocument,
            width: 92,
            height: 92,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          const Text(
            '아직 생성된 리포트가 없어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF121033),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '오늘의 컨디션을 기록하고 건강 리포트를 생성해보세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          _GenerateReportButton(loading: loading, onTap: onGenerate),
          const SizedBox(height: 18),
          const _DisclaimerText(text: _shortDisclaimer),
        ],
      ),
    );
  }
}

class _GenerateReportButton extends StatelessWidget {
  const _GenerateReportButton({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton(
        onPressed: loading ? null : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          disabledBackgroundColor: const Color(0xFFC8B8F4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : const Text(
                '건강 리포트 생성하기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}

class _SoftMessage extends StatelessWidget {
  const _SoftMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '확인이 필요해요',
            style: TextStyle(
              color: Color(0xFF121033),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerText extends StatelessWidget {
  const _DisclaimerText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.45,
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SparklePainter(color: color)),
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final path = Path();

    for (var i = 0; i < 8; i++) {
      final angle = -3.1415926535 / 2 + i * 3.1415926535 / 4;
      final currentRadius = i.isEven ? radius : radius * 0.22;
      final x = center.dx + currentRadius * _cos(angle);
      final y = center.dy + currentRadius * _sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _HeaderUnderlinePainter extends CustomPainter {
  const _HeaderUnderlinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9A72F5).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.02, size.height * 0.72)
      ..cubicTo(
        size.width * 0.27,
        size.height * 0.22,
        size.width * 0.72,
        size.height * 0.28,
        size.width * 0.98,
        size.height * 0.63,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeaderUnderlinePainter oldDelegate) => false;
}

// Kept temporarily as a fallback detail layout while the next report screen
// is routed through AnalysisScreen.
// ignore: unused_element
class _ReportDetailScreen extends StatelessWidget {
  const _ReportDetailScreen({required this.report});

  final HealthReport report;

  @override
  Widget build(BuildContext context) {
    final risk = _riskPresentation(report);
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF121033),
        title: const Text(
          '상세 리포트',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailScoreCard(report: report, risk: risk),
              const SizedBox(height: 16),
              _DetailSection(title: '건강 요약', items: [report.summary]),
              const SizedBox(height: 16),
              _DetailSection(title: '주요 요인', items: report.mainFactors),
              const SizedBox(height: 16),
              _DetailSection(title: '추천 케어', items: _careTips(report)),
              const SizedBox(height: 18),
              _DisclaimerText(
                text: report.disclaimer.isEmpty
                    ? _fullDisclaimer
                    : report.disclaimer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailScoreCard extends StatelessWidget {
  const _DetailScoreCard({required this.report, required this.risk});

  final HealthReport report;
  final _RiskPresentation risk;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Row(
        children: [
          Image.asset(
            AppAssets.aiReportDocument,
            width: 72,
            height: 72,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PMS 위험도 참고 점수',
                  style: TextStyle(
                    color: Color(0xFF121033),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${risk.label} ${report.pmsScore}/100',
                  style: TextStyle(
                    color: risk.color,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '건강 점수 ${report.healthScore}/100 · 신뢰도 ${_confidenceLabel(report.confidence)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.where((item) => item.trim().isNotEmpty).toList();
    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF121033),
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (visibleItems.isEmpty)
            const Text(
              '표시할 기록이 아직 부족해요.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            )
          else
            ...visibleItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryPurple,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: Color(0xFF33333A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChangeRowData {
  const _ChangeRowData({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

class _RiskPresentation {
  const _RiskPresentation({
    required this.label,
    required this.score10,
    required this.color,
  });

  final String label;
  final int score10;
  final Color color;
}

_RiskPresentation _riskPresentation(HealthReport report) {
  final score10 = (report.pmsScore / 10).round().clamp(0, 10).toInt();
  return switch (report.riskLevel) {
    'high' => _RiskPresentation(
      label: '높음',
      score10: score10,
      color: const Color(0xFFE87522),
    ),
    'medium' => _RiskPresentation(
      label: '보통',
      score10: score10,
      color: const Color(0xFFFF7A00),
    ),
    _ => _RiskPresentation(
      label: '낮음',
      score10: score10,
      color: AppColors.primaryPurple,
    ),
  };
}

String _shortSummary(HealthReport report) {
  final summary = report.summary.trim();
  if (summary.isNotEmpty) {
    return summary;
  }
  return switch (report.riskLevel) {
    'high' => '최근 기록에서 컨디션 변화가 높게 나타났어요. 증상이 지속되면 의료진과 상담해보세요.',
    'medium' => '평소보다 컨디션 변화가 나타날 수 있어요.',
    _ => '최근 기록 기준 PMS 위험도는 낮은 편이에요.',
  };
}

List<_ChangeRowData> _changeRows(AnalysisSummary summary, HealthReport report) {
  final rows = <_ChangeRowData>[];
  if (summary.averageSleepHours != null) {
    rows.add(
      _ChangeRowData(
        icon: Icons.dark_mode_rounded,
        text: '수면 시간 평균 ${_formatHours(summary.averageSleepHours!)}',
      ),
    );
  }
  if (summary.stressLevel != null) {
    rows.add(
      _ChangeRowData(
        icon: Icons.flash_on_rounded,
        text: '스트레스 지수 ${_stressLabel(summary.stressLevel!)}',
      ),
    );
  }
  if (summary.trendPoints.isNotEmpty) {
    final average =
        summary.trendPoints
            .map((point) => point.value)
            .reduce((a, b) => a + b) /
        summary.trendPoints.length;
    rows.add(
      _ChangeRowData(
        icon: Icons.battery_charging_full_rounded,
        text: '증상 변화 지수 평균 ${average.round()}',
      ),
    );
  }

  for (final factor in report.mainFactors) {
    if (rows.length >= 3) {
      break;
    }
    rows.add(_ChangeRowData(icon: Icons.favorite_rounded, text: factor));
  }

  if (rows.isEmpty) {
    rows.add(
      const _ChangeRowData(
        icon: Icons.info_outline_rounded,
        text: '아직 변화 분석을 위한 기록이 부족해요.',
      ),
    );
  }
  return rows.take(3).toList();
}

List<String> _careTips(HealthReport report) {
  final tips = report.careTips
      .map((tip) => tip.trim())
      .where((tip) => tip.isNotEmpty)
      .where((tip) => !tip.contains('복용'))
      .toList();
  if (tips.isNotEmpty) {
    return tips;
  }
  return const ['충분한 휴식', '가벼운 스트레칭', '수면 리듬 일정하게 유지'];
}

String _formatHours(double hours) {
  final minutes = (hours * 60).round();
  return '${minutes ~/ 60}h ${minutes % 60}m';
}

String _stressLabel(StressLevel level) {
  return switch (level) {
    StressLevel.low => '낮음',
    StressLevel.medium => '보통',
    StressLevel.high => '높음',
  };
}

String _confidenceLabel(String confidence) {
  return switch (confidence) {
    'high' => '높음',
    'medium' => '보통',
    _ => '낮음',
  };
}

double _sin(double x) {
  var term = x;
  var sum = x;
  for (var i = 1; i < 8; i++) {
    term *= -x * x / ((2 * i) * (2 * i + 1));
    sum += term;
  }
  return sum;
}

double _cos(double x) {
  var term = 1.0;
  var sum = 1.0;
  for (var i = 1; i < 8; i++) {
    term *= -x * x / ((2 * i - 1) * (2 * i));
    sum += term;
  }
  return sum;
}

const _shortDisclaimer = '이 분석은 진단이나 치료가 아닌 건강 관리 참고 정보입니다.';
const _fullDisclaimer =
    '이 서비스는 진단이나 치료를 제공하지 않습니다. 사용자가 입력한 기록과 공공데이터 기반 의료기관 정보를 바탕으로 건강 관리 참고 정보를 제공합니다.';
