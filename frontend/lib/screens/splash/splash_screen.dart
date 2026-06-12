import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/app_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _brandOpacity;
  late final Animation<Offset> _sloganOffset;
  late final Animation<double> _sloganOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..forward();
    _brandOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.72, curve: Curves.easeOutCubic),
    );
    _sloganOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.28, 1.0, curve: Curves.easeOutCubic),
    );
    _sloganOffset =
        Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.28, 1.0, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFCFF),
                AppColors.lavenderBackground,
                Color(0xFFFBF7FF),
              ],
              stops: [0.0, 0.58, 1.0],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _SplashBackgroundPainter()),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final height = constraints.maxHeight;
                    final width = constraints.maxWidth;
                    final logoSize = math
                        .min(width * 0.25, height * 0.14)
                        .clamp(82.0, 104.0)
                        .toDouble();
                    final topOffset = (height * 0.285)
                        .clamp(116.0, 230.0)
                        .toDouble();
                    final bottomOffset = (height * 0.035)
                        .clamp(18.0, 34.0)
                        .toDouble();

                    return Stack(
                      children: [
                        Positioned(
                          top: topOffset,
                          left: 24,
                          right: 24,
                          child: FadeTransition(
                            opacity: _brandOpacity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  AppAssets.moreCycleLogo,
                                  width: logoSize,
                                  height: logoSize,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  AppText.appName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppFonts.brand,
                                    color: AppColors.primaryPurple,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'AI 여성 생애주기 케어 플랫폼',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppFonts.title,
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: bottomOffset,
                          child: FadeTransition(
                            opacity: _sloganOpacity,
                            child: SlideTransition(
                              position: _sloganOffset,
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '더 나은 오늘, 더 건강한 내일\n모어사이클이 함께해요.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: AppFonts.body,
                                      color: AppColors.primaryPurple,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0,
                                      height: 1.55,
                                    ),
                                  ),
                                  SizedBox(height: 28),
                                  _PageDots(currentIndex: 0, totalCount: 4),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashBackgroundPainter extends CustomPainter {
  const _SplashBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    _drawCenterGlow(canvas, size);
    _drawWaves(canvas, width, height);
    _drawHighlights(canvas, width, height);
    _drawSparkle(
      canvas,
      Offset(width * 0.12, height * 0.58),
      6,
      Colors.white.withValues(alpha: 0.34),
    );
    _drawSparkle(
      canvas,
      Offset(width * 0.80, height * 0.72),
      7,
      Colors.white.withValues(alpha: 0.42),
    );
    _drawSparkle(
      canvas,
      Offset(width * 0.88, height * 0.54),
      5,
      Colors.white.withValues(alpha: 0.28),
    );
    _drawSparkle(
      canvas,
      Offset(width * 0.22, height * 0.75),
      6,
      Colors.white.withValues(alpha: 0.30),
    );
  }

  void _drawCenterGlow(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.78),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(width * 0.5, height * 0.34),
              radius: width * 0.55,
            ),
          );

    canvas.drawCircle(
      Offset(width * 0.5, height * 0.34),
      width * 0.55,
      glowPaint,
    );
  }

  void _drawWaves(Canvas canvas, double width, double height) {
    final wave1 = Path()
      ..moveTo(0, height * 0.60)
      ..cubicTo(
        width * 0.16,
        height * 0.63,
        width * 0.27,
        height * 0.72,
        width * 0.46,
        height * 0.66,
      )
      ..cubicTo(
        width * 0.66,
        height * 0.59,
        width * 0.76,
        height * 0.53,
        width,
        height * 0.56,
      )
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    final wave2 = Path()
      ..moveTo(0, height * 0.67)
      ..cubicTo(
        width * 0.18,
        height * 0.70,
        width * 0.35,
        height * 0.70,
        width * 0.55,
        height * 0.62,
      )
      ..cubicTo(
        width * 0.74,
        height * 0.55,
        width * 0.82,
        height * 0.49,
        width,
        height * 0.50,
      )
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    final wave3 = Path()
      ..moveTo(0, height * 0.72)
      ..cubicTo(
        width * 0.20,
        height * 0.75,
        width * 0.32,
        height * 0.68,
        width * 0.52,
        height * 0.69,
      )
      ..cubicTo(
        width * 0.74,
        height * 0.70,
        width * 0.82,
        height * 0.61,
        width,
        height * 0.64,
      )
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    final wave4 = Path()
      ..moveTo(0, height * 0.78)
      ..cubicTo(
        width * 0.22,
        height * 0.76,
        width * 0.38,
        height * 0.82,
        width * 0.56,
        height * 0.77,
      )
      ..cubicTo(
        width * 0.75,
        height * 0.72,
        width * 0.84,
        height * 0.65,
        width,
        height * 0.68,
      )
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    canvas
      ..drawPath(
        wave1,
        Paint()..color = const Color(0xFFC6A6FF).withValues(alpha: 0.24),
      )
      ..drawPath(
        wave2,
        Paint()..color = const Color(0xFFB592FF).withValues(alpha: 0.30),
      )
      ..drawPath(
        wave3,
        Paint()..color = const Color(0xFF9F7AFF).withValues(alpha: 0.20),
      )
      ..drawPath(
        wave4,
        Paint()..color = const Color(0xFFD9C9FF).withValues(alpha: 0.32),
      );
  }

  void _drawHighlights(Canvas canvas, double width, double height) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final highlight1 = Path()
      ..moveTo(0, height * 0.67)
      ..cubicTo(
        width * 0.22,
        height * 0.69,
        width * 0.36,
        height * 0.66,
        width * 0.52,
        height * 0.62,
      )
      ..cubicTo(
        width * 0.72,
        height * 0.57,
        width * 0.80,
        height * 0.52,
        width,
        height * 0.51,
      );

    final highlight2 = Path()
      ..moveTo(0, height * 0.73)
      ..cubicTo(
        width * 0.18,
        height * 0.71,
        width * 0.35,
        height * 0.75,
        width * 0.52,
        height * 0.76,
      )
      ..cubicTo(
        width * 0.70,
        height * 0.77,
        width * 0.82,
        height * 0.72,
        width,
        height * 0.72,
      );

    canvas
      ..drawPath(highlight1, linePaint)
      ..drawPath(highlight2, linePaint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();

    for (var i = 0; i < 8; i++) {
      final angle = -math.pi / 2 + i * math.pi / 4;
      final currentRadius = i.isEven ? radius : radius * 0.22;
      final point = Offset(
        center.dx + math.cos(angle) * currentRadius,
        center.dy + math.sin(angle) * currentRadius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SplashBackgroundPainter oldDelegate) {
    return false;
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.currentIndex, required this.totalCount});

  final int currentIndex;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalCount, (index) {
        final isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 5.5),
          width: 8.5,
          height: 8.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primaryPurple : const Color(0xFFD5C8FF),
          ),
        );
      }),
    );
  }
}
