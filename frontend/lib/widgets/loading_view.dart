import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = '불러오는 중이에요.'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryPurple),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontFamily: AppFonts.body,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
