import 'package:carehub_app/core/enums/app_enums.dart';

class UserProfile {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String language;
  final DateTime? createdAt;
  final UserRole role;

  UserProfile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.language = 'en',
    this.createdAt,
    this.role = UserRole.contributor,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    fullName: json['full_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    language: (json['language'] as String?) ?? 'en',
    createdAt: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at'] as String),
    role: _parseRole(json['role'] as String?),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'language': language,
    'created_at': createdAt?.toIso8601String(),
    'role': role.name,
  };

  static UserRole _parseRole(String? roleStr) {
    if (roleStr == null) return UserRole.contributor;
    try {
      return UserRole.values.firstWhere((r) => r.name == roleStr);
    } catch (_) {
      return UserRole.contributor;
    }
  }

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? avatarUrl,
    String? language,
    DateTime? createdAt,
    UserRole? role,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }
}
