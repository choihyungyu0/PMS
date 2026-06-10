import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'app_card.dart';

class DisclaimerBox extends StatelessWidget {
  const DisclaimerBox({super.key, required this.text, this.warning = false});

  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: warning ? AppColors.warningSoft : AppColors.lightPurpleCard,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            warning ? Icons.info_outline : Icons.health_and_safety_outlined,
            color: AppColors.deepPurple,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
