import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:more_cycle/app.dart';
import 'package:more_cycle/models/health_report.dart';
import 'package:more_cycle/screens/auth/auth_screen.dart';
import 'package:more_cycle/services/auth_api.dart';
import 'package:more_cycle/state/auth_controller.dart';
import 'package:more_cycle/core/api/api_client.dart';
import 'package:more_cycle/core/storage/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app shows welcome screen after splash when token is missing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MoreCycleApp());
    expect(find.text('AI 여성 생애주기 케어 플랫폼'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('나만을 위한\n여성 건강 관리 시작하기'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);
  });

  testWidgets('login screen renders required fields', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = TokenStorage();
    final client = ApiClient(tokenStorage: storage);
    final controller = AuthController(
      authApi: AuthApi(client),
      tokenStorage: storage,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(
          controller: controller,
          initialSignupMode: false,
          onBackToWelcome: () {},
        ),
      ),
    );

    expect(find.text('로그인'), findsWidgets);
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
  });

  test('health report parses backend JSON safely', () {
    final report = HealthReport.fromJson({
      'id': 1,
      'pms_score': 42,
      'health_score': 76,
      'risk_level': 'medium',
      'confidence': 'high',
      'summary': '요약',
      'main_factors': ['수면 부족'],
      'care_tips': ['휴식'],
      'recommended_category': 'WOMEN_HEALTH',
      'disclaimer': '면책',
      'created_at': '2026-06-11T01:00:00',
    });

    expect(report.pmsScore, 42);
    expect(report.mainFactors.first, '수면 부족');
    expect(report.recommendedCategory, 'WOMEN_HEALTH');
  });
}
