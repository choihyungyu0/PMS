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
    final json =
        await _client.post(
              '/api/auth/signup',
              body: {
                'email': email,
                'password': password,
                'nickname': nickname,
                if (birthDate != null && birthDate.isNotEmpty)
                  'birth_date': birthDate,
              },
            )
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
}
