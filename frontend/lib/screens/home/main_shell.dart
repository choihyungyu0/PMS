import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../state/auth_controller.dart';
import '../../state/analysis_controller.dart';
import '../../state/institution_controller.dart';
import '../../state/record_controller.dart';
import '../../state/report_controller.dart';
import '../analysis/ai_report_screen.dart';
import '../community/community_screen.dart';
import '../mypage/mypage_screen.dart';
import '../record/record_screen.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.authController,
    required this.recordController,
    required this.reportController,
    required this.analysisController,
    required this.institutionController,
  });

  final AuthController authController;
  final RecordController recordController;
  final ReportController reportController;
  final AnalysisController analysisController;
  final InstitutionController institutionController;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    widget.recordController.loadLatestCycle();
    widget.recordController.loadLatestSleep();
    widget.reportController.load();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        authController: widget.authController,
        recordController: widget.recordController,
        reportController: widget.reportController,
        onOpenRecord: () => setState(() => _index = 1),
        onOpenReport: () => setState(() => _index = 2),
        onOpenMyPage: () => setState(() => _index = 4),
      ),
      RecordScreen(
        recordController: widget.recordController,
        reportController: widget.reportController,
        onOpenReport: () => setState(() => _index = 2),
        onClose: () => setState(() => _index = 0),
        onComplete: () => setState(() => _index = 0),
      ),
      AiReportScreen(
        authController: widget.authController,
        reportController: widget.reportController,
        analysisController: widget.analysisController,
      ),
      const CommunityScreen(),
      MyPageScreen(
        authController: widget.authController,
        onClose: () => setState(() => _index = 0),
        onOpenReport: () => setState(() => _index = 2),
        onOpenRecord: () => setState(() => _index = 1),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.lavenderBackground,
      body: screens[_index],
      bottomNavigationBar: _DashboardBottomNav(
        selectedIndex: _index,
        onTap: (value) => setState(() => _index = value),
      ),
    );
  }
}

class _DashboardBottomNav extends StatelessWidget {
  const _DashboardBottomNav({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _BottomNavItemData(
      icon: Icons.home_rounded,
      assetPath: AppAssets.bottomNavHome,
      label: '홈',
    ),
    _BottomNavItemData(
      icon: Icons.note_alt_outlined,
      assetPath: AppAssets.bottomNavRecord,
      label: '기록',
    ),
    _BottomNavItemData(
      icon: Icons.stacked_line_chart_rounded,
      assetPath: AppAssets.bottomNavAnalysis,
      label: '분석',
    ),
    _BottomNavItemData(
      icon: Icons.diversity_3_outlined,
      assetPath: AppAssets.bottomNavCommunity,
      label: '커뮤니티',
    ),
    _BottomNavItemData(
      icon: Icons.person_outline_rounded,
      assetPath: AppAssets.bottomNavMy,
      label: '마이',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00FFFFFF), Color(0xFFF4EFFF)],
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 120,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE4D7FA), width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.12),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(_items.length, (index) {
                  final item = _items[index];
                  return Expanded(
                    child: _BottomNavItem(
                      icon: item.icon,
                      assetPath: item.assetPath,
                      label: item.label,
                      selected: selectedIndex == index,
                      onTap: () => onTap(index),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItemData {
  const _BottomNavItemData({
    required this.icon,
    required this.assetPath,
    required this.label,
  });

  final IconData icon;
  final String assetPath;
  final String label;
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.assetPath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String assetPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF6A35F2) : const Color(0xFF504A83);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withValues(alpha: 0.98)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: selected
                ? Border.all(color: const Color(0xFFD8C2FF), width: 1.2)
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: selected ? 1 : 0.82,
                  child: Image.asset(
                    assetPath,
                    width: selected ? 40 : 35,
                    height: selected ? 40 : 35,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(icon, color: color, size: selected ? 34 : 31);
                    },
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
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
  }
}
