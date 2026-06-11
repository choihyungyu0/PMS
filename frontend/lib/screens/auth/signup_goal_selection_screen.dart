import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/storage/health_goal_storage.dart';
import '../../state/auth_controller.dart';
import 'signup_basic_info_screen.dart';

enum HealthGoalOption {
  cycleManagement(
    id: 'cycle_management',
    label: '생리 주기 관리',
    iconType: GoalIconType.cycle,
  ),
  pmsRelief(
    id: 'pms_relief',
    label: 'PMS 증상 완화',
    iconType: GoalIconType.calendarHeart,
  ),
  sleepStressManagement(
    id: 'sleep_stress_management',
    label: '수면 & 스트레스 관리',
    iconType: GoalIconType.moon,
  ),
  skinBodyManagement(
    id: 'skin_body_management',
    label: '피부 & 체형 관리',
    iconType: GoalIconType.skin,
  ),
  womenDiseasePrevention(
    id: 'women_disease_prevention',
    label: '여성 질환 예방',
    iconType: GoalIconType.shield,
  );

  const HealthGoalOption({
    required this.id,
    required this.label,
    required this.iconType,
  });

  final String id;
  final String label;
  final GoalIconType iconType;
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
  static const _borderColor = Color(0xFFD6D2E6);
  static const _chevronColor = Color(0xFFB8B3C8);
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
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final screenHeight = constraints.maxHeight;
                  final horizontalPadding = (screenWidth * 0.085)
                      .clamp(30.0, 44.0)
                      .toDouble();
                  final topGap = (screenHeight * 0.026)
                      .clamp(24.0, 30.0)
                      .toDouble();
                  final titleTopGap = (screenHeight * 0.024)
                      .clamp(18.0, 26.0)
                      .toDouble();
                  final titleSize = (screenWidth * 0.089)
                      .clamp(33.0, 42.0)
                      .toDouble();
                  final listTopGap = (screenHeight * 0.040)
                      .clamp(34.0, 42.0)
                      .toDouble();
                  final cardHeight = (screenHeight * 0.087)
                      .clamp(74.0, 86.0)
                      .toDouble();
                  final cardGap = (screenHeight * 0.020)
                      .clamp(16.0, 22.0)
                      .toDouble();
                  final buttonHeight = (screenHeight * 0.082)
                      .clamp(66.0, 78.0)
                      .toDouble();
                  final bottomGap = (screenHeight * 0.050)
                      .clamp(34.0, 52.0)
                      .toDouble();

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
                                  enabled: !_isBusy,
                                  onTap: widget.onCloseToWelcome,
                                ),
                              ),
                              SizedBox(height: titleTopGap),
                              Text(
                                '나의 건강 목표를\n선택해주세요.',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                  height: 1.38,
                                ),
                              ),
                              SizedBox(height: listTopGap),
                              Column(
                                children: [
                                  for (final goal in HealthGoalOption.values)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom:
                                            goal == HealthGoalOption.values.last
                                            ? 0
                                            : cardGap,
                                      ),
                                      child: _GoalOptionCard(
                                        height: cardHeight,
                                        goal: goal,
                                        selected: _selectedGoals.contains(goal),
                                        enabled: !_isBusy,
                                        onTap: () => _toggleGoal(goal),
                                      ),
                                    ),
                                ],
                              ),
                              if (_visibleErrorMessage != null) ...[
                                const SizedBox(height: 18),
                                Text(
                                  _visibleErrorMessage!,
                                  key: const Key('goalSelectionErrorMessage'),
                                  style: const TextStyle(
                                    color: _errorColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                              const Spacer(),
                              SizedBox(height: screenHeight * 0.04),
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
  const _TopCloseButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '닫기',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(28),
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.close_rounded, color: Colors.black, size: 38),
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
        ? AppColors.primaryPurple
        : _HealthGoalSelectionScreenState._borderColor;
    final backgroundColor = selected ? AppColors.lightPurpleCard : Colors.white;
    final chevronColor = selected
        ? AppColors.primaryPurple
        : _HealthGoalSelectionScreenState._chevronColor;

    return Semantics(
      button: true,
      selected: selected,
      label: goal.label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(25),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: double.infinity,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: borderColor, width: selected ? 2.2 : 2),
              boxShadow: [
                if (selected)
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: Row(
              children: [
                _GoalIcon(
                  type: goal.iconType,
                  color: AppColors.primaryPurple,
                  size: 30,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    goal.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: chevronColor,
                  size: selected ? 28 : 36,
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
    return Semantics(
      button: true,
      label: '다음',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: loading ? null : onTap,
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
                  Color(0xFF7A35F4),
                  AppColors.primaryPurple,
                  AppColors.deepPurple,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '다음',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
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

enum GoalIconType { cycle, calendarHeart, moon, skin, shield }

class _GoalIcon extends StatelessWidget {
  const _GoalIcon({
    required this.type,
    required this.color,
    required this.size,
  });

  final GoalIconType type;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoalIconPainter(type: type, color: color),
      ),
    );
  }
}

class _GoalIconPainter extends CustomPainter {
  const _GoalIconPainter({required this.type, required this.color});

  final GoalIconType type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (type) {
      case GoalIconType.cycle:
        _drawCycleIcon(canvas, size, strokePaint, fillPaint);
        break;
      case GoalIconType.calendarHeart:
        _drawCalendarHeartIcon(canvas, size, strokePaint);
        break;
      case GoalIconType.moon:
        _drawMoonIcon(canvas, size, strokePaint, fillPaint);
        break;
      case GoalIconType.skin:
        _drawSkinIcon(canvas, size, strokePaint, fillPaint);
        break;
      case GoalIconType.shield:
        _drawShieldIcon(canvas, size, strokePaint);
        break;
    }
  }

  void _drawCycleIcon(
    Canvas canvas,
    Size size,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    final w = size.width;
    final h = size.height;
    final arcRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.50),
      width: w * 0.74,
      height: h * 0.74,
    );

    canvas.drawArc(
      arcRect,
      -math.pi * 0.25,
      math.pi * 1.65,
      false,
      strokePaint,
    );

    final arrowPath = Path()
      ..moveTo(w * 0.78, h * 0.24)
      ..lineTo(w * 0.86, h * 0.26)
      ..lineTo(w * 0.83, h * 0.35);
    canvas.drawPath(arrowPath, strokePaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.055, fillPaint);
  }

  void _drawCalendarHeartIcon(Canvas canvas, Size size, Paint strokePaint) {
    final w = size.width;
    final h = size.height;
    final calendarRect = Rect.fromLTWH(w * 0.17, h * 0.20, w * 0.66, h * 0.64);

    canvas.drawRRect(
      RRect.fromRectAndRadius(calendarRect, Radius.circular(w * 0.14)),
      strokePaint,
    );
    canvas.drawLine(
      Offset(w * 0.32, h * 0.12),
      Offset(w * 0.32, h * 0.28),
      strokePaint,
    );
    canvas.drawLine(
      Offset(w * 0.68, h * 0.12),
      Offset(w * 0.68, h * 0.28),
      strokePaint,
    );

    final heartPath = Path()
      ..moveTo(w * 0.50, h * 0.66)
      ..cubicTo(w * 0.28, h * 0.52, w * 0.36, h * 0.39, w * 0.50, h * 0.49)
      ..cubicTo(w * 0.64, h * 0.39, w * 0.72, h * 0.52, w * 0.50, h * 0.66);
    canvas.drawPath(heartPath, strokePaint);
  }

  void _drawMoonIcon(
    Canvas canvas,
    Size size,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    final w = size.width;
    final h = size.height;
    final moonPath = Path()
      ..moveTo(w * 0.68, h * 0.18)
      ..cubicTo(w * 0.36, h * 0.15, w * 0.17, h * 0.40, w * 0.20, h * 0.62)
      ..cubicTo(w * 0.24, h * 0.89, w * 0.58, h * 0.96, w * 0.78, h * 0.75)
      ..cubicTo(w * 0.55, h * 0.79, w * 0.43, h * 0.59, w * 0.47, h * 0.43)
      ..cubicTo(w * 0.50, h * 0.30, w * 0.58, h * 0.22, w * 0.68, h * 0.18);
    canvas.drawPath(moonPath, strokePaint);
    _drawSmallSparkle(canvas, Offset(w * 0.78, h * 0.35), w * 0.10, fillPaint);
    canvas.drawCircle(Offset(w * 0.70, h * 0.25), w * 0.035, fillPaint);
  }

  void _drawSkinIcon(
    Canvas canvas,
    Size size,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    final w = size.width;
    final h = size.height;
    final faceRect = Rect.fromLTWH(w * 0.17, h * 0.16, w * 0.58, h * 0.70);

    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(w * 0.20)),
      strokePaint,
    );

    final faceLine = Path()
      ..moveTo(w * 0.38, h * 0.61)
      ..quadraticBezierTo(w * 0.48, h * 0.72, w * 0.63, h * 0.64);
    canvas.drawPath(faceLine, strokePaint);
    canvas.drawLine(
      Offset(w * 0.33, h * 0.66),
      Offset(w * 0.42, h * 0.66),
      strokePaint,
    );
    _drawSmallSparkle(canvas, Offset(w * 0.78, h * 0.61), w * 0.12, fillPaint);
  }

  void _drawShieldIcon(Canvas canvas, Size size, Paint strokePaint) {
    final w = size.width;
    final h = size.height;
    final shieldPath = Path()
      ..moveTo(w * 0.50, h * 0.12)
      ..lineTo(w * 0.78, h * 0.24)
      ..lineTo(w * 0.75, h * 0.56)
      ..cubicTo(w * 0.73, h * 0.74, w * 0.61, h * 0.84, w * 0.50, h * 0.90)
      ..cubicTo(w * 0.39, h * 0.84, w * 0.27, h * 0.74, w * 0.25, h * 0.56)
      ..lineTo(w * 0.22, h * 0.24)
      ..close();
    canvas.drawPath(shieldPath, strokePaint);
    canvas.drawLine(
      Offset(w * 0.50, h * 0.40),
      Offset(w * 0.50, h * 0.63),
      strokePaint,
    );
    canvas.drawLine(
      Offset(w * 0.39, h * 0.515),
      Offset(w * 0.61, h * 0.515),
      strokePaint,
    );
  }

  void _drawSmallSparkle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint fillPaint,
  ) {
    final sparklePath = Path();
    for (var i = 0; i < 8; i++) {
      final angle = -math.pi / 2 + i * math.pi / 4;
      final currentRadius = i.isEven ? radius : radius * 0.32;
      final x = center.dx + math.cos(angle) * currentRadius;
      final y = center.dy + math.sin(angle) * currentRadius;
      if (i == 0) {
        sparklePath.moveTo(x, y);
      } else {
        sparklePath.lineTo(x, y);
      }
    }
    sparklePath.close();
    canvas.drawPath(sparklePath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _GoalIconPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
