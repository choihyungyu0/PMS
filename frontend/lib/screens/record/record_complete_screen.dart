import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';

class RecordCompleteScreen extends StatefulWidget {
  const RecordCompleteScreen({super.key, required this.onGoHome});

  final VoidCallback onGoHome;

  @override
  State<RecordCompleteScreen> createState() => _RecordCompleteScreenState();
}

class _RecordCompleteScreenState extends State<RecordCompleteScreen> {
  bool _leaving = false;

  void _goHome() {
    if (_leaving) {
      return;
    }
    _leaving = true;
    widget.onGoHome();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goHome();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = (constraints.maxWidth * 0.071)
                .clamp(28.0, 62.0)
                .toDouble();
            final contentScale =
                (constraints.maxHeight / (constraints.maxWidth * 2.08))
                    .clamp(0.76, 1.0)
                    .toDouble();
            final textScale =
                (constraints.maxHeight / (constraints.maxWidth * 1.92))
                    .clamp(0.84, 1.0)
                    .toDouble();
            final closeTopPadding = (constraints.maxHeight * 0.039)
                .clamp(28.0, 76.0)
                .toDouble();
            final closeRightPadding = (constraints.maxWidth * 0.087)
                .clamp(30.0, 76.0)
                .toDouble();
            final closeBoxSize =
                ((constraints.maxWidth * 0.078).clamp(44.0, 64.0) *
                        contentScale)
                    .clamp(40.0, 64.0)
                    .toDouble();
            final closeIconSize = closeBoxSize * 0.78;
            final checkSize =
                ((constraints.maxWidth * 0.493).clamp(184.0, 405.0) *
                        contentScale)
                    .clamp(156.0, 405.0)
                    .toDouble();
            final maxCheckTop = constraints.maxHeight * 0.30;
            final minCheckTop = maxCheckTop < 150.0 ? maxCheckTop : 150.0;
            final checkTop = (constraints.maxHeight * 0.232)
                .clamp(minCheckTop, maxCheckTop)
                .toDouble();
            final minimumTextTop = checkTop + checkSize + 44;
            final preferredTextTop = constraints.maxHeight * 0.531;
            final textTop = preferredTextTop < minimumTextTop
                ? minimumTextTop
                : preferredTextTop;
            final titleFontSize =
                ((constraints.maxWidth * 0.062).clamp(27.0, 52.0) * textScale)
                    .clamp(24.0, 52.0)
                    .toDouble();
            final descriptionFontSize =
                ((constraints.maxWidth * 0.063).clamp(26.0, 52.0) * textScale)
                    .clamp(22.0, 52.0)
                    .toDouble();
            final buttonHeight =
                ((constraints.maxWidth * 0.19).clamp(62.0, 158.0) *
                        contentScale)
                    .clamp(58.0, 158.0)
                    .toDouble();
            final buttonBottomPadding = (constraints.maxHeight * 0.036)
                .clamp(24.0, 70.0)
                .toDouble();
            final buttonTextSize =
                ((constraints.maxWidth * 0.069).clamp(28.0, 56.0) * textScale)
                    .clamp(23.0, 56.0)
                    .toDouble();
            final buttonRadius = (buttonHeight * 0.30)
                .clamp(22.0, 48.0)
                .toDouble();
            final titleDescriptionGap =
                ((constraints.maxHeight * 0.041).clamp(30.0, 80.0) *
                        contentScale)
                    .clamp(22.0, 80.0)
                    .toDouble();

            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD8C4FB), width: 1.4),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      top: closeTopPadding,
                      right: closeRightPadding,
                      child: _CloseButton(
                        size: closeBoxSize,
                        iconSize: closeIconSize,
                        onTap: _goHome,
                      ),
                    ),
                    Positioned(
                      top: checkTop,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Image.asset(
                          AppAssets.recordCompleteCheck,
                          width: checkSize,
                          height: checkSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: textTop,
                      left: horizontalPadding,
                      right: horizontalPadding,
                      child: Column(
                        children: [
                          Text(
                            '기록이 완료되었습니다!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppFonts.title,
                              color: AppColors.textPrimary,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w900,
                              height: 1.18,
                            ),
                          ),
                          SizedBox(height: titleDescriptionGap),
                          Text(
                            'AI 분석을 통해 더 정확한\n건강 케어를 제공할게요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              color: Color(0xFF2E2E32),
                              fontSize: descriptionFontSize,
                              fontWeight: FontWeight.w500,
                              height: 1.54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      bottom: buttonBottomPadding,
                      child: _GradientHomeButton(
                        height: buttonHeight,
                        borderRadius: buttonRadius,
                        fontSize: buttonTextSize,
                        onTap: _goHome,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  final double size;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '닫기',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              Icons.close_rounded,
              color: const Color(0xFF242428),
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientHomeButton extends StatelessWidget {
  const _GradientHomeButton({
    required this.height,
    required this.borderRadius,
    required this.fontSize,
    required this.onTap,
  });

  final double height;
  final double borderRadius;
  final double fontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '홈으로 이동',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Ink(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF7B2DFA),
                  Color(0xFF7735FF),
                  Color(0xFF6628EA),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.24),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '홈으로 이동',
                style: TextStyle(
                  fontFamily: AppFonts.action,
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
