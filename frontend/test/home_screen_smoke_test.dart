import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:more_cycle/core/api/api_client.dart';
import 'package:more_cycle/core/constants/app_assets.dart';
import 'package:more_cycle/core/constants/app_text.dart';
import 'package:more_cycle/core/storage/token_storage.dart';
import 'package:more_cycle/core/theme/app_theme.dart';
import 'package:more_cycle/models/user.dart';
import 'package:more_cycle/screens/home/main_shell.dart';
import 'package:more_cycle/services/auth_api.dart';
import 'package:more_cycle/services/institution_api.dart';
import 'package:more_cycle/services/record_api.dart';
import 'package:more_cycle/services/report_api.dart';
import 'package:more_cycle/state/analysis_controller.dart';
import 'package:more_cycle/state/auth_controller.dart';
import 'package:more_cycle/state/institution_controller.dart';
import 'package:more_cycle/state/record_controller.dart';
import 'package:more_cycle/state/report_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('home screen renders real cycle layout with local assets', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controllers = _buildControllers();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: MainShell(
          authController: controllers.authController,
          recordController: controllers.recordController,
          reportController: controllers.reportController,
          analysisController: controllers.analysisController,
          institutionController: controllers.institutionController,
        ),
      ),
    );
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('안녕하세요, 지은님 👋'), findsOneWidget);
    expect(find.text('오늘의 건강 요약'), findsOneWidget);
    expect(find.text('오늘의 미션'), findsOneWidget);
    expect(find.text('생리 1일차'), findsOneWidget);
    expect(find.text(_expectedNextPeriodText(28)), findsOneWidget);
    expect(find.text('PMS 예측'), findsOneWidget);
    expect(find.text('보통'), findsOneWidget);
    expect(find.text('수면 시간'), findsOneWidget);
    expect(find.text('6h 30m'), findsOneWidget);
    expect(find.byTooltip('커뮤니티'), findsOneWidget);
    expect(find.byIcon(Icons.forum_rounded), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);
    expect(find.byIcon(Icons.calendar_month_outlined), findsNothing);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('기록'), findsOneWidget);
    expect(find.text('분석'), findsOneWidget);
    expect(find.text('병원'), findsOneWidget);
    expect(find.text('마이'), findsOneWidget);

    final cycleCardAsset = _asset(
      AppAssets.homeCycleCardBg,
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );
    expect(cycleCardAsset, findsOneWidget);
    expect(_asset(AppAssets.homePmsCardBg), findsNothing);
    expect(_asset(AppAssets.homeSleepCardBg), findsNothing);
    expect(_asset(AppAssets.homeMissionTea), findsOneWidget);
    expect(_asset(AppAssets.bottomNavHome), findsOneWidget);
    expect(_asset(AppAssets.bottomNavRecord), findsOneWidget);
    expect(_asset(AppAssets.bottomNavAnalysis), findsOneWidget);
    expect(_asset(AppAssets.bottomNavHospital), findsOneWidget);
    expect(_asset(AppAssets.bottomNavMy), findsOneWidget);

    final cycleCardRect = tester.getRect(cycleCardAsset);

    expect(cycleCardRect.width / cycleCardRect.height, greaterThan(1.95));
    expect(cycleCardRect.width / cycleCardRect.height, lessThan(2.18));
  });

  testWidgets('home community action opens community screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controllers = _buildControllers();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: MainShell(
          authController: controllers.authController,
          recordController: controllers.recordController,
          reportController: controllers.reportController,
          analysisController: controllers.analysisController,
          institutionController: controllers.institutionController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('커뮤니티'));
    await tester.pumpAndSettle();

    expect(find.text('추천'), findsOneWidget);
    expect(find.text('최신'), findsOneWidget);
    expect(find.text('인기'), findsOneWidget);
    expect(find.textContaining('PMS 심할 때'), findsOneWidget);
  });

  testWidgets('home initial state shows empty service copy', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controllers = _buildControllers(hasRecords: false);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: MainShell(
          authController: controllers.authController,
          recordController: controllers.recordController,
          reportController: controllers.reportController,
          analysisController: controllers.analysisController,
          institutionController: controllers.institutionController,
        ),
      ),
    );
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('안녕하세요, 지은님 👋'), findsOneWidget);
    expect(find.text('생리 시작일을 기록하면 주기 요약을 볼 수 있어요.'), findsOneWidget);
    expect(find.text('분석 전'), findsOneWidget);
    expect(find.text('기록 전'), findsNWidgets(2));
    expect(find.text('가임기 5일차'), findsNothing);
    expect(find.text('다음 생리 예정 6.24 (D-3)'), findsNothing);
    expect(find.text('보통'), findsNothing);
    expect(find.text('6h 30m'), findsNothing);
    expect(find.text('기록이 필요해요'), findsNothing);
    expect(find.text('기록 없음'), findsNothing);
  });

  testWidgets('home cycle card shows empty copy when only cycle is missing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controllers = _buildControllers(hasCycle: false);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: MainShell(
          authController: controllers.authController,
          recordController: controllers.recordController,
          reportController: controllers.reportController,
          analysisController: controllers.analysisController,
          institutionController: controllers.institutionController,
        ),
      ),
    );
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('생리 시작일을 기록하면 주기 요약을 볼 수 있어요.'), findsOneWidget);
    expect(find.text('보통'), findsOneWidget);
    expect(find.text('6h 30m'), findsOneWidget);
    expect(find.text('가임기 5일차'), findsNothing);
  });
}

Finder _asset(String assetPath, {BoxFit? fit, AlignmentGeometry? alignment}) {
  return find.byWidgetPredicate((widget) {
    if (widget is! Image || widget.image is! AssetImage) {
      return false;
    }
    if ((widget.image as AssetImage).assetName != assetPath) {
      return false;
    }
    if (fit != null && widget.fit != fit) {
      return false;
    }
    if (alignment != null && widget.alignment != alignment) {
      return false;
    }
    return true;
  });
}

_Controllers _buildControllers({
  bool hasRecords = true,
  bool? hasCycle,
  int cycleStartDaysAgo = 0,
  int cycleLength = 28,
}) {
  hasCycle ??= hasRecords;
  final today = DateTime.now();
  final cycleStart = today.subtract(Duration(days: cycleStartDaysAgo));
  final sleepStart = DateTime(
    today.year,
    today.month,
    today.day,
  ).subtract(const Duration(hours: 7));
  final sleepEnd = sleepStart.add(const Duration(hours: 6, minutes: 30));

  final storage = TokenStorage();
  final client = ApiClient(
    tokenStorage: storage,
    httpClient: MockClient((request) async {
      switch (request.url.path) {
        case '/api/cycles/latest':
          if (!hasCycle!) {
            return http.Response('', 200);
          }
          return _jsonResponse({
            'id': 1,
            'start_date': _date(cycleStart),
            'end_date': null,
            'cycle_length': cycleLength,
            'memo': null,
            'created_at': today.toIso8601String(),
          });
        case '/api/sleep':
          if (!hasRecords) {
            return _jsonResponse([]);
          }
          return _jsonResponse([
            {
              'id': 1,
              'sleep_start': sleepStart.toIso8601String(),
              'sleep_end': sleepEnd.toIso8601String(),
              'sleep_hours': 6.5,
              'quality_score': 4,
              'created_at': today.toIso8601String(),
            },
          ]);
        case '/api/reports/latest':
          if (!hasRecords) {
            return http.Response('', 200);
          }
          return _jsonResponse({
            'id': 1,
            'pms_score': 48,
            'health_score': 74,
            'risk_level': 'medium',
            'confidence': 'medium',
            'summary': '최근 기록을 바탕으로 PMS 위험도가 보통 수준으로 계산되었어요.',
            'main_factors': ['수면 부족'],
            'care_tips': ['따뜻한 차 한 잔과 휴식을 챙겨보세요.'],
            'recommended_category': 'WOMEN_HEALTH',
            'disclaimer': AppText.medicalDisclaimer,
            'created_at': today.toIso8601String(),
          });
        case '/api/reports/history':
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
    recordController: RecordController(RecordApi(client)),
    reportController: ReportController(ReportApi(client)),
    analysisController: AnalysisController(
      reportApi: ReportApi(client),
      recordApi: RecordApi(client),
    ),
    institutionController: InstitutionController(InstitutionApi(client)),
  );
}

String _date(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _expectedNextPeriodText(int cycleLength) {
  final today = DateTime.now();
  final next = today.add(Duration(days: cycleLength));
  return '다음 생리 예정 ${next.month}.${next.day} (D-$cycleLength)';
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
}
