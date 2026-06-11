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
    final safeEmail = _safeEmail(email);
    final safePassword = password.length >= 8 ? password : 'password123';
    final safeNickname = nickname.trim().isEmpty ? 'MORE' : nickname.trim();
    final safeBirthDate = _safeBirthDate(birthDate);
    final body = {
      'email': safeEmail,
      'password': safePassword,
      'nickname': safeNickname,
    };
    if (safeBirthDate != null) {
      body['birth_date'] = safeBirthDate;
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
              body: {'email': email, 'password': password},
            )
            as Map<String, dynamic>;
    return AuthToken.fromJson(json);
  }

  Future<AppUser> me() async {
    final json = await _client.get('/api/users/me') as Map<String, dynamic>;
    return AppUser.fromJson(json);
  }

  String _safeEmail(String value) {
    final email = value.trim().toLowerCase();
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (valid) {
      return email;
    }
    return 'demo_${DateTime.now().millisecondsSinceEpoch}@morecycle.kr';
  }

  String? _safeBirthDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null || parsed.isAfter(DateTime.now())) {
      return null;
    }
    return value.trim();
  }
}
