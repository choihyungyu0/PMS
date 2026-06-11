import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:more_cycle/app.dart';
import 'package:more_cycle/core/storage/health_goal_storage.dart';
import 'package:more_cycle/models/health_report.dart';
import 'package:more_cycle/screens/auth/auth_screen.dart';
import 'package:more_cycle/screens/auth/signup_basic_info_screen.dart';
import 'package:more_cycle/screens/auth/signup_goal_selection_screen.dart';
import 'package:more_cycle/services/auth_api.dart';
import 'package:more_cycle/state/auth_controller.dart';
import 'package:more_cycle/core/api/api_client.dart';
import 'package:more_cycle/core/storage/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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
          onBackToWelcome: () {},
          onSignupRequested: () {},
        ),
      ),
    );

    expect(find.text('로그인'), findsWidgets);
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
  });

  testWidgets('start button opens signup basic info screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MoreCycleApp());
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('회원가입'), findsOneWidget);
    expect(find.text('더 정확한 맞춤 케어를 위해\n기본 정보를 입력해주세요.'), findsOneWidget);
    expect(find.byKey(const Key('signupNameField')), findsOneWidget);
    expect(find.byKey(const Key('signupBirthDateField')), findsOneWidget);
    expect(find.byKey(const Key('signupEmailField')), findsOneWidget);
    expect(find.byKey(const Key('signupPasswordField')), findsOneWidget);
    expect(find.byKey(const Key('signupNextButton')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('signupNextButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('signupNextButton')));
    await tester.pumpAndSettle();

    expect(find.text('이름을 입력해주세요.'), findsOneWidget);
    expect(find.text('생년월일을 선택해주세요.'), findsOneWidget);
    expect(find.text('올바른 이메일을 입력해주세요.'), findsOneWidget);
    expect(find.text('비밀번호는 8자 이상 입력해주세요.'), findsOneWidget);
  });

  testWidgets('signup login link opens existing login screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MoreCycleApp());
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('signupLoginLink')));
    await tester.tap(find.byKey(const Key('signupLoginLink')));
    await tester.pumpAndSettle();

    expect(find.text('다시 만나서 반가워요'), findsOneWidget);
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
  });

  testWidgets('signup back and close buttons return to welcome', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MoreCycleApp());
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('나만을 위한\n여성 건강 관리 시작하기'), findsOneWidget);

    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('나만을 위한\n여성 건강 관리 시작하기'), findsOneWidget);
  });

  testWidgets('health goal selection requires at least one selected goal', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final storage = TokenStorage();
    final client = ApiClient(tokenStorage: storage);
    final controller = AuthController(
      authApi: AuthApi(client),
      tokenStorage: storage,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HealthGoalSelectionScreen(
          controller: controller,
          signupData: const PendingSignupData(
            email: 'test@example.com',
            password: 'password123',
            nickname: '테스터',
            birthDate: '2000-01-01',
          ),
          onBackToBasicInfo: () {},
          onCloseToWelcome: () {},
          onSignupCompleted: () {},
        ),
      ),
    );

    await tester.ensureVisible(
      find.byKey(const Key('goalSelectionNextButton')),
    );
    await tester.tap(find.byKey(const Key('goalSelectionNextButton')));
    await tester.pumpAndSettle();

    expect(find.text('건강 목표를 하나 이상 선택해주세요.'), findsOneWidget);
  });

  testWidgets('selected health goals are stored locally before signup', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final signupBodies = <Map<String, dynamic>>[];
    final storage = TokenStorage();
    final client = ApiClient(
      tokenStorage: storage,
      httpClient: MockClient((request) async {
        if (request.url.path == '/api/auth/signup') {
          signupBodies.add(jsonDecode(request.body) as Map<String, dynamic>);
          return http.Response(
            jsonEncode({'access_token': 'test-token', 'token_type': 'bearer'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/api/users/me') {
          return http.Response(
            jsonEncode({
              'id': 1,
              'email': 'test@example.com',
              'nickname': '테스터',
              'birth_date': '2000-01-01',
              'created_at': '2026-06-11T00:00:00',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('not found', 404);
      }),
    );
    final controller = AuthController(
      authApi: AuthApi(client),
      tokenStorage: storage,
    );
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: HealthGoalSelectionScreen(
          controller: controller,
          signupData: const PendingSignupData(
            email: 'test@example.com',
            password: 'password123',
            nickname: '테스터',
            birthDate: '2000-01-01',
          ),
          onBackToBasicInfo: () {},
          onCloseToWelcome: () {},
          onSignupCompleted: () => completed = true,
        ),
      ),
    );

    await tester.tap(find.text('생리 주기 관리'));
    await tester.ensureVisible(
      find.byKey(const Key('goalSelectionNextButton')),
    );
    await tester.tap(find.byKey(const Key('goalSelectionNextButton')));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString(HealthGoalStorage.storageKey),
      jsonEncode(['cycle_management']),
    );
    expect(signupBodies, hasLength(1));
    expect(signupBodies.single, {
      'email': 'test@example.com',
      'password': 'password123',
      'nickname': '테스터',
      'birth_date': '2000-01-01',
    });
    expect(completed, isTrue);
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
