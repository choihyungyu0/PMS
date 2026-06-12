import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/app_text.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onStart,
    required this.onLogin,
  });

  final VoidCallback onStart;
  final VoidCallback onLogin;

  static const _backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFFCFAFF), Color(0xFFF8F4FF)],
    stops: [0.0, 0.62, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final compactHeight = height < 700;
              final horizontalPadding = (width * 0.085)
                  .clamp(28.0, 44.0)
                  .toDouble();
              final logoSize = (width * (compactHeight ? 0.35 : 0.41))
                  .clamp(compactHeight ? 132.0 : 150.0, 184.0)
                  .toDouble();
              final titleSize = (width * (compactHeight ? 0.087 : 0.10))
                  .clamp(compactHeight ? 34.0 : 40.0, 46.0)
                  .toDouble();
              final headlineSize = (width * 0.057)
                  .clamp(compactHeight ? 21.0 : 23.0, 26.0)
                  .toDouble();
              final topGap = (height * (compactHeight ? 0.075 : 0.15))
                  .clamp(compactHeight ? 44.0 : 106.0, 145.0)
                  .toDouble();
              final logoToTitleGap = (height * 0.028)
                  .clamp(compactHeight ? 12.0 : 18.0, 26.0)
                  .toDouble();
              final titleToHeadlineGap =
                  (height * (compactHeight ? 0.09 : 0.16))
                      .clamp(compactHeight ? 54.0 : 112.0, 150.0)
                      .toDouble();
              final buttonHeight = (height * 0.078)
                  .clamp(compactHeight ? 56.0 : 60.0, 72.0)
                  .toDouble();
              final buttonGap = compactHeight ? 18.0 : 24.0;
              final bottomGap = (height * 0.05)
                  .clamp(compactHeight ? 20.0 : 28.0, 54.0)
                  .toDouble();
              final usedHeight =
                  topGap +
                  logoSize +
                  logoToTitleGap +
                  titleSize +
                  titleToHeadlineGap +
                  (headlineSize * 1.45 * 2) +
                  buttonHeight +
                  buttonGap +
                  buttonHeight +
                  bottomGap;
              final actionGap = (height - usedHeight)
                  .clamp(
                    compactHeight ? 20.0 : 28.0,
                    compactHeight ? 36.0 : 120.0,
                  )
                  .toDouble();

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: height),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: topGap),
                          Image.asset(
                            AppAssets.moreCycleLogo,
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: logoToTitleGap),
                          _GradientText(
                            text: AppText.appName,
                            style: TextStyle(
                              fontFamily: AppFonts.brand,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                              height: 1,
                            ),
                          ),
                          SizedBox(height: titleToHeadlineGap),
                          Text(
                            '나만을 위한\n여성 건강 관리 시작하기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppFonts.title,
                              color: AppColors.textPrimary,
                              fontSize: headlineSize,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                              height: 1.45,
                            ),
                          ),
                          SizedBox(height: actionGap),
                          _PrimaryGradientButton(
                            height: buttonHeight,
                            label: '시작하기',
                            onPressed: onStart,
                          ),
                          SizedBox(height: buttonGap),
                          _OutlineButton(
                            height: buttonHeight,
                            label: '로그인',
                            onPressed: onLogin,
                          ),
                          SizedBox(height: bottomGap),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.primaryPurple,
              AppColors.deepPurple,
              Color(0xFF7446F4),
            ],
          ).createShader(Offset.zero & bounds.size);
        },
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: style.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _PrimaryGradientButton extends StatelessWidget {
  const _PrimaryGradientButton({
    required this.height,
    required this.label,
    required this.onPressed,
  });

  final double height;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF6B35F2),
                  AppColors.primaryPurple,
                  Color(0xFF7444F4),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.23),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.action,
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.height,
    required this.label,
    required this.onPressed,
  });

  final double height;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD6CFF0), width: 2.2),
            ),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.action,
                  color: AppColors.textPrimary,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
