import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../state/record_controller.dart';
import 'record_complete_screen.dart';

class ConditionRecordScreen extends StatefulWidget {
  const ConditionRecordScreen({
    super.key,
    required this.recordController,
    this.onClose,
    this.onComplete,
  });

  final RecordController recordController;
  final VoidCallback? onClose;
  final VoidCallback? onComplete;

  @override
  State<ConditionRecordScreen> createState() => _ConditionRecordScreenState();
}

class _ConditionRecordScreenState extends State<ConditionRecordScreen> {
  DateTime _selectedDate = DateTime.now();
  final Set<String> _selectedSymptomIds = {};
  final Set<String> _selectedEmotionIds = {};

  static const _symptomOptions = [
    _ConditionOption(
      id: 'abdominal_pain',
      label: '복통',
      assetPath: AppAssets.symptomAbdominalPain,
      backendType: 'abdominal_pain',
      isSupportedByBackend: true,
    ),
    _ConditionOption(
      id: 'headache',
      label: '두통',
      assetPath: AppAssets.symptomHeadache,
      backendType: 'headache',
      isSupportedByBackend: true,
    ),
    _ConditionOption(
      id: 'fatigue',
      label: '피로',
      assetPath: AppAssets.symptomFatigue,
      isSupportedByBackend: false,
    ),
    _ConditionOption(
      id: 'breast_pain',
      label: '유방통',
      assetPath: AppAssets.symptomBreastPain,
      backendType: 'breast_pain',
      isSupportedByBackend: true,
    ),
    _ConditionOption(
      id: 'dizziness',
      label: '어지럼',
      assetPath: AppAssets.symptomDizziness,
      isSupportedByBackend: false,
    ),
    _ConditionOption(
      id: 'swelling',
      label: '부종',
      assetPath: AppAssets.symptomSwelling,
      isSupportedByBackend: false,
    ),
  ];

  static const _emotionOptions = [
    _ConditionOption(
      id: 'sad',
      label: '우울',
      assetPath: AppAssets.emotionSad,
      backendType: 'sad',
      intensity: 3,
      isSupportedByBackend: true,
    ),
    _ConditionOption(
      id: 'sensitive',
      label: '예민',
      assetPath: AppAssets.emotionSensitive,
      backendType: 'irritated',
      intensity: 3,
      isSupportedByBackend: true,
    ),
    _ConditionOption(
      id: 'calm',
      label: '평온',
      assetPath: AppAssets.emotionCalm,
      backendType: 'calm',
      intensity: 3,
      isSupportedByBackend: true,
    ),
    _ConditionOption(
      id: 'irritated',
      label: '짜증',
      assetPath: AppAssets.emotionIrritated,
      backendType: 'angry',
      intensity: 4,
      isSupportedByBackend: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.recordController,
      builder: (context, _) {
        final loading = widget.recordController.loading;

        return Scaffold(
          backgroundColor: AppColors.lavenderBackground,
          body: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFE2D8F4), width: 2),
              ),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = constraints.maxHeight;
                    final horizontalPadding = (width * 0.075)
                        .clamp(28.0, 42.0)
                        .toDouble();
                    final titleSize = (width * 0.095)
                        .clamp(34.0, 44.0)
                        .toDouble();
                    final sectionTitleSize = (width * 0.068)
                        .clamp(25.0, 32.0)
                        .toDouble();
                    final dateTextSize = (width * 0.055)
                        .clamp(20.0, 26.0)
                        .toDouble();
                    final symptomCircleSize = (width * 0.235)
                        .clamp(82.0, 110.0)
                        .toDouble();
                    final emotionCircleSize = (width * 0.185)
                        .clamp(66.0, 88.0)
                        .toDouble();
                    final buttonHeight = (height * 0.075)
                        .clamp(58.0, 72.0)
                        .toDouble();

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: height * 0.010),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _CloseButton(onTap: _handleClose),
                              ),
                              SizedBox(height: height * 0.010),
                              Text(
                                '오늘의 컨디션은\n어떤가요?',
                                style: TextStyle(
                                  color: const Color(0xFF111111),
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0,
                                  height: 1.24,
                                ),
                              ),
                              SizedBox(height: height * 0.025),
                              _DateRow(
                                value: _formatKoreanDate(_selectedDate),
                                fontSize: dateTextSize,
                                onTap: _pickDate,
                              ),
                              SizedBox(height: height * 0.030),
                              _SectionTitle(
                                title: '신체 증상',
                                fontSize: sectionTitleSize,
                              ),
                              const SizedBox(height: 12),
                              _ConditionGrid(
                                options: _symptomOptions,
                                selectedIds: _selectedSymptomIds,
                                crossAxisCount: 3,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 22,
                                circleSize: symptomCircleSize,
                                labelFontSize: 19,
                                onTap: _toggleSymptom,
                              ),
                              SizedBox(height: height * 0.015),
                              _SectionTitle(
                                title: '감정 상태',
                                fontSize: sectionTitleSize,
                              ),
                              const SizedBox(height: 12),
                              _ConditionGrid(
                                options: _emotionOptions,
                                selectedIds: _selectedEmotionIds,
                                crossAxisCount: 4,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                circleSize: emotionCircleSize,
                                labelFontSize: 18,
                                onTap: _toggleEmotion,
                              ),
                              SizedBox(height: height * 0.022),
                              _GradientSaveButton(
                                height: buttonHeight,
                                loading: loading,
                                onTap: loading ? null : _save,
                              ),
                              SizedBox(height: height * 0.024),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleClose() {
    if (widget.onClose != null) {
      widget.onClose!();
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _selectedDate = picked);
  }

  void _toggleSymptom(String id) {
    setState(() {
      if (_selectedSymptomIds.contains(id)) {
        _selectedSymptomIds.remove(id);
      } else {
        _selectedSymptomIds.add(id);
      }
    });
  }

  void _toggleEmotion(String id) {
    setState(() {
      if (_selectedEmotionIds.contains(id)) {
        _selectedEmotionIds.remove(id);
      } else {
        _selectedEmotionIds.add(id);
      }
    });
  }

  Future<void> _save() async {
    if (_selectedSymptomIds.isEmpty && _selectedEmotionIds.isEmpty) {
      _showSnackBar('오늘의 컨디션을 하나 이상 선택해주세요.');
      return;
    }

    final selectedSymptoms = _symptomOptions
        .where((option) => _selectedSymptomIds.contains(option.id))
        .toList();
    final selectedEmotions = _emotionOptions
        .where((option) => _selectedEmotionIds.contains(option.id))
        .toList();

    // TODO: Add a pain severity selector; the MVP uses a neutral default.
    final painDrafts = selectedSymptoms
        .where((option) => option.isSupportedByBackend)
        .map(
          (option) =>
              ConditionPainDraft(painType: option.backendType!, painScore: 5),
        )
        .toList();
    final unsupportedSymptoms = selectedSymptoms
        .where((option) => !option.isSupportedByBackend)
        .map(
          (option) => ConditionUnsupportedSymptomDraft(
            id: option.id,
            label: option.label,
          ),
        )
        .toList();
    final emotionDrafts = selectedEmotions
        .map(
          (option) => ConditionEmotionDraft(
            emotionType: option.backendType!,
            intensity: option.intensity,
          ),
        )
        .toList();

    final ok = await widget.recordController.createConditionRecords(
      recordDate: _dateKey(_selectedDate),
      painDrafts: painDrafts,
      emotionDrafts: emotionDrafts,
      unsupportedSymptoms: unsupportedSymptoms,
    );
    if (!mounted) {
      return;
    }
    if (ok) {
      _openCompleteScreen();
      return;
    }
    _showSnackBar(
      widget.recordController.errorMessage ?? '컨디션 저장에 실패했어요. 잠시 후 다시 시도해주세요.',
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryPurple,
      ),
    );
  }

  void _openCompleteScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecordCompleteScreen(
          onGoHome: () {
            widget.recordController.loadLatestCycle();
            widget.recordController.loadLatestSleep();
            widget.onComplete?.call();
          },
        ),
      ),
    );
  }

  String _formatKoreanDate(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.year}.${_twoDigits(date.month)}.${_twoDigits(date.day)} (${weekdays[date.weekday - 1]})';
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.value,
    required this.fontSize,
    required this.onTap,
  });

  final String value;
  final double fontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '날짜',
              style: TextStyle(
                color: const Color(0xFF3F3F43),
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: const Color(0xFF3F3F43),
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.fontSize});

  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: const Color(0xFF111111),
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

class _ConditionGrid extends StatelessWidget {
  const _ConditionGrid({
    required this.options,
    required this.selectedIds,
    required this.crossAxisCount,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.circleSize,
    required this.labelFontSize,
    required this.onTap,
  });

  final List<_ConditionOption> options;
  final Set<String> selectedIds;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double circleSize;
  final double labelFontSize;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        mainAxisExtent: circleSize + 34,
      ),
      itemBuilder: (context, index) {
        final option = options[index];
        return _ConditionOptionTile(
          label: option.label,
          assetPath: option.assetPath,
          circleSize: circleSize,
          labelFontSize: labelFontSize,
          isSelected: selectedIds.contains(option.id),
          onTap: () => onTap(option.id),
        );
      },
    );
  }
}

class _ConditionOptionTile extends StatelessWidget {
  const _ConditionOptionTile({
    required this.label,
    required this.assetPath,
    required this.circleSize,
    required this.labelFontSize,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String assetPath;
  final double circleSize;
  final double labelFontSize;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFFF6F0FF)
                      : const Color(0xFFFCFBFF),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryPurple
                        : const Color(0xFFE5DDF6),
                    width: isSelected ? 2.4 : 1.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.primaryPurple.withValues(alpha: 0.14)
                          : Colors.black.withValues(alpha: 0.035),
                      blurRadius: isSelected ? 18 : 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    assetPath,
                    width: circleSize * 0.96,
                    height: circleSize * 0.96,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: const Color(0xFF4B4B50),
                fontSize: labelFontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
                height: 1,
              ),
            ),
          ),
        ],
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
            width: 50,
            height: 50,
            child: Icon(Icons.close_rounded, color: Colors.black, size: 38),
          ),
        ),
      ),
    );
  }
}

class _GradientSaveButton extends StatelessWidget {
  const _GradientSaveButton({
    required this.height,
    required this.loading,
    required this.onTap,
  });

  final double height;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '저장하기',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: loading
                    ? const [Color(0xFFB8A9F6), Color(0xFF9F8CEF)]
                    : const [
                        Color(0xFF7A35F4),
                        Color(0xFF6532EF),
                        Color(0xFF5C2BE8),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6532EF).withValues(alpha: 0.24),
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
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '저장하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
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

class _ConditionOption {
  const _ConditionOption({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.isSupportedByBackend,
    this.backendType,
    this.intensity = 0,
  });

  final String id;
  final String label;
  final String assetPath;
  final bool isSupportedByBackend;
  final String? backendType;
  final int intensity;
}
