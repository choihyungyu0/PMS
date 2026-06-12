import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/storage/health_goal_storage.dart';
import '../../state/auth_controller.dart';
import 'signup_basic_info_screen.dart';

enum HealthGoalOption {
  cycleManagement(
    id: 'cycle_management',
    label: '생리 주기 관리',
    assetPath: AppAssets.goalCycle,
  ),
  pmsRelief(id: 'pms_relief', label: 'PMS 증상 완화', assetPath: AppAssets.goalPms),
  sleepStressManagement(
    id: 'sleep_stress_management',
    label: '수면 & 스트레스 관리',
    assetPath: AppAssets.goalSleepStress,
  ),
  skinBodyManagement(
    id: 'skin_body_management',
    label: '피부 & 체형 관리',
    assetPath: AppAssets.goalSkinBody,
  ),
  womenDiseasePrevention(
    id: 'women_disease_prevention',
    label: '여성 질환 예방',
    assetPath: AppAssets.goalPrevention,
  );

  const HealthGoalOption({
    required this.id,
    required this.label,
    required this.assetPath,
  });

  final String id;
  final String label;
  final String assetPath;
}

class HealthGoalSelectionScreen extends StatefulWidget {
  const HealthGoalSelectionScreen({
    super.key,
    required this.controller,
    required this.signupData,
    required this.onBackToBasicInfo,
    required this.onCloseToWelcome,
    required this.onSignupCompleted,
    HealthGoalStorage? goalStorage,
  }) : goalStorage = goalStorage ?? const _DefaultHealthGoalStorage();

  final AuthController controller;
  final PendingSignupData signupData;
  final VoidCallback onBackToBasicInfo;
  final VoidCallback onCloseToWelcome;
  final VoidCallback onSignupCompleted;
  final HealthGoalStorage goalStorage;

  @override
  State<HealthGoalSelectionScreen> createState() =>
      _HealthGoalSelectionScreenState();
}

class _HealthGoalSelectionScreenState extends State<HealthGoalSelectionScreen> {
  static const _screenTextColor = Color(0xFF181337);
  static const _cardBorderColor = Color(0xFFFFFFFF);
  static const _selectedBorderColor = Color(0xFFC36AFF);
  static const _chevronColor = Color(0xFF9B66D8);
  static const _errorColor = Color(0xFFC44949);

  final Set<HealthGoalOption> _selectedGoals = {};
  String? _localErrorMessage;
  bool _signupAttempted = false;
  bool _savingGoals = false;

  bool get _isBusy => _savingGoals || widget.controller.loading;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_isBusy) {
          widget.onBackToBasicInfo();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF8FF),
        body: Stack(
          children: [
            const Positioned.fill(child: _GoalSelectionBackground()),
            SafeArea(
              top: false,
              child: AnimatedBuilder(
                animation: widget.controller,
                builder: (context, _) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final screenHeight = constraints.maxHeight;
                      final compactHeight = screenHeight < 760;
                      final horizontalPadding = (screenWidth * 0.077)
                          .clamp(28.0, 40.0)
                          .toDouble();
                      final topGap = (screenHeight * 0.044)
                          .clamp(compactHeight ? 18.0 : 32.0, 46.0)
                          .toDouble();
                      final closeSize = compactHeight
                          ? (screenWidth * 0.092).clamp(40.0, 46.0).toDouble()
                          : (screenWidth * 0.112).clamp(42.0, 52.0).toDouble();
                      final titleTopGap = compactHeight
                          ? (screenHeight * 0.022).clamp(13.0, 18.0).toDouble()
                          : (screenHeight * 0.033).clamp(24.0, 42.0).toDouble();
                      final titleSize = compactHeight
                          ? (screenHeight * 0.052).clamp(32.0, 38.0).toDouble()
                          : (screenWidth * 0.091).clamp(34.0, 45.0).toDouble();
                      final listTopGap = compactHeight
                          ? (screenHeight * 0.028).clamp(16.0, 22.0).toDouble()
                          : (screenHeight * 0.039).clamp(28.0, 40.0).toDouble();
                      final cardHeight = compactHeight
                          ? (screenHeight * 0.091).clamp(60.0, 68.0).toDouble()
                          : (screenHeight * 0.101).clamp(78.0, 94.0).toDouble();
                      final cardGap = compactHeight
                          ? (screenHeight * 0.014).clamp(8.0, 11.0).toDouble()
                          : (screenHeight * 0.019).clamp(14.0, 19.0).toDouble();
                      final buttonHeight = compactHeight
                          ? (screenHeight * 0.074).clamp(52.0, 58.0).toDouble()
                          : (screenHeight * 0.083).clamp(66.0, 78.0).toDouble();
                      final buttonTopGap = compactHeight
                          ? (screenHeight * 0.018).clamp(10.0, 14.0).toDouble()
                          : (screenHeight * 0.030).clamp(22.0, 30.0).toDouble();
                      final bottomGap = compactHeight
                          ? (screenHeight * 0.022).clamp(12.0, 18.0).toDouble()
                          : (screenHeight * 0.037).clamp(24.0, 38.0).toDouble();

                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: screenHeight),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: topGap),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: _TopCloseButton(
                                      size: closeSize,
                                      enabled: !_isBusy,
                                      onTap: widget.onCloseToWelcome,
                                    ),
                                  ),
                                  SizedBox(height: titleTopGap),
                                  Text(
                                    '나의 건강 목표를\n선택해주세요.',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: AppFonts.title,
                                      color: _screenTextColor,
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0,
                                      height: 1.30,
                                    ),
                                  ),
                                  SizedBox(height: listTopGap),
                                  Column(
                                    children: [
                                      for (final goal
                                          in HealthGoalOption.values)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom:
                                                goal ==
                                                    HealthGoalOption.values.last
                                                ? 0
                                                : cardGap,
                                          ),
                                          child: _GoalOptionCard(
                                            height: cardHeight,
                                            goal: goal,
                                            selected: _selectedGoals.contains(
                                              goal,
                                            ),
                                            enabled: !_isBusy,
                                            onTap: () => _toggleGoal(goal),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (_visibleErrorMessage != null) ...[
                                    const SizedBox(height: 14),
                                    Text(
                                      _visibleErrorMessage!,
                                      key: const Key(
                                        'goalSelectionErrorMessage',
                                      ),
                                      style: const TextStyle(
                                        fontFamily: AppFonts.body,
                                        color: _errorColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  SizedBox(height: buttonTopGap),
                                  _GradientNextButton(
                                    key: const Key('goalSelectionNextButton'),
                                    height: buttonHeight,
                                    loading: _isBusy,
                                    onTap: _submit,
                                  ),
                                  SizedBox(height: bottomGap),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? get _visibleErrorMessage {
    if (_localErrorMessage != null) {
      return _localErrorMessage;
    }
    if (_signupAttempted && widget.controller.errorMessage != null) {
      final errorMessage = widget.controller.errorMessage!;
      return errorMessage.isEmpty
          ? '회원가입에 실패했어요. 입력 정보를 확인해주세요.'
          : errorMessage;
    }
    return null;
  }

  void _toggleGoal(HealthGoalOption goal) {
    if (_isBusy) {
      return;
    }
    setState(() {
      _localErrorMessage = null;
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  Future<void> _submit() async {
    if (_isBusy) {
      return;
    }
    if (_selectedGoals.isEmpty) {
      setState(() {
        _localErrorMessage = '건강 목표를 하나 이상 선택해주세요.';
      });
      return;
    }

    setState(() {
      _savingGoals = true;
      _signupAttempted = false;
      _localErrorMessage = null;
    });

    try {
      await widget.goalStorage.saveGoalIds(_selectedGoalIds);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _savingGoals = false;
        _localErrorMessage = '건강 목표 저장에 실패했어요. 다시 시도해주세요.';
      });
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _savingGoals = false;
      _signupAttempted = true;
    });

    final success = await widget.controller.signup(
      widget.signupData.email,
      widget.signupData.password,
      widget.signupData.nickname,
      widget.signupData.birthDate,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      widget.onSignupCompleted();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원가입이 완료되었어요.'),
          backgroundColor: AppColors.primaryPurple,
        ),
      );
      return;
    }

    setState(() {
      _signupAttempted = true;
    });
  }

  List<String> get _selectedGoalIds {
    return HealthGoalOption.values
        .where(_selectedGoals.contains)
        .map((goal) => goal.id)
        .toList();
  }
}

class _DefaultHealthGoalStorage extends HealthGoalStorage {
  const _DefaultHealthGoalStorage();
}

class _TopCloseButton extends StatelessWidget {
  const _TopCloseButton({
    required this.size,
    required this.enabled,
    required this.onTap,
  });

  final double size;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '닫기',
      child: Material(
        color: Colors.white.withValues(alpha: 0.94),
        shape: const CircleBorder(),
        elevation: 0,
        shadowColor: AppColors.primaryPurple.withValues(alpha: 0.18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB998F8).withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                Icons.close_rounded,
                color: const Color(0xFF2E1B82),
                size: size * 0.68,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalOptionCard extends StatelessWidget {
  const _GoalOptionCard({
    required this.height,
    required this.goal,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final double height;
  final HealthGoalOption goal;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? _HealthGoalSelectionScreenState._selectedBorderColor
        : _HealthGoalSelectionScreenState._cardBorderColor;
    final iconSize = (height * 0.80).clamp(58.0, 76.0).toDouble();
    final leftPadding = (height * 0.18).clamp(14.0, 22.0).toDouble();
    final textGap = (height * 0.25).clamp(18.0, 25.0).toDouble();
    final fontSize = (height * 0.28).clamp(19.0, 25.0).toDouble();

    return Semantics(
      button: true,
      selected: selected,
      label: goal.label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: double.infinity,
            height: height,
            padding: EdgeInsets.only(left: leftPadding, right: 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: selected ? 0.98 : 0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderColor, width: selected ? 2.0 : 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFFB99AF4,
                  ).withValues(alpha: selected ? 0.22 : 0.13),
                  blurRadius: selected ? 24 : 18,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.80),
                  blurRadius: 10,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Image.asset(
                  goal.assetPath,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                SizedBox(width: textGap),
                Expanded(
                  child: Text(
                    goal.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.action,
                      color: _HealthGoalSelectionScreenState._screenTextColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                      height: 1.05,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right_rounded,
                  color: selected
                      ? AppColors.primaryPurple
                      : _HealthGoalSelectionScreenState._chevronColor,
                  size: (height * 0.43).clamp(30.0, 38.0).toDouble(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientNextButton extends StatelessWidget {
  const _GradientNextButton({
    super.key,
    required this.height,
    required this.loading,
    required this.onTap,
  });

  final double height;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(26);

    return Semantics(
      button: true,
      label: '다음',
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: borderRadius,
          child: Ink(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE15AFF),
                  Color(0xFF8E27EE),
                  AppColors.primaryPurple,
                  AppColors.deepPurple,
                ],
                stops: [0.0, 0.30, 0.66, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.44),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6D27DE).withValues(alpha: 0.36),
                  blurRadius: 25,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: const Color(0xFF2D0D86).withValues(alpha: 0.50),
                  blurRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _ButtonHighlightPainter()),
                ),
                Center(
                  child: loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          '다음',
                          style: TextStyle(
                            fontFamily: AppFonts.action,
                            color: Colors.white,
                            fontSize: (height * 0.41).clamp(24.0, 31.0),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                            height: 1,
                            shadows: [
                              Shadow(
                                color: const Color(
                                  0xFF391199,
                                ).withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalSelectionBackground extends StatelessWidget {
  const _GoalSelectionBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFBFAFF), Color(0xFFF8F2FF), Color(0xFFFFFFFF)],
          stops: [0.0, 0.48, 1.0],
        ),
      ),
      child: CustomPaint(painter: _GoalSelectionBackgroundPainter()),
    );
  }
}

class _GoalSelectionBackgroundPainter extends CustomPainter {
  const _GoalSelectionBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final waveRect = Rect.fromLTWH(
      size.width * 0.36,
      size.height * 0.04,
      size.width * 0.78,
      size.height * 0.42,
    );
    final wavePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x00FFFFFF), Color(0xBFE9DAFF), Color(0x66B987FF)],
      ).createShader(waveRect)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10);

    final wavePath = Path()
      ..moveTo(size.width * 0.46, size.height * 0.30)
      ..cubicTo(
        size.width * 0.66,
        size.height * 0.25,
        size.width * 0.77,
        size.height * 0.11,
        size.width * 1.08,
        size.height * 0.02,
      )
      ..lineTo(size.width * 1.08, size.height * 0.24)
      ..cubicTo(
        size.width * 0.86,
        size.height * 0.31,
        size.width * 0.74,
        size.height * 0.39,
        size.width * 0.50,
        size.height * 0.38,
      )
      ..close();
    canvas.drawPath(wavePath, wavePaint);

    final ribbonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.78),
          const Color(0xFFCFA8FF).withValues(alpha: 0.50),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.46))
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.2);

    final ribbonPath = Path()
      ..moveTo(size.width * 0.52, size.height * 0.29)
      ..cubicTo(
        size.width * 0.70,
        size.height * 0.27,
        size.width * 0.76,
        size.height * 0.15,
        size.width * 1.04,
        size.height * 0.08,
      );
    canvas.drawPath(ribbonPath, ribbonPaint);

    final secondRibbon = Path()
      ..moveTo(size.width * 0.70, size.height * 0.35)
      ..cubicTo(
        size.width * 0.84,
        size.height * 0.27,
        size.width * 0.88,
        size.height * 0.18,
        size.width * 1.05,
        size.height * 0.12,
      );
    canvas.drawPath(secondRibbon, ribbonPaint..strokeWidth = 1.2);

    final sparklePaint = Paint()..color = Colors.white.withValues(alpha: 0.82);
    _drawSparkle(
      canvas,
      Offset(size.width * 0.79, size.height * 0.17),
      7,
      sparklePaint,
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.70, size.height * 0.21),
      4,
      sparklePaint,
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.93, size.height * 0.13),
      5,
      sparklePaint,
    );
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = -math.pi / 2 + i * math.pi / 4;
      final currentRadius = i.isEven ? radius : radius * 0.28;
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
  bool shouldRepaint(covariant _GoalSelectionBackgroundPainter oldDelegate) {
    return false;
  }
}

class _ButtonHighlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topGlow = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.58),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.46));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3, 3, size.width - 6, size.height * 0.40),
        const Radius.circular(22),
      ),
      topGlow,
    );

    final lowerEdge = Paint()
      ..color = const Color(0xFF2E0C92).withValues(alpha: 0.52)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawArc(
      Rect.fromLTWH(3, size.height * 0.23, size.width - 6, size.height * 0.68),
      0,
      math.pi,
      false,
      lowerEdge,
    );

    final sparklePaint = Paint()..color = Colors.white.withValues(alpha: 0.78);
    _drawSparkle(
      canvas,
      Offset(size.width * 0.13, size.height * 0.45),
      8,
      sparklePaint,
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.85, size.height * 0.42),
      9,
      sparklePaint,
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.93, size.height * 0.64),
      5,
      sparklePaint,
    );
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = -math.pi / 2 + i * math.pi / 4;
      final currentRadius = i.isEven ? radius : radius * 0.30;
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
  bool shouldRepaint(covariant _ButtonHighlightPainter oldDelegate) {
    return false;
  }
}
