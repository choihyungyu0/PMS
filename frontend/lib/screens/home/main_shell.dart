import 'package:flutter/material.dart';

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
        reportController: widget.reportController,
        analysisController: widget.analysisController,
      ),
      const CommunityScreen(),
      MyPageScreen(authController: widget.authController),
    ];

    return Scaffold(
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
    _BottomNavItemData(icon: Icons.home_rounded, label: '홈'),
    _BottomNavItemData(icon: Icons.note_alt_outlined, label: '기록'),
    _BottomNavItemData(icon: Icons.stacked_line_chart_rounded, label: '분석'),
    _BottomNavItemData(icon: Icons.diversity_3_outlined, label: '커뮤니티'),
    _BottomNavItemData(icon: Icons.person_outline_rounded, label: '마이'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6E3EC))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 78,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              return Expanded(
                child: _BottomNavItem(
                  icon: item.icon,
                  label: item.label,
                  selected: selectedIndex == index,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItemData {
  const _BottomNavItemData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF6A35F2) : const Color(0xFF7C7A8D);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: selected ? 33 : 31),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  letterSpacing: 0,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
