import '../core/api/api_client.dart';
import '../models/auth.dart';
import '../models/user.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<AuthToken> signup({
    required String email,
    required String password,
    required String nickname,
    String? birthDate,
  }) async {
    final body = {
      'email': email.trim().toLowerCase(),
      'password': password,
      'nickname': nickname.trim(),
    };
    final normalizedBirthDate = _normalizedBirthDate(birthDate);
    if (normalizedBirthDate != null) {
      body['birth_date'] = normalizedBirthDate;
    }
    final json =
        await _client.post('/api/auth/signup', body: body)
            as Map<String, dynamic>;
    return AuthToken.fromJson(json);
  }

  Future<AuthToken> login({
    required String email,
    required String password,
  }) async {
    final json =
        await _client.post(
              '/api/auth/login',
              body: {'email': email.trim().toLowerCase(), 'password': password},
            )
            as Map<String, dynamic>;
    return AuthToken.fromJson(json);
  }

  Future<AppUser> me() async {
    final json = await _client.get('/api/users/me') as Map<String, dynamic>;
    return AppUser.fromJson(json);
  }

  String? _normalizedBirthDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }
}
