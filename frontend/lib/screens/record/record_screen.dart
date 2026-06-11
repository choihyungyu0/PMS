import 'package:flutter/material.dart';

import '../../state/record_controller.dart';
import '../../state/report_controller.dart';
import 'condition_record_screen.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({
    super.key,
    required this.recordController,
    required this.reportController,
    required this.onOpenReport,
    required this.onClose,
    required this.onComplete,
  });

  final RecordController recordController;
  final ReportController reportController;
  final VoidCallback onOpenReport;
  final VoidCallback onClose;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return ConditionRecordScreen(
      recordController: recordController,
      onClose: onClose,
      onComplete: onComplete,
    );
  }
}
