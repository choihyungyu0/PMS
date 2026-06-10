import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text.dart';
import '../../models/medical_institution.dart';
import '../../state/institution_controller.dart';
import '../../state/report_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/disclaimer_box.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/section_header.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({
    super.key,
    required this.institutionController,
    required this.reportController,
  });

  final InstitutionController institutionController;
  final ReportController reportController;

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  final _keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.institutionController.loadInitial(
        reportCategory:
            widget.reportController.latestReport?.recommendedCategory,
      );
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          widget.institutionController,
          widget.reportController,
        ]),
        builder: (context, _) {
          final controller = widget.institutionController;
          if (controller.loading && controller.searchItems.isEmpty) {
            return const LoadingView(message: '의료기관 정보를 불러오는 중이에요.');
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionHeader(
                title: '병원',
                subtitle: '인천 공공데이터 기반 의료기관 정보를 확인해요.',
              ),
              const SizedBox(height: 16),
              const DisclaimerBox(text: AppText.hospitalDisclaimer),
              const SizedBox(height: 12),
              const DisclaimerBox(
                text: AppText.availabilityNotice,
                warning: true,
              ),
              const SizedBox(height: 16),
              _CategoryChips(controller: controller),
              const SizedBox(height: 12),
              if (controller.sigunguOptions.isNotEmpty)
                DropdownButtonFormField<String?>(
                  initialValue: controller.selectedSigungu,
                  decoration: const InputDecoration(labelText: '지역 선택'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('전체 지역'),
                    ),
                    ...controller.sigunguOptions.map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    ),
                  ],
                  onChanged: controller.setSigungu,
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _keywordController,
                decoration: InputDecoration(
                  labelText: '기관명, 진료과, 주소 검색',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () =>
                        controller.setKeyword(_keywordController.text.trim()),
                  ),
                ),
                onSubmitted: (value) => controller.setKeyword(value.trim()),
              ),
              const SizedBox(height: 16),
              if (controller.errorMessage != null) ...[
                ErrorView(
                  message: controller.errorMessage!,
                  onRetry: controller.loadInitial,
                ),
                const SizedBox(height: 12),
              ],
              if (controller.recommendation?.reason.isNotEmpty == true) ...[
                AppCard(
                  color: AppColors.lightPurpleCard,
                  padding: const EdgeInsets.all(14),
                  child: Text(controller.recommendation!.reason),
                ),
                const SizedBox(height: 12),
              ],
              if (controller.searchItems.isEmpty)
                const EmptyState(
                  message: '병원 정보가 없습니다. 다른 증상 유형이나 지역을 선택해보세요.',
                  icon: Icons.local_hospital_outlined,
                )
              else
                ...controller.searchItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _InstitutionCard(item: item),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.controller});

  final InstitutionController controller;

  @override
  Widget build(BuildContext context) {
    final categories = controller.categories.isEmpty
        ? const ['WOMEN_HEALTH', 'MENTAL_HEALTH', 'PUBLIC_HEALTH', 'PAIN_NEURO']
        : controller.categories;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('전체'),
          selected: controller.selectedCategory == null,
          onSelected: (_) => controller.selectCategory(null),
        ),
        ...categories.map(
          (category) => ChoiceChip(
            label: Text(categoryLabel(category)),
            selected: controller.selectedCategory == category,
            onSelected: (_) => controller.selectCategory(category),
          ),
        ),
      ],
    );
  }
}

class _InstitutionCard extends StatelessWidget {
  const _InstitutionCard({required this.item});

  final MedicalInstitution item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(label: Text(categoryLabel(item.serviceCategory))),
              if (item.distanceKm != null)
                Chip(label: Text('${item.distanceKm!.toStringAsFixed(1)}km')),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.institutionName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          if (_notEmpty(item.institutionType)) Text(item.institutionType!),
          if (_notEmpty(item.department)) Text('진료/분야: ${item.department}'),
          if (_notEmpty(item.address)) Text('주소: ${item.address}'),
          if (_notEmpty(item.sigungu)) Text('지역: ${item.sigungu}'),
          if (_notEmpty(item.phone)) Text('전화: ${item.phone}'),
          const SizedBox(height: 10),
          const Text(
            AppText.availabilityNotice,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

bool _notEmpty(String? value) => value != null && value.isNotEmpty;

String categoryLabel(String value) {
  return switch (value) {
    'WOMEN_HEALTH' => '여성 건강',
    'MENTAL_HEALTH' => '정신 건강',
    'PAIN_NEURO' => '통증/두통',
    'PUBLIC_HEALTH' => '공공 보건',
    _ => value,
  };
}
