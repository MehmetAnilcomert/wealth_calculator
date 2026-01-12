import 'package:core/src/cache/core/cache_model.dart';

/// An abstract class defining the interface for a cache manager.
abstract class CacheManager {
  /// Creates a [CacheManager] with the given [path].
  CacheManager({this.path});

  /// Make your initialization of the cache with a list of [items].
  Future<void> init({required List<CacheModel> items});

  /// Removes a value from the cache using the specified [key].
  Future<void> remove(String key);

  /// The path where the cache is stored. For testing purposes.
  final String? path;
}
