import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:more_cycle/core/api/api_client.dart';
import 'package:more_cycle/core/constants/app_text.dart';
import 'package:more_cycle/core/storage/token_storage.dart';
import 'package:more_cycle/core/theme/app_theme.dart';
import 'package:more_cycle/models/user.dart';
import 'package:more_cycle/screens/analysis/ai_report_screen.dart';
import 'package:more_cycle/services/auth_api.dart';
import 'package:more_cycle/services/record_api.dart';
import 'package:more_cycle/services/report_api.dart';
import 'package:more_cycle/state/analysis_controller.dart';
import 'package:more_cycle/state/auth_controller.dart';
import 'package:more_cycle/state/report_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('AI report compact cards keep labels on screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controllers = _buildControllers();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: Scaffold(
          body: AiReportScreen(
            authController: controllers.authController,
            reportController: controllers.reportController,
            analysisController: controllers.analysisController,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('주요 변화'), findsOneWidget);
    expect(find.text('AI 추천 케어'), findsOneWidget);
    expect(find.text('충분한 휴식'), findsOneWidget);
    expect(find.text('수분 섭취'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

_Controllers _buildControllers() {
  final now = DateTime.now();
  final storage = TokenStorage();
  final client = ApiClient(
    tokenStorage: storage,
    httpClient: MockClient((request) async {
      switch (request.url.path) {
        case '/api/reports/latest':
          return _jsonResponse(_reportJson(now));
        case '/api/reports/history':
          return _jsonResponse([_reportJson(now)]);
        case '/api/sleep':
        case '/api/emotions':
        case '/api/pain':
          return _jsonResponse([]);
      }
      return http.Response('not found', 404);
    }),
  );

  final authController =
      AuthController(authApi: AuthApi(client), tokenStorage: storage)
        ..status = AuthStatus.authenticated
        ..user = AppUser(
          id: 1,
          email: 'test@example.com',
          nickname: '지은',
          birthDate: DateTime(2000),
        );

  return _Controllers(
    authController: authController,
    reportController: ReportController(ReportApi(client)),
    analysisController: AnalysisController(
      reportApi: ReportApi(client),
      recordApi: RecordApi(client),
    ),
  );
}

Map<String, Object?> _reportJson(DateTime createdAt) {
  return {
    'id': 1,
    'pms_score': 12,
    'health_score': 91,
    'risk_level': 'low',
    'confidence': 'medium',
    'summary': '최근 기록 기준 PMS 위험도는 낮은 편이에요.',
    'main_factors': ['아직 두드러진 위험 요인은 적게 나타났어요.'],
    'care_tips': ['충분한 휴식', '수분 섭취'],
    'recommended_category': 'PUBLIC_HEALTH',
    'disclaimer': AppText.medicalDisclaimer,
    'created_at': createdAt.toIso8601String(),
  };
}

http.Response _jsonResponse(Object body) {
  return http.Response(
    jsonEncode(body),
    200,
    headers: {'content-type': 'application/json'},
  );
}

class _Controllers {
  const _Controllers({
    required this.authController,
    required this.reportController,
    required this.analysisController,
  });

  final AuthController authController;
  final ReportController reportController;
  final AnalysisController analysisController;
}
