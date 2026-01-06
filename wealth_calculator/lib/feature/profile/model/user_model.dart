import 'package:equatable/equatable.dart';

enum UserRole { free, premium, admin }

enum AuthStatus { authenticated, unauthenticated, unknown }

class User extends Equatable {
  final String? id;
  final String name;
  final String email;
  final String? profilePicture;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final Map<String, dynamic>? statistics;

  const User({
    this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.role = UserRole.free,
    this.createdAt,
    this.lastLogin,
    this.statistics,
  });

  factory User.empty() {
    return const User(
      name: '',
      email: '',
    );
  }

  factory User.guest() {
    return const User(
      name: 'Misafir',
      email: 'guest@app.com',
      role: UserRole.free,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    Map<String, dynamic>? statistics,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      statistics: statistics ?? this.statistics,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'role': role.name,
      'createdAt': createdAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'statistics': statistics,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePicture: map['profilePicture'],
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.free,
      ),
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      lastLogin:
          map['lastLogin'] != null ? DateTime.parse(map['lastLogin']) : null,
      statistics: map['statistics'],
    );
  }

  bool get isEmpty => id == null || id!.isEmpty;

  bool get isNotEmpty => !isEmpty;

  bool get isPremium => role == UserRole.premium || role == UserRole.admin;

  String get roleDisplayName {
    switch (role) {
      case UserRole.free:
        return 'Ücretsiz Üye';
      case UserRole.premium:
        return 'Premium Üye';
      case UserRole.admin:
        return 'Yönetici';
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        profilePicture,
        role,
        createdAt,
        lastLogin,
        statistics,
      ];
}
