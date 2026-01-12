import 'package:core/src/cache/core/cache_model.dart';

/// A cache model representing a user. Test model
class UserCacheModel with CacheModel {
  /// Creates a [UserCacheModel] with the given [id].
  UserCacheModel({required this.name, required String id}) : _id = id;

  /// Creates an empty [UserCacheModel].
  UserCacheModel.empty() : _id = '', name = '';

  /// The unique identifier for the user.
  final String _id;

  /// The name of the user.
  final String name;

  @override
  CacheModel fromDynamicJson(json) {
    final itemMap = json as Map<String, dynamic>;
    return UserCacheModel(
      name: itemMap['name'] as String,
      id: itemMap['id'] as String,
    );
  }

  @override
  String get id => _id;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': name,
    };
  }
}
