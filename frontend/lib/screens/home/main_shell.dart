import 'package:flutter/material.dart';

import '../../state/auth_controller.dart';
import '../../state/institution_controller.dart';
import '../../state/record_controller.dart';
import '../../state/report_controller.dart';
import '../analysis/analysis_screen.dart';
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
    required this.institutionController,
  });

  final AuthController authController;
  final RecordController recordController;
  final ReportController reportController;
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
        onOpenHospital: () => setState(() => _index = 3),
      ),
      RecordScreen(
        recordController: widget.recordController,
        reportController: widget.reportController,
        onOpenReport: () => setState(() => _index = 2),
      ),
      AnalysisScreen(reportController: widget.reportController),
      HospitalScreen(
        institutionController: widget.institutionController,
        reportController: widget.reportController,
      ),
      MyPageScreen(authController: widget.authController),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            activeIcon: Icon(Icons.edit),
            label: '기록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: '분석',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital_outlined),
            activeIcon: Icon(Icons.local_hospital),
            label: '병원',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '마이',
          ),
        ],
      ),
    );
  }
}
