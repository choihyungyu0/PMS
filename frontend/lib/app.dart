import 'package:flutter/material.dart';

import 'core/api/api_client.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/auth/signup_basic_info_screen.dart';
import 'screens/auth/signup_goal_selection_screen.dart';
import 'screens/home/main_shell.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/auth_api.dart';
import 'services/institution_api.dart';
import 'services/record_api.dart';
import 'services/report_api.dart';
import 'state/auth_controller.dart';
import 'state/institution_controller.dart';
import 'state/record_controller.dart';
import 'state/report_controller.dart';

class MoreCycleApp extends StatefulWidget {
  const MoreCycleApp({super.key});

  @override
  State<MoreCycleApp> createState() => _MoreCycleAppState();
}

class _MoreCycleAppState extends State<MoreCycleApp> {
  static const _minimumSplashDuration = Duration(milliseconds: 1500);

  late final TokenStorage _tokenStorage;
  late final ApiClient _apiClient;
  late final AuthController _authController;
  late final RecordController _recordController;
  late final ReportController _reportController;
  late final InstitutionController _institutionController;

  bool _minimumSplashElapsed = false;
  _UnauthenticatedScreen _unauthenticatedScreen =
      _UnauthenticatedScreen.welcome;
  PendingSignupData? _pendingSignupData;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _apiClient = ApiClient(
      tokenStorage: _tokenStorage,
      onUnauthorized: () => _authController.handleUnauthorized(),
    );
    _authController = AuthController(
      authApi: AuthApi(_apiClient),
      tokenStorage: _tokenStorage,
    );
    _recordController = RecordController(RecordApi(_apiClient));
    _reportController = ReportController(ReportApi(_apiClient));
    _institutionController = InstitutionController(InstitutionApi(_apiClient));
    _authController.bootstrap();
    _holdSplashForBrandMoment();
  }

  Future<void> _holdSplashForBrandMoment() async {
    await Future<void>.delayed(_minimumSplashDuration);
    if (!mounted) {
      return;
    }
    setState(() => _minimumSplashElapsed = true);
  }

  @override
  void dispose() {
    _authController.dispose();
    _recordController.dispose();
    _reportController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MORE Cycle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AnimatedBuilder(
        animation: _authController,
        builder: (context, _) {
          if (!_minimumSplashElapsed ||
              _authController.status == AuthStatus.checking) {
            return const SplashScreen();
          }
          if (_authController.status == AuthStatus.unauthenticated) {
            switch (_unauthenticatedScreen) {
              case _UnauthenticatedScreen.welcome:
                return WelcomeScreen(
                  onStart: () => setState(() {
                    _pendingSignupData = null;
                    _unauthenticatedScreen = _UnauthenticatedScreen.signup;
                  }),
                  onLogin: () => setState(() {
                    _pendingSignupData = null;
                    _unauthenticatedScreen = _UnauthenticatedScreen.login;
                  }),
                );
              case _UnauthenticatedScreen.signup:
                return SignupBasicInfoScreen(
                  initialData: _pendingSignupData,
                  onBackToWelcome: () => setState(() {
                    _pendingSignupData = null;
                    _unauthenticatedScreen = _UnauthenticatedScreen.welcome;
                  }),
                  onCloseToWelcome: () => setState(() {
                    _pendingSignupData = null;
                    _unauthenticatedScreen = _UnauthenticatedScreen.welcome;
                  }),
                  onLogin: () => setState(() {
                    _pendingSignupData = null;
                    _unauthenticatedScreen = _UnauthenticatedScreen.login;
                  }),
                  onNext: (signupData) => setState(() {
                    _pendingSignupData = signupData;
                    _unauthenticatedScreen =
                        _UnauthenticatedScreen.signupGoalSelection;
                  }),
                );
              case _UnauthenticatedScreen.signupGoalSelection:
                final signupData = _pendingSignupData;
                if (signupData == null) {
                  return SignupBasicInfoScreen(
                    onBackToWelcome: () => setState(
                      () => _unauthenticatedScreen =
                          _UnauthenticatedScreen.welcome,
                    ),
                    onCloseToWelcome: () => setState(
                      () => _unauthenticatedScreen =
                          _UnauthenticatedScreen.welcome,
                    ),
                    onLogin: () => setState(
                      () =>
                          _unauthenticatedScreen = _UnauthenticatedScreen.login,
                    ),
                    onNext: (signupData) => setState(() {
                      _pendingSignupData = signupData;
                      _unauthenticatedScreen =
                          _UnauthenticatedScreen.signupGoalSelection;
                    }),
                  );
                }
                return HealthGoalSelectionScreen(
                  controller: _authController,
                  signupData: signupData,
                  onBackToBasicInfo: () => setState(
                    () =>
                        _unauthenticatedScreen = _UnauthenticatedScreen.signup,
                  ),
                  onCloseToWelcome: () => setState(() {
                    _pendingSignupData = null;
                    _unauthenticatedScreen = _UnauthenticatedScreen.welcome;
                  }),
                  onSignupCompleted: () => setState(() {
                    _pendingSignupData = null;
                    _unauthenticatedScreen = _UnauthenticatedScreen.welcome;
                  }),
                );
              case _UnauthenticatedScreen.login:
                return AuthScreen(
                  controller: _authController,
                  onBackToWelcome: () => setState(
                    () =>
                        _unauthenticatedScreen = _UnauthenticatedScreen.welcome,
                  ),
                  onSignupRequested: () => setState(() {
                    _pendingSignupData = null;
                    _unauthenticatedScreen = _UnauthenticatedScreen.signup;
                  }),
                );
            }
          }
          return MainShell(
            authController: _authController,
            recordController: _recordController,
            reportController: _reportController,
            institutionController: _institutionController,
          );
        },
      ),
    );
  }
}

enum _UnauthenticatedScreen { welcome, signup, signupGoalSelection, login }
