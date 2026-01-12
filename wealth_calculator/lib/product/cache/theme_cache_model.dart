import 'package:core/core.dart';

/// Tema ayarlarını saklamak için cache modeli
class ThemeCacheModel with CacheModel {
  /// Creates a [ThemeCacheModel] with the given theme mode.
  ThemeCacheModel({required this.themeMode, required String id}) : _id = id;

  /// Creates an empty [ThemeCacheModel] with system theme.
  ThemeCacheModel.empty()
      : _id = 'theme_preference',
        themeMode = 'system';

  /// The unique identifier for the theme cache.
  final String _id;

  /// The theme mode: 'light', 'dark', or 'system'
  final String themeMode;

  @override
  CacheModel fromDynamicJson(json) {
    final itemMap = json as Map<String, dynamic>;
    return ThemeCacheModel(
      themeMode: itemMap['themeMode'] as String? ?? 'system',
      id: itemMap['id'] as String? ?? 'theme_preference',
    );
  }

  @override
  String get id => _id;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'themeMode': themeMode,
    };
  }
}
