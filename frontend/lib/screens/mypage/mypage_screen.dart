import 'package:flutter/material.dart';

import '../../core/constants/app_text.dart';
import '../../state/auth_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/disclaimer_box.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: authController,
        builder: (context, _) {
          final user = authController.user;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionHeader(title: '마이', subtitle: '계정과 서비스 안내를 확인해요.'),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.nickname ?? '사용자',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('앱 정보', style: TextStyle(fontWeight: FontWeight.w800)),
                    SizedBox(height: 8),
                    Text(
                      'MORE Cycle은 생리주기, 감정, 수면, 통증 기록을 바탕으로 건강 관리 참고 정보를 제공하는 MVP 서비스입니다.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const DisclaimerBox(text: AppText.medicalDisclaimer),
              const SizedBox(height: 20),
              PrimaryButton(
                label: '로그아웃',
                icon: Icons.logout,
                secondary: true,
                onPressed: authController.logout,
              ),
            ],
          );
        },
      ),
    );
  }
}
