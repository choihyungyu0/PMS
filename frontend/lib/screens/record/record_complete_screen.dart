import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

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
        backgroundColor: AppColors.lavenderBackground,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 390
                ? 28.0
                : (constraints.maxWidth * 0.072).clamp(44.0, 60.0).toDouble();
            final topClosePadding = (constraints.maxWidth * 0.075)
                .clamp(18.0, 62.0)
                .toDouble();
            final checkSize = (constraints.maxWidth * 0.56)
                .clamp(190.0, 455.0)
                .toDouble();
            final titleFontSize = (constraints.maxWidth * 0.058)
                .clamp(30.0, 48.0)
                .toDouble();
            final descriptionFontSize = (constraints.maxWidth * 0.056)
                .clamp(29.0, 46.0)
                .toDouble();
            final buttonHeight = (constraints.maxWidth * 0.19)
                .clamp(62.0, 155.0)
                .toDouble();
            final buttonBottomPadding = (constraints.maxWidth * 0.085)
                .clamp(34.0, 70.0)
                .toDouble();
            final buttonTextSize = (constraints.maxWidth * 0.056)
                .clamp(28.0, 46.0)
                .toDouble();

            return ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: const Color(0xFFE2D6F8),
                    width: 1.8,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: topClosePadding,
                            right: horizontalPadding - 12,
                          ),
                          child: _CloseButton(onTap: _goHome),
                        ),
                      ),
                      const Spacer(flex: 6),
                      Image.asset(
                        AppAssets.recordCompleteCheck,
                        width: checkSize,
                        height: checkSize,
                        fit: BoxFit.contain,
                      ),
                      const Spacer(flex: 3),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          children: [
                            Text(
                              '기록이 완료되었습니다!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 34),
                            Text(
                              'AI 분석을 통해 더 정확한\n건강 케어를 제공할게요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2E2E32),
                                fontSize: descriptionFontSize,
                                fontWeight: FontWeight.w500,
                                height: 1.48,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 7),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          buttonBottomPadding,
                        ),
                        child: _GradientHomeButton(
                          height: buttonHeight,
                          fontSize: buttonTextSize,
                          onTap: _goHome,
                        ),
                      ),
                    ],
                  ),
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
  const _CloseButton({required this.onTap});

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
          child: const SizedBox(
            width: 64,
            height: 64,
            child: Icon(
              Icons.close_rounded,
              color: Color(0xFF242428),
              size: 56,
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
    required this.fontSize,
    required this.onTap,
  });

  final double height;
  final double fontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '홈으로 이동',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Ink(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF7B35F4),
                  AppColors.primaryPurple,
                  AppColors.deepPurple,
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
