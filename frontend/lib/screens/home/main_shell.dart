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
import '../hospital/hospital_screen.dart';
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
        onOpenCommunity: () => setState(() => _index = 5),
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
        onGoHome: () => setState(() => _index = 0),
      ),
      HospitalScreen(
        institutionController: widget.institutionController,
        reportController: widget.reportController,
      ),
      MyPageScreen(
        authController: widget.authController,
        onClose: () => setState(() => _index = 0),
        onOpenReport: () => setState(() => _index = 2),
        onOpenRecord: () => setState(() => _index = 1),
      ),
      const CommunityScreen(),
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
      icon: Icons.local_hospital_outlined,
      assetPath: AppAssets.bottomNavHospital,
      label: '병원',
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
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: Border.all(color: const Color(0xFFE8DDF8), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.13),
            blurRadius: 28,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 86,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
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
    );
  }
}

class _BottomNavItemData {
  const _BottomNavItemData({
    required this.icon,
    required this.label,
    this.assetPath,
  });

  final IconData icon;
  final String? assetPath;
  final String label;
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.assetPath,
  });

  final IconData icon;
  final String? assetPath;
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
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: selected ? 1 : 0.76,
                  child: assetPath == null
                      ? Icon(icon, color: color, size: selected ? 34 : 31)
                      : Image.asset(
                          assetPath!,
                          width: selected ? 42 : 33,
                          height: selected ? 42 : 33,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              icon,
                              color: color,
                              size: selected ? 34 : 31,
                            );
                          },
                        ),
                ),
                const SizedBox(height: 2),
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
