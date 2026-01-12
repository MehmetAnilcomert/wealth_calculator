import 'package:core/core.dart';

/// A class responsible for managing product cache functionalities.
final class ProductCache {
  /// Creates an instance of [ProductCache] with the provided [CacheManager].
  ProductCache({required CacheManager cacheManager})
    : _cacheManager = cacheManager;

  /// Initializes the cache by setting up necessary configurations.
  final CacheManager _cacheManager;

  Future<void> initialize() async {
    await _cacheManager.init(items: []);
  }
}
