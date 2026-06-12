import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text.dart';
import '../../models/medical_institution.dart';
import '../../state/institution_controller.dart';
import '../../state/report_controller.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';

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
  _GuideFilter _selectedFilter = _GuideFilter.all;

  @override
  void initState() {
    super.initState();
    final reportCategory =
        widget.reportController.latestReport?.recommendedCategory;
    _selectedFilter = _guideFilterForCategory(reportCategory);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.institutionController.loadInitial(reportCategory: reportCategory);
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _submitSearch() async {
    setState(() => _selectedFilter = _GuideFilter.all);
    await widget.institutionController.setKeyword(
      _keywordController.text.trim(),
    );
  }

  Future<void> _selectFilter(_GuideFilter filter) async {
    setState(() => _selectedFilter = filter);
    if (filter == _GuideFilter.pharmacy || filter == _GuideFilter.emergency) {
      return;
    }
    await widget.institutionController.selectCategory(filter.serviceCategory);
  }

  void _showNearbyNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('현재 위치 기능은 아직 연결되지 않았어요. 기관명 또는 지역명으로 검색해주세요.'),
      ),
    );
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
          final showsUnavailableCategory =
              _selectedFilter == _GuideFilter.pharmacy ||
              _selectedFilter == _GuideFilter.emergency;
          final visibleItems = showsUnavailableCategory
              ? const <MedicalInstitution>[]
              : controller.searchItems;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFDFCFF), Color(0xFFF5EEFF)],
              ),
            ),
            child: ListView(
              cacheExtent: 1800,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                const _HospitalHero(),
                const SizedBox(height: 18),
                _HospitalSearchField(
                  controller: _keywordController,
                  loading: controller.loading,
                  onSearch: _submitSearch,
                ),
                const SizedBox(height: 18),
                _GuideFilterBar(
                  selectedFilter: _selectedFilter,
                  onSelected: _selectFilter,
                ),
                const SizedBox(height: 18),
                _GuideCard(
                  title: '의료기관',
                  subtitle: '병원 · 의원 · 전문 진료기관',
                  badgeText: 'CSV 안내',
                  badgeIcon: Icons.location_on_rounded,
                  imageAsset: AppAssets.hospitalMedicalInstitution,
                  shieldAsset: AppAssets.hospitalShieldPurple,
                  palette: _GuidePalette.medical,
                  imageSide: _GuideImageSide.left,
                  selected: _selectedFilter == _GuideFilter.medical,
                  onTap: () => _selectFilter(_GuideFilter.medical),
                ),
                const SizedBox(height: 14),
                _GuideCard(
                  title: '보건기관',
                  subtitle: '보건소 · 보건지소 · 건강 지원 서비스',
                  badgeText: '공공 지원',
                  badgeIcon: Icons.eco_rounded,
                  imageAsset: AppAssets.hospitalPublicInstitution,
                  shieldAsset: AppAssets.hospitalShieldMint,
                  palette: _GuidePalette.publicHealth,
                  imageSide: _GuideImageSide.right,
                  selected: _selectedFilter == _GuideFilter.publicHealth,
                  onTap: () => _selectFilter(_GuideFilter.publicHealth),
                ),
                const SizedBox(height: 14),
                _GuideCard(
                  title: '약국',
                  subtitle: '약국 정보 · 방문 전 전화 확인',
                  badgeText: '전화 확인',
                  badgeIcon: Icons.access_time_rounded,
                  imageAsset: AppAssets.hospitalPharmacy,
                  shieldAsset: AppAssets.hospitalShieldBlue,
                  palette: _GuidePalette.pharmacy,
                  imageSide: _GuideImageSide.left,
                  selected: _selectedFilter == _GuideFilter.pharmacy,
                  onTap: () => _selectFilter(_GuideFilter.pharmacy),
                ),
                const SizedBox(height: 14),
                _GuideCard(
                  title: '응급기관',
                  subtitle: '응급의료기관 · 긴급 문의 안내',
                  badgeText: '의료진 문의',
                  badgeIcon: Icons.notifications_active_outlined,
                  imageAsset: AppAssets.hospitalEmergency,
                  shieldAsset: AppAssets.hospitalShieldRed,
                  palette: _GuidePalette.emergency,
                  imageSide: _GuideImageSide.right,
                  selected: _selectedFilter == _GuideFilter.emergency,
                  onTap: () => _selectFilter(_GuideFilter.emergency),
                ),
                const SizedBox(height: 18),
                _NearbyButton(onPressed: _showNearbyNotice),
                const SizedBox(height: 14),
                const _HospitalSafetyNotice(),
                const SizedBox(height: 18),
                _ResultsSection(
                  controller: controller,
                  items: visibleItems,
                  selectedFilter: _selectedFilter,
                  showsUnavailableCategory: showsUnavailableCategory,
                  onRetry: () => controller.loadInitial(
                    reportCategory: widget
                        .reportController
                        .latestReport
                        ?.recommendedCategory,
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

class _HospitalHero extends StatelessWidget {
  const _HospitalHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 232,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -38,
            bottom: 0,
            child: Opacity(
              opacity: 0.82,
              child: Image.asset(
                AppAssets.hospitalIncheonSkyline,
                width: 280,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    _TopSymbolButton(
                      icon: Icons.health_and_safety_rounded,
                      boxed: true,
                    ),
                    Spacer(),
                    _TopSymbolButton(icon: Icons.search_rounded),
                    SizedBox(width: 14),
                    _TopSymbolButton(icon: Icons.location_on_outlined),
                  ],
                ),
                const Spacer(),
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '인천 의료·보건 안내',
                    style: TextStyle(
                      color: Color(0xFF241064),
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                      height: 1.08,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '의료기관 · 보건기관 · 약국 · 응급기관',
                  style: TextStyle(
                    color: Color(0xFF4D3D74),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopSymbolButton extends StatelessWidget {
  const _TopSymbolButton({required this.icon, this.boxed = false});

  final IconData icon;
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: boxed ? 58 : 56,
      height: boxed ? 58 : 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(boxed ? 20 : 28),
        border: Border.all(color: const Color(0xFFECE2FF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7750E8).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF2A116C), size: boxed ? 34 : 31),
    );
  }
}

class _HospitalSearchField extends StatelessWidget {
  const _HospitalSearchField({
    required this.controller,
    required this.loading,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE1D5FF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8C68E8).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onSearch(),
        style: const TextStyle(
          color: Color(0xFF241064),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          filled: false,
          hintText: '기관명 또는 지역 검색',
          hintStyle: const TextStyle(
            color: Color(0xFF7B728B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF5F5874),
            size: 34,
          ),
          suffixIcon: loading
              ? const Padding(
                  padding: EdgeInsets.all(18),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                )
              : IconButton(
                  onPressed: onSearch,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  color: AppColors.primaryPurple,
                ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

class _GuideFilterBar extends StatelessWidget {
  const _GuideFilterBar({
    required this.selectedFilter,
    required this.onSelected,
  });

  final _GuideFilter selectedFilter;
  final ValueChanged<_GuideFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _GuideFilter.values.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _GuideFilterPill(
              label: filter.label,
              selected: filter == selectedFilter,
              onTap: () => onSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GuideFilterPill extends StatelessWidget {
  const _GuideFilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          height: 52,
          constraints: const BoxConstraints(minWidth: 82),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFFA95BFF), Color(0xFF6E2FDF)],
                  )
                : null,
            color: selected ? null : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7E42EA)
                  : const Color(0xFFE0D7F2),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (selected
                            ? const Color(0xFF6D32E2)
                            : const Color(0xFF8778A8))
                        .withValues(alpha: selected ? 0.25 : 0.12),
                blurRadius: selected ? 18 : 12,
                offset: Offset(0, selected ? 8 : 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF28135E),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeIcon,
    required this.imageAsset,
    required this.shieldAsset,
    required this.palette,
    required this.imageSide,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String badgeText;
  final IconData badgeIcon;
  final String imageAsset;
  final String shieldAsset;
  final _GuidePalette palette;
  final _GuideImageSide imageSide;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isImageLeft = imageSide == _GuideImageSide.left;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 176,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: palette.background,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: selected ? palette.accent : palette.border,
              width: selected ? 2 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: palette.shadow.withValues(alpha: selected ? 0.24 : 0.15),
                blurRadius: selected ? 24 : 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              children: [
                Positioned(
                  left: isImageLeft ? 4 : null,
                  right: isImageLeft ? null : 60,
                  bottom: isImageLeft ? -2 : -8,
                  child: Image.asset(
                    imageAsset,
                    width: isImageLeft ? 142 : 136,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 18,
                  child: Image.asset(shieldAsset, width: 42, height: 42),
                ),
                Positioned(
                  top: 22,
                  bottom: 18,
                  left: isImageLeft ? 146 : 22,
                  right: isImageLeft ? 76 : 158,
                  child: _GuideCardCopy(
                    title: title,
                    subtitle: subtitle,
                    badgeText: badgeText,
                    badgeIcon: badgeIcon,
                    palette: palette,
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 55,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      border: Border.all(color: palette.border),
                      boxShadow: [
                        BoxShadow(
                          color: palette.shadow.withValues(alpha: 0.16),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: palette.accent,
                      size: 36,
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

class _GuideCardCopy extends StatelessWidget {
  const _GuideCardCopy({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeIcon,
    required this.palette,
  });

  final String title;
  final String subtitle;
  final String badgeText;
  final IconData badgeIcon;
  final _GuidePalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            maxLines: 1,
            style: TextStyle(
              color: palette.title,
              fontSize: 29,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF241064),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        _GuideBadge(text: badgeText, icon: badgeIcon, palette: palette),
      ],
    );
  }
}

class _GuideBadge extends StatelessWidget {
  const _GuideBadge({
    required this.text,
    required this.icon,
    required this.palette,
  });

  final String text;
  final IconData icon;
  final _GuidePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: palette.badge,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: palette.accent, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: palette.badgeText,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyButton extends StatelessWidget {
  const _NearbyButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFB760FF), Color(0xFF6221D3)],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFC08DFF), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B1CC5).withValues(alpha: 0.30),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_rounded, color: Colors.white, size: 33),
              SizedBox(width: 12),
              Text(
                '내 주변 기관 찾기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.chevron_right_rounded, color: Colors.white, size: 34),
            ],
          ),
        ),
      ),
    );
  }
}

class _HospitalSafetyNotice extends StatelessWidget {
  const _HospitalSafetyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3D9F5)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.medicalDisclaimer,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              height: 1.35,
            ),
          ),
          SizedBox(height: 6),
          Text(
            AppText.availabilityNotice,
            style: TextStyle(
              color: Color(0xFF7B5D1E),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsSection extends StatelessWidget {
  const _ResultsSection({
    required this.controller,
    required this.items,
    required this.selectedFilter,
    required this.showsUnavailableCategory,
    required this.onRetry,
  });

  final InstitutionController controller;
  final List<MedicalInstitution> items;
  final _GuideFilter selectedFilter;
  final bool showsUnavailableCategory;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (controller.errorMessage != null && !showsUnavailableCategory) {
      return ErrorView(message: controller.errorMessage!, onRetry: onRetry);
    }

    if (showsUnavailableCategory) {
      return _UnavailableDataCard(filter: selectedFilter);
    }

    if (controller.loading && items.isEmpty) {
      return const _ResultMessageCard(
        icon: Icons.local_hospital_outlined,
        title: '의료기관 정보를 불러오는 중이에요',
        message: '제공된 CSV 데이터를 기준으로 조회하고 있어요.',
        loading: true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'CSV 기반 검색 결과',
              style: TextStyle(
                color: Color(0xFF241064),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const Spacer(),
            Text(
              '${items.length}곳',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        if (controller.recommendation?.reason.isNotEmpty == true) ...[
          const SizedBox(height: 10),
          Text(
            controller.recommendation!.reason,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (items.isEmpty)
          const EmptyState(
            message: '병원 정보가 없습니다. 다른 증상 유형이나 지역을 선택해보세요.',
            icon: Icons.local_hospital_outlined,
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InstitutionResultCard(item: item),
            ),
          ),
      ],
    );
  }
}

class _UnavailableDataCard extends StatelessWidget {
  const _UnavailableDataCard({required this.filter});

  final _GuideFilter filter;

  @override
  Widget build(BuildContext context) {
    return _ResultMessageCard(
      icon: filter == _GuideFilter.pharmacy
          ? Icons.local_pharmacy_outlined
          : Icons.emergency_outlined,
      title: '${filter.label} 데이터 확인이 필요해요',
      message:
          '현재 제공된 CSV에는 ${filter.label} 전용 데이터가 포함되어 있지 않아요. 의료기관 또는 보건기관으로 검색해주세요.',
    );
  }
}

class _ResultMessageCard extends StatelessWidget {
  const _ResultMessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4D8F8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.lightPurpleCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(11),
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : Icon(icon, color: AppColors.primaryPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF241064),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstitutionResultCard extends StatelessWidget {
  const _InstitutionResultCard({required this.item});

  final MedicalInstitution item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2D6F7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8767D8).withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SmallInfoChip(text: categoryLabel(item.serviceCategory)),
              if (item.distanceKm != null)
                _SmallInfoChip(
                  text: '${item.distanceKm!.toStringAsFixed(1)}km',
                  icon: Icons.near_me_rounded,
                ),
              if (_notEmpty(item.sigungu))
                _SmallInfoChip(text: item.sigungu!, icon: Icons.map_rounded),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.institutionName,
            style: const TextStyle(
              color: Color(0xFF241064),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          if (_notEmpty(item.institutionType))
            _ResultLine(
              icon: Icons.business_rounded,
              text: item.institutionType!,
            ),
          if (_notEmpty(item.department))
            _ResultLine(
              icon: Icons.medical_services_outlined,
              text: item.department!,
            ),
          if (_notEmpty(item.address))
            _ResultLine(icon: Icons.location_on_outlined, text: item.address!),
          if (_notEmpty(item.phone))
            _ResultLine(icon: Icons.call_outlined, text: item.phone!),
          const SizedBox(height: 10),
          const Text(
            AppText.availabilityNotice,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallInfoChip extends StatelessWidget {
  const _SmallInfoChip({required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightPurpleCard,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE3D7F7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: AppColors.primaryPurple),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4A2CB4),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _GuideFilter {
  all,
  medical,
  publicHealth,
  pharmacy,
  emergency;

  String get label {
    return switch (this) {
      _GuideFilter.all => '전체',
      _GuideFilter.medical => '의료기관',
      _GuideFilter.publicHealth => '보건기관',
      _GuideFilter.pharmacy => '약국',
      _GuideFilter.emergency => '응급',
    };
  }

  String? get serviceCategory {
    return switch (this) {
      _GuideFilter.publicHealth => 'PUBLIC_HEALTH',
      _ => null,
    };
  }
}

enum _GuideImageSide { left, right }

class _GuidePalette {
  const _GuidePalette({
    required this.background,
    required this.border,
    required this.shadow,
    required this.title,
    required this.accent,
    required this.badge,
    required this.badgeText,
  });

  final List<Color> background;
  final Color border;
  final Color shadow;
  final Color title;
  final Color accent;
  final Color badge;
  final Color badgeText;

  static const medical = _GuidePalette(
    background: [Color(0xFFFFFAFF), Color(0xFFF5EBFF)],
    border: Color(0xFFD8C3FF),
    shadow: Color(0xFF8B5BED),
    title: Color(0xFF261066),
    accent: Color(0xFF7C39F0),
    badge: Color(0xFFF0E4FF),
    badgeText: Color(0xFF6A2DDC),
  );

  static const publicHealth = _GuidePalette(
    background: [Color(0xFFF5FFFC), Color(0xFFEAFBF8)],
    border: Color(0xFFC3EEE4),
    shadow: Color(0xFF2EB999),
    title: Color(0xFF20105E),
    accent: Color(0xFF1F9E82),
    badge: Color(0xFFDFF8EE),
    badgeText: Color(0xFF147662),
  );

  static const pharmacy = _GuidePalette(
    background: [Color(0xFFF8FBFF), Color(0xFFEFF6FF)],
    border: Color(0xFFC7DFFF),
    shadow: Color(0xFF5EA2FF),
    title: Color(0xFF20105E),
    accent: Color(0xFF2C79E8),
    badge: Color(0xFFEAF3FF),
    badgeText: Color(0xFF2B67C7),
  );

  static const emergency = _GuidePalette(
    background: [Color(0xFFFFFAFA), Color(0xFFFFEBF1)],
    border: Color(0xFFFFB8CE),
    shadow: Color(0xFFFF5E83),
    title: Color(0xFFC91F3E),
    accent: Color(0xFFE9264B),
    badge: Color(0xFFFFE4EC),
    badgeText: Color(0xFFD91F43),
  );
}

bool _notEmpty(String? value) => value != null && value.isNotEmpty;

_GuideFilter _guideFilterForCategory(String? category) {
  return switch (category) {
    'PUBLIC_HEALTH' => _GuideFilter.publicHealth,
    'WOMEN_HEALTH' || 'MENTAL_HEALTH' || 'PAIN_NEURO' => _GuideFilter.medical,
    _ => _GuideFilter.all,
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
