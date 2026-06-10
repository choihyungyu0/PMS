import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../state/record_controller.dart';
import '../../state/report_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/error_view.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({
    super.key,
    required this.recordController,
    required this.reportController,
    required this.onOpenReport,
  });

  final RecordController recordController;
  final ReportController reportController;
  final VoidCallback onOpenReport;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: SectionHeader(title: '기록', subtitle: '오늘의 컨디션을 짧게 남겨보세요.'),
            ),
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: '생리'),
                Tab(text: '감정'),
                Tab(text: '수면'),
                Tab(text: '통증'),
              ],
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.recordController,
                builder: (context, _) {
                  return TabBarView(
                    children: [
                      _CycleForm(controller: widget.recordController),
                      _EmotionForm(controller: widget.recordController),
                      _SleepForm(controller: widget.recordController),
                      _PainForm(controller: widget.recordController),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: PrimaryButton(
                label: '건강 리포트 생성하기',
                icon: Icons.auto_graph,
                loading: widget.reportController.loading,
                onPressed: () async {
                  await widget.reportController.generate();
                  if (mounted) widget.onOpenReport();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CycleForm extends StatefulWidget {
  const _CycleForm({required this.controller});

  final RecordController controller;

  @override
  State<_CycleForm> createState() => _CycleFormState();
}

class _CycleFormState extends State<_CycleForm> {
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  final _memoController = TextEditingController();

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormList(
      controller: widget.controller,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateButton(
              label: '시작일',
              value: _startDate,
              onTap: () => _pickStart(context),
            ),
            const SizedBox(height: 10),
            _DateButton(
              label: '종료일 선택',
              value: _endDate,
              onTap: () => _pickEnd(context),
              optional: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _memoController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: '메모'),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: '생리 주기 저장',
              loading: widget.controller.loading,
              onPressed: () async {
                final ok = await widget.controller.createCycle(
                  AppDateUtils.date(_startDate),
                  _endDate == null ? null : AppDateUtils.date(_endDate!),
                  _memoController.text.trim(),
                );
                if (ok && context.mounted) {
                  _showSuccess(context, widget.controller.successMessage);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStart(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEnd(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }
}

class _EmotionForm extends StatefulWidget {
  const _EmotionForm({required this.controller});

  final RecordController controller;

  @override
  State<_EmotionForm> createState() => _EmotionFormState();
}

class _EmotionFormState extends State<_EmotionForm> {
  String _emotionType = 'calm';
  double _intensity = 3;

  @override
  Widget build(BuildContext context) {
    return _FormList(
      controller: widget.controller,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: emotionLabels.entries.map((entry) {
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: _emotionType == entry.key,
                  onSelected: (_) => setState(() => _emotionType = entry.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Text('강도 ${_intensity.round()} / 5'),
            Slider(
              value: _intensity,
              min: 1,
              max: 5,
              divisions: 4,
              label: '${_intensity.round()}',
              onChanged: (value) => setState(() => _intensity = value),
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: '감정 저장',
              loading: widget.controller.loading,
              onPressed: () async {
                final ok = await widget.controller.createEmotion(
                  _emotionType,
                  _intensity.round(),
                );
                if (ok && context.mounted) {
                  _showSuccess(context, widget.controller.successMessage);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SleepForm extends StatefulWidget {
  const _SleepForm({required this.controller});

  final RecordController controller;

  @override
  State<_SleepForm> createState() => _SleepFormState();
}

class _SleepFormState extends State<_SleepForm> {
  late DateTime _sleepStart;
  late DateTime _sleepEnd;
  double _quality = 7;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _sleepStart = DateTime(now.year, now.month, now.day - 1, 23);
    _sleepEnd = DateTime(now.year, now.month, now.day, 7);
  }

  @override
  Widget build(BuildContext context) {
    final hours = _sleepEnd.difference(_sleepStart).inMinutes / 60;
    return _FormList(
      controller: widget.controller,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateTimeButton(
              label: '잠든 시간',
              value: _sleepStart,
              onTap: () => _pickDateTime(true),
            ),
            const SizedBox(height: 10),
            _DateTimeButton(
              label: '일어난 시간',
              value: _sleepEnd,
              onTap: () => _pickDateTime(false),
            ),
            const SizedBox(height: 14),
            Text('수면 시간 ${hours <= 0 ? 0 : hours.toStringAsFixed(1)}시간'),
            const SizedBox(height: 12),
            Text('수면 질 ${_quality.round()} / 10'),
            Slider(
              value: _quality,
              min: 0,
              max: 10,
              divisions: 10,
              label: '${_quality.round()}',
              onChanged: (value) => setState(() => _quality = value),
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: '수면 저장',
              loading: widget.controller.loading,
              onPressed: hours <= 0
                  ? null
                  : () async {
                      final ok = await widget.controller.createSleep(
                        _sleepStart,
                        _sleepEnd,
                        hours,
                        _quality.round(),
                      );
                      if (ok && context.mounted) {
                        _showSuccess(context, widget.controller.successMessage);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime(bool start) async {
    final current = start ? _sleepStart : _sleepEnd;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null) {
      return;
    }
    final value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (start) {
        _sleepStart = value;
      } else {
        _sleepEnd = value;
      }
    });
  }
}

class _PainForm extends StatefulWidget {
  const _PainForm({required this.controller});

  final RecordController controller;

  @override
  State<_PainForm> createState() => _PainFormState();
}

class _PainFormState extends State<_PainForm> {
  String _painType = 'menstrual_cramp';
  double _painScore = 4;
  final _memoController = TextEditingController();

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormList(
      controller: widget.controller,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: painLabels.entries.map((entry) {
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: _painType == entry.key,
                  onSelected: (_) => setState(() => _painType = entry.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Text('통증 점수 ${_painScore.round()} / 10'),
            Slider(
              value: _painScore,
              min: 0,
              max: 10,
              divisions: 10,
              label: '${_painScore.round()}',
              onChanged: (value) => setState(() => _painScore = value),
            ),
            TextField(
              controller: _memoController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: '메모'),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: '통증 저장',
              loading: widget.controller.loading,
              onPressed: () async {
                final ok = await widget.controller.createPain(
                  _painType,
                  _painScore.round(),
                  _memoController.text.trim(),
                );
                if (ok && context.mounted) {
                  _showSuccess(context, widget.controller.successMessage);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FormList extends StatelessWidget {
  const _FormList({required this.controller, required this.child});

  final RecordController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (controller.errorMessage != null) ...[
          ErrorView(message: controller.errorMessage!),
          const SizedBox(height: 12),
        ],
        child,
      ],
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
    this.optional = false,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.calendar_today),
      label: Text(
        value == null
            ? '$label${optional ? ' (선택)' : ''}'
            : '$label: ${AppDateUtils.date(value!)}',
      ),
    );
  }
}

class _DateTimeButton extends StatelessWidget {
  const _DateTimeButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.schedule),
      label: Text('$label: ${AppDateUtils.dateTime(value)}'),
    );
  }
}

void _showSuccess(BuildContext context, String? message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message ?? '저장했어요.'),
      backgroundColor: AppColors.primaryPurple,
    ),
  );
}

const emotionLabels = {
  'happy': '행복',
  'calm': '평온',
  'anxious': '불안',
  'sad': '우울',
  'angry': '분노',
  'irritated': '짜증',
  'tired': '피곤',
};

const painLabels = {
  'menstrual_cramp': '생리통',
  'headache': '두통',
  'abdominal_pain': '복통',
  'back_pain': '허리 통증',
  'breast_pain': '가슴 통증',
  'other': '기타',
};
