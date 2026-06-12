import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/health_goal_storage.dart';
import '../../models/health_report.dart';
import '../../state/analysis_controller.dart';
import '../../state/auth_controller.dart';
import '../../state/report_controller.dart';
import '../../widgets/loading_view.dart';

class AiCareRecommendationScreen extends StatefulWidget {
  const AiCareRecommendationScreen({
    super.key,
    required this.authController,
    required this.reportController,
    required this.analysisController,
    required this.onGoHome,
    HealthGoalStorage? goalStorage,
  }) : goalStorage = goalStorage ?? const HealthGoalStorage();

  final AuthController authController;
  final ReportController reportController;
  final AnalysisController analysisController;
  final VoidCallback onGoHome;
  final HealthGoalStorage goalStorage;

  @override
  State<AiCareRecommendationScreen> createState() =>
      _AiCareRecommendationScreenState();
}

class _AiCareRecommendationScreenState
    extends State<AiCareRecommendationScreen> {
  _CareCategory _selectedCategory = _CareCategory.food;
  List<String> _goalIds = const [];

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
    final goalIds = await widget.goalStorage.readGoalIds();
    if (!mounted) {
      return;
    }
    setState(() => _goalIds = goalIds);
  }

  void _goHome() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
    widget.onGoHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          widget.authController,
          widget.reportController,
          widget.analysisController,
        ]),
        builder: (context, _) {
          final report = widget.reportController.latestReport;
          final isInitialLoading =
              widget.reportController.loading &&
              report == null &&
              widget.reportController.errorMessage == null;

          if (isInitialLoading) {
            return const LoadingView(message: '맞춤 케어를 불러오는 중이에요.');
          }

          final recommendations = _buildRecommendations(
            report: report,
            summary: widget.analysisController.summary,
            goalIds: _goalIds,
            selectedCategory: _selectedCategory,
          );
          final nickname = _displayNickname(
            widget.authController.user?.nickname,
          );
          final hasReport = report != null;
          final hasError = widget.reportController.errorMessage != null;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0xFFFEFDFF), Color(0xFFF8F5FF)],
              ),
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _CareBackgroundPainter()),
                ),
                SafeArea(
                  child: RefreshIndicator(
                    color: AppColors.primaryPurple,
                    onRefresh: _load,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final screenWidth = constraints.maxWidth;
                        final screenHeight = constraints.maxHeight;
                        final horizontalPadding = (screenWidth * 0.065)
                            .clamp(22.0, 34.0)
                            .toDouble();
                        final topPadding = (screenHeight * 0.075)
                            .clamp(44.0, 88.0)
                            .toDouble();
                        final titleSize = (screenWidth * 0.092)
                            .clamp(32.0, 44.0)
                            .toDouble();
                        final subtitleSize = (screenWidth * 0.046)
                            .clamp(16.0, 22.0)
                            .toDouble();
                        final cardHeight = (screenHeight * 0.185)
                            .clamp(174.0, 214.0)
                            .toDouble();

                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            topPadding,
                            horizontalPadding,
                            34,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Header(
                                nickname: nickname,
                                titleSize: titleSize,
                                subtitleSize: subtitleSize,
                              ),
                              SizedBox(height: screenHeight * 0.045),
                              _CareSegmentedControl(
                                selectedCategory: _selectedCategory,
                                onChanged: (category) {
                                  setState(() => _selectedCategory = category);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.034),
                              if (!hasReport || hasError) ...[
                                _SoftNotice(
                                  text: hasError
                                      ? '추천 정보를 불러오지 못했어요. 기본 케어를 보여드릴게요.'
                                      : '아직 생성된 리포트가 없어 기본 케어를 추천드려요.\n오늘의 컨디션을 기록하면 더 맞춤화된 추천을 받을 수 있어요.',
                                ),
                                const SizedBox(height: 18),
                              ],
                              ...recommendations.map(
                                (recommendation) => Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: _CareRecommendationCard(
                                    recommendation: recommendation,
                                    height: cardHeight,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const _CareDisclaimerText(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 18,
                  child: SafeArea(
                    child: _HomeIconButton(onTap: _goHome),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.nickname,
    required this.titleSize,
    required this.subtitleSize,
  });

  final String nickname;
  final double titleSize;
  final double subtitleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI 맞춤 케어 추천',
          style: TextStyle(
            color: const Color(0xFF080A2F),
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
            height: 1.04,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          '$nickname에게 추천하는 케어예요.',
          style: TextStyle(
            color: const Color(0xFF555A76),
            fontSize: subtitleSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _HomeIconButton extends StatelessWidget {
  const _HomeIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '홈으로 이동',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.96),
              border: Border.all(color: const Color(0xFFE0D2FF), width: 1.3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.home_rounded,
              color: AppColors.primaryPurple,
              size: 27,
            ),
          ),
        ),
      ),
    );
  }
}

class _CareSegmentedControl extends StatelessWidget {
  const _CareSegmentedControl({
    required this.selectedCategory,
    required this.onChanged,
  });

  final _CareCategory selectedCategory;
  final ValueChanged<_CareCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFF0EAFE), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: _CareCategory.values.map((category) {
          final selected = selectedCategory == category;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFF9F4FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  border: selected
                      ? Border.all(color: const Color(0xFFE0D2FF), width: 1.4)
                      : null,
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryPurple.withValues(
                              alpha: 0.24,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category.icon,
                        color: selected
                            ? AppColors.primaryPurple
                            : const Color(0xFF596073),
                        size: 25,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.label,
                        style: TextStyle(
                          color: selected
                              ? AppColors.primaryPurple
                              : const Color(0xFF303241),
                          fontSize: 18,
                          fontWeight: selected
                              ? FontWeight.w900
                              : FontWeight.w700,
                          letterSpacing: 0,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CareRecommendationCard extends StatelessWidget {
  const _CareRecommendationCard({
    required this.recommendation,
    required this.height,
  });

  final _CareRecommendation recommendation;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0EAFE), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.075),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final textWidth = cardWidth * 0.55;
          final imageWidth = cardWidth * 0.50;
          return Stack(
            children: [
              Positioned(
                left: 28,
                top: 38,
                right: imageWidth - 12,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFEFE6FF),
                      ),
                      child: Icon(
                        recommendation.icon,
                        color: AppColors.primaryPurple,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          recommendation.title,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Color(0xFF080A2F),
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 31,
                top: 108,
                width: textWidth,
                child: Text(
                  recommendation.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2F3347),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    height: 1.3,
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 5,
                width: imageWidth,
                height: height * 0.88,
                child: Image.asset(
                  recommendation.assetPath,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                right: 35,
                top: 52,
                child: _Sparkle(
                  size: 18,
                  color: const Color(0xFFB893FF).withValues(alpha: 0.70),
                ),
              ),
              Positioned(
                right: 26,
                bottom: 27,
                child: _Sparkle(
                  size: 16,
                  color: const Color(0xFFB893FF).withValues(alpha: 0.58),
                ),
              ),
              Positioned(
                right: imageWidth * 0.93,
                bottom: 42,
                child: _Sparkle(
                  size: 15,
                  color: const Color(0xFFB893FF).withValues(alpha: 0.48),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SoftNotice extends StatelessWidget {
  const _SoftNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7DDFC), width: 1.2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.45,
        ),
      ),
    );
  }
}

class _CareDisclaimerText extends StatelessWidget {
  const _CareDisclaimerText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '이 추천은 진단이나 치료가 아닌 건강관리 참고 정보입니다.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.45,
      ),
    );
  }
}

class _CareBackgroundPainter extends CustomPainter {
  const _CareBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final blob = Path()
      ..moveTo(w * 0.82, 0)
      ..cubicTo(w * 0.74, h * 0.08, w * 0.83, h * 0.16, w * 0.92, h * 0.19)
      ..cubicTo(w * 1.04, h * 0.23, w * 1.03, h * 0.34, w * 0.98, h * 0.42)
      ..cubicTo(w * 0.91, h * 0.34, w * 0.88, h * 0.27, w, h * 0.20)
      ..lineTo(w, 0)
      ..close();

    canvas.drawPath(
      blob,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xFFEBDDFF).withValues(alpha: 0.82),
            const Color(0xFFF8F2FF).withValues(alpha: 0.18),
          ],
        ).createShader(Rect.fromLTWH(w * 0.68, 0, w * 0.34, h * 0.42)),
    );

    final curvePaint = Paint()
      ..color = const Color(0xFFC7A8FF).withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final curve = Path()
      ..moveTo(w * 0.89, h * 0.16)
      ..cubicTo(w * 0.88, h * 0.22, w * 0.94, h * 0.25, w, h * 0.25);

    canvas.drawPath(curve, curvePaint);

    _drawSparkle(
      canvas,
      Offset(w * 0.09, h * 0.09),
      15,
      const Color(0xFF8B51F5).withValues(alpha: 0.65),
    );
    _drawSparkle(
      canvas,
      Offset(w * 0.13, h * 0.09),
      7,
      const Color(0xFFD1B8FF).withValues(alpha: 0.72),
    );

    canvas.drawCircle(
      Offset(w * 0.70, h * 0.073),
      8,
      Paint()..color = const Color(0xFFE7DCFF).withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      Offset(w * 0.86, h * 0.14),
      6,
      Paint()..color = const Color(0xFFB996FF).withValues(alpha: 0.70),
    );
  }

  @override
  bool shouldRepaint(covariant _CareBackgroundPainter oldDelegate) => false;
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
    _drawSparkle(
      canvas,
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      color,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

enum _CareCategory {
  food(
    label: '식습관',
    title: '추천 음식',
    assetPath: AppAssets.aiCareFood,
    icon: Icons.restaurant_menu_rounded,
  ),
  exercise(
    label: '운동',
    title: '추천 운동',
    assetPath: AppAssets.aiCareExercise,
    icon: Icons.self_improvement_rounded,
  ),
  mind(
    label: '마음 케어',
    title: '추천 습관',
    assetPath: AppAssets.aiCareHabit,
    icon: Icons.favorite_border_rounded,
  );

  const _CareCategory({
    required this.label,
    required this.title,
    required this.assetPath,
    required this.icon,
  });

  final String label;
  final String title;
  final String assetPath;
  final IconData icon;
}

class _CareRecommendation {
  const _CareRecommendation({
    required this.category,
    required this.description,
    required this.priority,
  });

  final _CareCategory category;
  final String description;
  final int priority;

  String get title => category.title;
  String get assetPath => category.assetPath;
  IconData get icon => category.icon;
}

List<_CareRecommendation> _buildRecommendations({
  required HealthReport? report,
  required AnalysisSummary summary,
  required List<String> goalIds,
  required _CareCategory selectedCategory,
}) {
  final tips = _safeSources(report?.careTips ?? const []);
  final factors = _safeSources(report?.mainFactors ?? const []);
  final goals = _safeSources(_sourcesFromGoalIds(goalIds));
  final sources = [...tips, ...factors, ...goals];

  final recommendations = [
    _CareRecommendation(
      category: _CareCategory.food,
      description: _descriptionFor(
        category: _CareCategory.food,
        sources: sources,
        fallback: _foodFallback(report),
      ),
      priority: 0,
    ),
    _CareRecommendation(
      category: _CareCategory.exercise,
      description: _descriptionFor(
        category: _CareCategory.exercise,
        sources: sources,
        fallback: _exerciseFallback(summary),
      ),
      priority: 1,
    ),
    _CareRecommendation(
      category: _CareCategory.mind,
      description: _descriptionFor(
        category: _CareCategory.mind,
        sources: sources,
        fallback: _mindFallback(summary),
      ),
      priority: 2,
    ),
  ];

  recommendations.sort((a, b) {
    if (a.category == selectedCategory) {
      return -1;
    }
    if (b.category == selectedCategory) {
      return 1;
    }
    return a.priority.compareTo(b.priority);
  });

  return recommendations;
}

List<String> _sourcesFromGoalIds(List<String> goalIds) {
  final sources = <String>[];
  for (final goalId in goalIds) {
    switch (goalId) {
      case 'pms_relief':
        sources.addAll(['충분한 휴식', '가벼운 스트레칭', '따뜻한 찜질']);
        break;
      case 'sleep_stress_management':
        sources.addAll(['수면 루틴 유지', '명상 10분', '깊은 호흡']);
        break;
      case 'skin_body_management':
        sources.addAll(['수분 섭취', '균형 잡힌 식사']);
        break;
      case 'cycle_management':
      case 'women_disease_prevention':
        sources.add('증상 기록 지속');
        break;
    }
  }
  return sources;
}

String _descriptionFor({
  required _CareCategory category,
  required List<String> sources,
  required String fallback,
}) {
  final matched = sources
      .where((source) => _matchesCategory(source, category))
      .take(2)
      .toList();
  if (matched.isEmpty) {
    return fallback;
  }
  return matched.join(', ');
}

List<String> _safeSources(List<String> values) {
  return values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .where(_isSafeCareText)
      .map(_compactCareText)
      .where((value) => value.isNotEmpty)
      .toList();
}

bool _isSafeCareText(String value) {
  final unsafeWords = ['복용', '약', '영양제', '진단', '치료', '확진', '우울증', '처방', '예약'];
  return !unsafeWords.any(value.contains);
}

String _compactCareText(String value) {
  final normalized = value
      .replaceAll('규칙적인 수면 시간 유지', '수면 루틴 유지')
      .replaceAll('추천해요', '')
      .replaceAll('해보세요', '')
      .replaceAll('하세요', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (normalized.length <= 24) {
    return normalized;
  }
  return '${normalized.substring(0, 24).trim()}...';
}

bool _matchesCategory(String value, _CareCategory category) {
  final lower = value.toLowerCase();
  final keywords = switch (category) {
    _CareCategory.food => [
      '수분',
      '물',
      '차',
      '식사',
      '영양',
      '카페인',
      '따뜻',
      '균형',
      'meal',
      'hydration',
      'nutrition',
      'tea',
    ],
    _CareCategory.exercise => [
      '스트레칭',
      '산책',
      '요가',
      '운동',
      '필라테스',
      '걷기',
      '움직',
      'stretch',
      'walk',
      'yoga',
      'exercise',
    ],
    _CareCategory.mind => [
      '휴식',
      '명상',
      '호흡',
      '수면',
      '스트레스',
      '샤워',
      '루틴',
      '긴장',
      '마음',
      'rest',
      'meditation',
      'breathing',
      'sleep',
      'stress',
    ],
  };
  return keywords.any((keyword) => lower.contains(keyword.toLowerCase()));
}

String _foodFallback(HealthReport? report) {
  final factors = report?.mainFactors.join(' ') ?? '';
  if (factors.contains('통증') || factors.contains('피로')) {
    return '따뜻한 차, 수분 보충, 균형 식사';
  }
  return '연어, 아보카도, 견과류 참고';
}

String _exerciseFallback(AnalysisSummary summary) {
  if (summary.stressLevel == StressLevel.high) {
    return '가벼운 산책, 부드러운 스트레칭';
  }
  return '요가, 필라테스, 가벼운 스트레칭';
}

String _mindFallback(AnalysisSummary summary) {
  final sleepHours = summary.averageSleepHours;
  if (sleepHours != null && sleepHours < 6) {
    return '수면 루틴, 화면 사용 줄이기';
  }
  return '따뜻한 샤워, 명상 10분';
}

String _displayNickname(String? nickname) {
  final value = nickname?.trim() ?? '';
  if (value.isEmpty) {
    return '사용자님';
  }
  return value.endsWith('님') ? value : '$value님';
}

void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;
  final path = Path();

  for (var i = 0; i < 8; i++) {
    final angle = -math.pi / 2 + i * math.pi / 4;
    final currentRadius = i.isEven ? radius : radius * 0.22;
    final x = center.dx + math.cos(angle) * currentRadius;
    final y = center.dy + math.sin(angle) * currentRadius;
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }

  path.close();
  canvas.drawPath(path, paint);
}
