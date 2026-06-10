import 'package:flutter/material.dart';

import '../../core/constants/app_text.dart';
import '../../core/utils/date_utils.dart';
import '../../models/health_report.dart';
import '../../state/report_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/disclaimer_box.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key, required this.reportController});

  final ReportController reportController;

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  @override
  void initState() {
    super.initState();
    widget.reportController.load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: widget.reportController,
        builder: (context, _) {
          final controller = widget.reportController;
          if (controller.loading && controller.latestReport == null) {
            return const LoadingView(message: '건강 리포트를 불러오는 중이에요.');
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionHeader(
                title: '분석',
                subtitle: '기록 기반 PMS 위험도와 건강 점수를 확인해요.',
              ),
              const SizedBox(height: 16),
              if (controller.errorMessage != null) ...[
                ErrorView(
                  message: controller.errorMessage!,
                  onRetry: controller.load,
                ),
                const SizedBox(height: 14),
              ],
              if (controller.latestReport == null)
                EmptyState(
                  message: '아직 생성된 건강 리포트가 없어요. 기록을 남긴 뒤 리포트를 생성해보세요.',
                  icon: Icons.auto_graph,
                )
              else
                _ReportDetail(report: controller.latestReport!),
              const SizedBox(height: 14),
              PrimaryButton(
                label: '건강 리포트 생성하기',
                icon: Icons.auto_graph,
                loading: controller.loading,
                onPressed: controller.generate,
              ),
              const SizedBox(height: 14),
              const DisclaimerBox(text: AppText.medicalDisclaimer),
              if (controller.history.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('리포트 기록', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ...controller.history
                    .take(5)
                    .map(
                      (report) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            '${report.createdAt == null ? '' : AppDateUtils.dateTime(report.createdAt!)}  ·  PMS ${report.pmsScore}점  ·  ${riskLabel(report.riskLevel)}',
                          ),
                        ),
                      ),
                    ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ReportDetail extends StatelessWidget {
  const _ReportDetail({required this.report});

  final HealthReport report;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _ScoreBox(
                  label: 'PMS 위험도',
                  value: '${report.pmsScore}',
                  caption: riskLabel(report.riskLevel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ScoreBox(
                  label: '건강 점수',
                  value: '${report.healthScore}',
                  caption: '100점 기준',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('위험도 ${riskLabel(report.riskLevel)}')),
              Chip(label: Text('신뢰도 ${confidenceLabel(report.confidence)}')),
              if (report.recommendedCategory != null)
                Chip(label: Text(categoryLabel(report.recommendedCategory!))),
            ],
          ),
          const SizedBox(height: 14),
          Text(report.summary),
          const SizedBox(height: 18),
          _BulletSection(title: '주요 요인', items: report.mainFactors),
          const SizedBox(height: 14),
          _BulletSection(title: '추천 케어', items: report.careTips),
          if (report.createdAt != null) ...[
            const SizedBox(height: 12),
            Text(
              '생성일 ${AppDateUtils.dateTime(report.createdAt!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  const _ScoreBox({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(caption, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Text('아직 충분한 항목이 없어요.')
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

String riskLabel(String value) {
  return switch (value) {
    'high' => '높음',
    'medium' => '보통',
    _ => '낮음',
  };
}

String confidenceLabel(String value) {
  return switch (value) {
    'high' => '높음',
    'medium' => '보통',
    _ => '낮음',
  };
}

String categoryLabel(String value) {
  return switch (value) {
    'WOMEN_HEALTH' => '여성 건강',
    'MENTAL_HEALTH' => '정신 건강',
    'PAIN_NEURO' => '통증/두통',
    'PUBLIC_HEALTH' => '공공 보건',
    _ => value,
  };
}
