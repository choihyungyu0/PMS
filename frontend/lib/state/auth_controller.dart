import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../core/storage/token_storage.dart';
import '../models/user.dart';
import '../services/auth_api.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthController extends ChangeNotifier {
  AuthController({required AuthApi authApi, required TokenStorage tokenStorage})
    : _authApi = authApi,
      _tokenStorage = tokenStorage;

  final AuthApi _authApi;
  final TokenStorage _tokenStorage;

  AuthStatus status = AuthStatus.checking;
  AppUser? user;
  bool loading = false;
  String? errorMessage;

  Future<void> bootstrap() async {
    status = AuthStatus.checking;
    notifyListeners();
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      user = await _authApi.me();
      status = AuthStatus.authenticated;
    } catch (_) {
      await _tokenStorage.clearToken();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    return _authenticate(
      () => _authApi.login(email: email, password: password),
    );
  }

  Future<bool> signup(
    String email,
    String password,
    String nickname,
    String? birthDate,
  ) async {
    return _authenticate(
      () => _authApi.signup(
        email: email,
        password: password,
        nickname: nickname,
        birthDate: birthDate,
      ),
    );
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> handleUnauthorized() async {
    await logout();
  }

  Future<bool> _authenticate(Future<dynamic> Function() action) async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final token = await action();
      await _tokenStorage.saveToken(token.accessToken);
      user = await _authApi.me();
      status = AuthStatus.authenticated;
      loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = '서버 연결에 실패했어요. 백엔드 실행 상태를 확인해주세요.';
    }
    loading = false;
    notifyListeners();
    return false;
  }
}
