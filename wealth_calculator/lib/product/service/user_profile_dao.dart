import 'package:wealth_calculator/feature/profile/model/user_profile_model.dart';
import 'package:wealth_calculator/product/service/database_helper.dart';

/// Data Access Object for user profile operations.
/// Only one profile row is stored (single user app).
class UserProfileDao {
  static const String _tableName = 'user_profile';

  /// Retrieves the user profile from database.
  /// Returns null if no profile exists.
  Future<UserProfileModel?> getProfile() async {
    final db = await DbHelper.instance.database;
    final result = await db.query(_tableName, limit: 1);
    if (result.isEmpty) return null;
    return UserProfileModel.fromMap(result.first);
  }

  /// Inserts or updates the user profile.
  Future<int> saveProfile(UserProfileModel profile) async {
    final db = await DbHelper.instance.database;
    final existing = await getProfile();

    if (existing != null) {
      return await db.update(
        _tableName,
        profile.copyWith(id: existing.id).toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    } else {
      return await db.insert(_tableName, profile.toMap());
    }
  }

  /// Deletes the user profile.
  Future<int> deleteProfile() async {
    final db = await DbHelper.instance.database;
    return await db.delete(_tableName);
  }
}
