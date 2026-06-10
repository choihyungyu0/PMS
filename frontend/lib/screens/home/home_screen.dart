import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../models/health_report.dart';
import '../../state/auth_controller.dart';
import '../../state/record_controller.dart';
import '../../state/report_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.authController,
    required this.recordController,
    required this.reportController,
    required this.onOpenRecord,
    required this.onOpenReport,
    required this.onOpenHospital,
  });

  final AuthController authController;
  final RecordController recordController;
  final ReportController reportController;
  final VoidCallback onOpenRecord;
  final VoidCallback onOpenReport;
  final VoidCallback onOpenHospital;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          recordController,
          reportController,
          authController,
        ]),
        builder: (context, _) {
          final user = authController.user;
          final report = reportController.latestReport;
          return RefreshIndicator(
            onRefresh: () async {
              await recordController.loadLatestCycle();
              await reportController.load();
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                SectionHeader(
                  title: '${user?.nickname ?? '사용자'}님, 오늘 몸 상태는 어때요?',
                  subtitle: '기록이 쌓일수록 더 안정적인 참고 정보를 볼 수 있어요.',
                ),
                const SizedBox(height: 16),
                _CycleCard(controller: recordController),
                const SizedBox(height: 14),
                _QuickRecordCard(onOpenRecord: onOpenRecord),
                const SizedBox(height: 14),
                if (report == null)
                  EmptyState(
                    message: '아직 기록이 부족해요. 오늘의 컨디션을 기록하면 더 정확한 분석을 받을 수 있어요.',
                    icon: Icons.insights_outlined,
                  )
                else
                  _ReportSummaryCard(report: report),
                const SizedBox(height: 14),
                if (report == null)
                  PrimaryButton(
                    label: '건강 리포트 생성하기',
                    icon: Icons.auto_graph,
                    loading: reportController.loading,
                    onPressed: () async {
                      await reportController.generate();
                      onOpenReport();
                    },
                  )
                else ...[
                  _CareTipCard(report: report),
                  if (report.riskLevel == 'medium' ||
                      report.riskLevel == 'high') ...[
                    const SizedBox(height: 14),
                    PrimaryButton(
                      label: '병원 정보 보기',
                      icon: Icons.local_hospital_outlined,
                      onPressed: onOpenHospital,
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CycleCard extends StatelessWidget {
  const _CycleCard({required this.controller});

  final RecordController controller;

  @override
  Widget build(BuildContext context) {
    final cycle = controller.latestCycle;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: Icons.calendar_month, title: '생리 주기'),
          const SizedBox(height: 8),
          Text(
            cycle == null
                ? '아직 등록된 생리 주기 기록이 없어요.'
                : '${AppDateUtils.date(cycle.startDate)} 시작${cycle.endDate == null ? '' : ' - ${AppDateUtils.date(cycle.endDate!)} 종료'}',
          ),
        ],
      ),
    );
  }
}

class _QuickRecordCard extends StatelessWidget {
  const _QuickRecordCard({required this.onOpenRecord});

  final VoidCallback onOpenRecord;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.lightPurpleCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: Icons.favorite_border, title: '오늘 컨디션'),
          const SizedBox(height: 8),
          const Text('감정, 수면, 통증을 빠르게 기록해보세요.'),
          const SizedBox(height: 14),
          PrimaryButton(
            label: '기록하러 가기',
            icon: Icons.edit_note,
            onPressed: onOpenRecord,
          ),
        ],
      ),
    );
  }
}

class _ReportSummaryCard extends StatelessWidget {
  const _ReportSummaryCard({required this.report});

  final HealthReport report;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: Icons.insights, title: 'AI 건강 분석 요약'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ScoreTile(
                  label: 'PMS 위험도',
                  value: '${report.pmsScore}',
                  caption: _riskLabel(report.riskLevel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ScoreTile(
                  label: '건강 점수',
                  value: '${report.healthScore}',
                  caption: '100점 기준',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(report.summary),
        ],
      ),
    );
  }
}

class _CareTipCard extends StatelessWidget {
  const _CareTipCard({required this.report});

  final HealthReport report;

  @override
  Widget build(BuildContext context) {
    final tip = report.careTips.isEmpty
        ? '충분한 휴식과 수분 섭취를 챙겨보세요.'
        : report.careTips.first;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: Icons.spa_outlined, title: '오늘의 추천 케어'),
          const SizedBox(height: 8),
          Text(tip),
        ],
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightPurpleCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          Text(
            caption,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryPurple),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

String _riskLabel(String value) {
  return switch (value) {
    'high' => '높음',
    'medium' => '보통',
    _ => '낮음',
  };
}
