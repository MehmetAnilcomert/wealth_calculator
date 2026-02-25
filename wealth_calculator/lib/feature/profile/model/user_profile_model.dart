import 'package:equatable/equatable.dart';

/// User profile model for local storage.
/// Stores basic user info: name, surname and profile image path.
class UserProfileModel extends Equatable {
  /// Unique ID from database.
  final int? id;

  /// User's first name.
  final String name;

  /// User's surname.
  final String surname;

  /// Local file path of the profile image.
  final String? imagePath;

  const UserProfileModel({
    this.id,
    required this.name,
    required this.surname,
    this.imagePath,
  });

  /// Creates an empty profile.
  factory UserProfileModel.empty() =>
      const UserProfileModel(name: '', surname: '');

  /// Whether the profile has no data.
  bool get isEmpty => name.isEmpty && surname.isEmpty;

  /// Whether the profile has data.
  bool get isNotEmpty => !isEmpty;

  /// Full name of the user.
  String get fullName => '$name $surname'.trim();

  /// Creates a copy with updated fields.
  UserProfileModel copyWith({
    int? id,
    String? name,
    String? surname,
    String? imagePath,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  /// Converts to a map for database storage.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'surname': surname,
      'imagePath': imagePath,
    };
  }

  /// Creates from a database map.
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      surname: map['surname'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, surname, imagePath];
}
