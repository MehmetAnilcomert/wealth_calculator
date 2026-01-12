import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/cache/theme_cache_model.dart';

/// A class responsible for managing product cache functionalities.
final class ProductCache {
  /// Creates an instance of [ProductCache] with the provided [CacheManager].
  ProductCache({required CacheManager cacheManager})
      : _cacheManager = cacheManager;

  /// Initializes the cache by setting up necessary configurations.
  final CacheManager _cacheManager;

  /// Cache operation for theme preferences
  late final HiveCacheOperation<ThemeCacheModel> _themeCacheOperation;

  /// Cache key for theme preference
  static const String _themeCacheKey = 'theme_preference';

  Future<void> initialize() async {
    await _cacheManager.init(items: [ThemeCacheModel.empty()]);
    _themeCacheOperation = HiveCacheOperation<ThemeCacheModel>();
  }

  /// Saves the theme mode to cache using HiveCacheOperation
  void saveThemeMode(ThemeMode themeMode) {
    final themeModeString = _themeModeToString(themeMode);
    final cacheModel = ThemeCacheModel(
      themeMode: themeModeString,
      id: _themeCacheKey,
    );
    _themeCacheOperation.add(cacheModel);
  }

  /// Retrieves the saved theme mode from cache using HiveCacheOperation
  ThemeMode? getThemeMode() {
    final cacheModel = _themeCacheOperation.get(_themeCacheKey);
    if (cacheModel == null) return null;
    return _stringToThemeMode(cacheModel.themeMode);
  }

  /// Converts ThemeMode to String
  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Converts String to ThemeMode
  ThemeMode _stringToThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
