class AppUser {
  AppUser({
    required this.id,
    required this.email,
    required this.nickname,
    this.birthDate,
    this.createdAt,
  });

  final int id;
  final String email;
  final String nickname;
  final DateTime? birthDate;
  final DateTime? createdAt;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      email: json['email']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '사용자',
      birthDate: DateTime.tryParse(json['birth_date']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
