import 'dart:convert';

import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';
import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    required this.tokenStorage,
    String? baseUrl,
    this.onUnauthorized,
    http.Client? httpClient,
  }) : baseUrl = baseUrl ?? ApiConfig.baseUrl,
       _httpClient = httpClient ?? http.Client();

  final TokenStorage tokenStorage;
  final String baseUrl;
  final Future<void> Function()? onUnauthorized;
  final http.Client _httpClient;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    return _send('GET', path, query: query);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    return _send('POST', path, body: body);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool allowRefresh = true,
  }) async {
    final uri = _uri(path, query);
    final response = await _request(method, uri, body);
    return _handle(
      response,
      path: path,
      retry: allowRefresh
          ? () => _send(
              method,
              path,
              query: query,
              body: body,
              allowRefresh: false,
            )
          : null,
    );
  }

  Future<http.Response> _request(
    String method,
    Uri uri,
    Map<String, dynamic>? body,
  ) async {
    if (method == 'GET') {
      return _httpClient.get(uri, headers: await _headers());
    }
    if (method == 'POST') {
      return _httpClient.post(
        uri,
        headers: await _headers(),
        body: jsonEncode(body ?? <String, dynamic>{}),
      );
    }
    throw UnsupportedError('Unsupported API method: $method');
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = await tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await _httpClient.post(
        _uri('/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        return false;
      }
      final accessToken = decoded['access_token']?.toString() ?? '';
      final nextRefreshToken =
          decoded['refresh_token']?.toString() ?? refreshToken;
      if (accessToken.isEmpty) {
        return false;
      }
      await tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: nextRefreshToken,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleanQuery = <String, String>{};
    query?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        cleanQuery[key] = value.toString();
      }
    });
    return Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: cleanQuery.isEmpty ? null : cleanQuery);
  }

  Future<Map<String, String>> _headers() async {
    final token = await tokenStorage.readToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _handle(
    http.Response response, {
    required String path,
    Future<dynamic> Function()? retry,
  }) async {
    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {
        decoded = response.body;
      }
    }

    if (response.statusCode == 401) {
      if (_isAuthRequest(path)) {
        throw ApiException(_errorMessage(decoded), statusCode: 401);
      }
      final refreshed = retry != null && await _refreshAccessToken();
      if (refreshed) {
        return retry();
      }
      await tokenStorage.clearTokens();
      await onUnauthorized?.call();
      throw ApiException('로그인이 만료되었어요. 다시 로그인해주세요.', statusCode: 401);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _errorMessage(decoded),
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  bool _isAuthRequest(String path) {
    return path == '/api/auth/login' ||
        path == '/api/auth/signup' ||
        path == '/api/auth/refresh';
  }

  String _errorMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail'];
      if (detail is String && detail.isNotEmpty) {
        if (detail.contains('Invalid email or password')) {
          return '이메일 또는 비밀번호를 확인해주세요.';
        }
        if (detail.contains('already registered')) {
          return '이미 가입된 이메일이에요.';
        }
        return detail;
      }
      if (detail is List && detail.isNotEmpty) {
        return _validationMessage(detail);
      }
    }
    return '서버 요청에 실패했어요. 백엔드 실행 상태를 확인해주세요.';
  }

  String _validationMessage(List<dynamic> detail) {
    final fields = detail
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final loc = item['loc'];
          if (loc is List && loc.isNotEmpty) {
            return loc.last.toString();
          }
          return '';
        })
        .where((field) => field.isNotEmpty)
        .toSet();

    if (fields.contains('email')) {
      return '이메일 형식을 다시 확인해주세요.';
    }
    if (fields.contains('password')) {
      return '비밀번호는 8자 이상 입력해주세요.';
    }
    if (fields.contains('nickname')) {
      return '이름을 입력해주세요.';
    }
    if (fields.contains('birth_date')) {
      return '생년월일을 다시 확인해주세요.';
    }
    return '입력값을 다시 확인해주세요.';
  }
}
