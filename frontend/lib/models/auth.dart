class AuthToken {
  AuthToken({
    required this.accessToken,
    required this.tokenType,
    this.refreshToken = '',
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'bearer',
    );
  }
}
