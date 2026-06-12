import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../state/record_controller.dart';
import '../../state/report_controller.dart';
import 'calendar_screen.dart';

class ConditionRecordScreen extends StatefulWidget {
  const ConditionRecordScreen({
    super.key,
    required this.recordController,
    required this.reportController,
    this.onClose,
    this.onComplete,
    this.onOpenReport,
  });

  final RecordController recordController;
  final ReportController reportController;
  final VoidCallback? onClose;
  final VoidCallback? onComplete;
  final VoidCallback? onOpenReport;

  @override
  State<ConditionRecordScreen> createState() => _ConditionRecordScreenState();
}

class _ConditionRecordScreenState extends State<ConditionRecordScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _cycleStartSelected = false;
  double _sleepHours = 0;
  int _sleepQuality = 6;
  int _painScore = 5;
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
          body: Container(
            decoration: BoxDecoration(
              color: Colors.white,
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
                              title: '생리 기록',
                              fontSize: sectionTitleSize,
                            ),
                            const SizedBox(height: 12),
                            _CycleStartToggle(
                              selected: _cycleStartSelected,
                              onChanged: (value) {
                                setState(() => _cycleStartSelected = value);
                              },
                            ),
                            SizedBox(height: height * 0.022),
                            _SectionTitle(
                              title: '수면 기록',
                              fontSize: sectionTitleSize,
                            ),
                            const SizedBox(height: 12),
                            _SleepRecordPanel(
                              sleepHours: _sleepHours,
                              qualityScore: _sleepQuality,
                              onSleepHoursChanged: (value) {
                                setState(() => _sleepHours = value);
                              },
                              onQualityChanged: (value) {
                                setState(() => _sleepQuality = value);
                              },
                            ),
                            SizedBox(height: height * 0.025),
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
                            if (_selectedSymptomIds.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _PainScorePanel(
                                painScore: _painScore,
                                onChanged: (value) {
                                  setState(() => _painScore = value);
                                },
                              ),
                            ],
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
    if (!_cycleStartSelected &&
        _sleepHours <= 0 &&
        _selectedSymptomIds.isEmpty &&
        _selectedEmotionIds.isEmpty) {
      _showSnackBar('오늘의 컨디션을 하나 이상 선택해주세요.');
      return;
    }

    final selectedSymptoms = _symptomOptions
        .where((option) => _selectedSymptomIds.contains(option.id))
        .toList();
    final selectedEmotions = _emotionOptions
        .where((option) => _selectedEmotionIds.contains(option.id))
        .toList();

    final recordedAt = _recordedAtForSelectedDate();
    final painDrafts = selectedSymptoms
        .where((option) => option.isSupportedByBackend)
        .map(
          (option) => ConditionPainDraft(
            painType: option.backendType!,
            painScore: _painScore,
            createdAt: recordedAt,
          ),
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
            createdAt: recordedAt,
          ),
        )
        .toList();

    final ok = await widget.recordController.createConditionRecords(
      recordDate: _dateKey(_selectedDate),
      cycleDraft: _cycleStartSelected
          ? ConditionCycleDraft(
              startDate: _dateKey(_selectedDate),
              memo: 'MORE Cycle 앱에서 기록한 생리 시작일',
            )
          : null,
      sleepDraft: _sleepHours > 0
          ? ConditionSleepDraft(
              sleepStart: _sleepStartForSelectedDate(),
              sleepEnd: _sleepEndForSelectedDate(),
              sleepHours: _sleepHours,
              qualityScore: _sleepQuality,
            )
          : null,
      painDrafts: painDrafts,
      emotionDrafts: emotionDrafts,
      unsupportedSymptoms: unsupportedSymptoms,
    );
    if (!mounted) {
      return;
    }
    if (ok) {
      await widget.reportController.generate();
      if (!mounted) {
        return;
      }
      _openCalendarScreen();
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

  void _openCalendarScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CalendarScreen(
          recordController: widget.recordController,
          reportController: widget.reportController,
          initialSelectedDate: _selectedDate,
          completedRecordDate: _selectedDate,
          onOpenReport: widget.onOpenReport,
          onComplete: widget.onComplete,
        ),
      ),
    );
    widget.recordController.loadLatestCycle();
    widget.recordController.loadLatestSleep();
  }

  String _formatKoreanDate(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.year}.${_twoDigits(date.month)}.${_twoDigits(date.day)} (${weekdays[date.weekday - 1]})';
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  DateTime _recordedAtForSelectedDate() {
    final now = DateTime.now();
    if (now.year == _selectedDate.year &&
        now.month == _selectedDate.month &&
        now.day == _selectedDate.day) {
      return now;
    }
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      12,
    );
  }

  DateTime _sleepEndForSelectedDate() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      7,
    );
  }

  DateTime _sleepStartForSelectedDate() {
    final minutes = (_sleepHours * 60).round();
    return _sleepEndForSelectedDate().subtract(Duration(minutes: minutes));
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

class _CycleStartToggle extends StatelessWidget {
  const _CycleStartToggle({required this.selected, required this.onChanged});

  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SoftInputPanel(
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: selected,
        activeThumbColor: AppColors.primaryPurple,
        title: const Text(
          '선택한 날짜를 생리 시작일로 저장',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        subtitle: const Text(
          '주기 예측과 PMS 위험도 계산에 반영돼요.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _SleepRecordPanel extends StatelessWidget {
  const _SleepRecordPanel({
    required this.sleepHours,
    required this.qualityScore,
    required this.onSleepHoursChanged,
    required this.onQualityChanged,
  });

  final double sleepHours;
  final int qualityScore;
  final ValueChanged<double> onSleepHoursChanged;
  final ValueChanged<int> onQualityChanged;

  @override
  Widget build(BuildContext context) {
    return _SoftInputPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SliderHeader(
            title: '수면 시간',
            value: sleepHours <= 0
                ? '기록 안 함'
                : '${sleepHours.toStringAsFixed(1)}시간',
          ),
          Slider(
            value: sleepHours,
            min: 0,
            max: 12,
            divisions: 24,
            activeColor: AppColors.primaryPurple,
            inactiveColor: const Color(0xFFE7DDF8),
            label: sleepHours <= 0
                ? '기록 안 함'
                : '${sleepHours.toStringAsFixed(1)}시간',
            onChanged: onSleepHoursChanged,
          ),
          const SizedBox(height: 4),
          _SliderHeader(title: '수면 질', value: '$qualityScore/10'),
          Slider(
            value: qualityScore.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            activeColor: AppColors.deepPurple,
            inactiveColor: const Color(0xFFE7DDF8),
            label: '$qualityScore/10',
            onChanged: (value) => onQualityChanged(value.round()),
          ),
        ],
      ),
    );
  }
}

class _PainScorePanel extends StatelessWidget {
  const _PainScorePanel({required this.painScore, required this.onChanged});

  final int painScore;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SoftInputPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SliderHeader(title: '통증 강도', value: '$painScore/10'),
          Slider(
            value: painScore.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            activeColor: AppColors.primaryPurple,
            inactiveColor: const Color(0xFFE7DDF8),
            label: '$painScore/10',
            onChanged: (value) => onChanged(value.round()),
          ),
        ],
      ),
    );
  }
}

class _SliderHeader extends StatelessWidget {
  const _SliderHeader({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryPurple,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _SoftInputPanel extends StatelessWidget {
  const _SoftInputPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5DDF6), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
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
                  child: _ConditionIconImage(
                    assetPath: assetPath,
                    circleSize: circleSize,
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

class _ConditionIconImage extends StatelessWidget {
  const _ConditionIconImage({
    required this.assetPath,
    required this.circleSize,
  });

  final String assetPath;
  final double circleSize;

  @override
  Widget build(BuildContext context) {
    final cropSize = circleSize * 0.86;
    final imageSize = circleSize * 1.24;

    return SizedBox(
      width: cropSize,
      height: cropSize,
      child: ClipOval(
        child: OverflowBox(
          minWidth: imageSize,
          maxWidth: imageSize,
          minHeight: imageSize,
          maxHeight: imageSize,
          child: Image.asset(
            assetPath,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.contain,
          ),
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
