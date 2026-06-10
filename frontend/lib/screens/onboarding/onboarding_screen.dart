import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
    required this.onStart,
    required this.onLogin,
  });

  final VoidCallback onStart;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 24),
            Text(
              '내 몸을 더 이해하는 가장 쉬운 방법',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 10),
            const Text(
              AppText.appKoreanName,
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 28),
            const AppCard(
              child: Column(
                children: [
                  _OnboardingPoint(
                    icon: Icons.calendar_month,
                    text: '생리주기, 감정, 수면, 통증을 함께 기록해요',
                  ),
                  SizedBox(height: 16),
                  _OnboardingPoint(
                    icon: Icons.insights,
                    text: '기록을 바탕으로 PMS 위험도와 건강 리포트를 확인해요',
                  ),
                  SizedBox(height: 16),
                  _OnboardingPoint(
                    icon: Icons.local_hospital_outlined,
                    text: '인천 의료기관 정보를 공공데이터 기반으로 안내받아요',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: '시작하기',
              icon: Icons.arrow_forward,
              onPressed: onStart,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: '로그인',
              icon: Icons.login,
              secondary: true,
              onPressed: onLogin,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPoint extends StatelessWidget {
  const _OnboardingPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
