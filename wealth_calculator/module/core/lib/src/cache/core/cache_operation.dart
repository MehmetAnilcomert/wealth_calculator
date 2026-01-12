import 'package:core/src/cache/core/cache_model.dart';

/// An abstract class defining cache operations for a generic cache model type [T].
abstract class CacheOperation<T extends CacheModel> {
  /// Adds an item to the cache.
  void add(T item);

  /// Adds multiple items to the cache.
  void remove(String id);

  /// Removes multiple items from the cache by their IDs.
  void removeAll(List<String> ids);

  /// Adds multiple items to the cache.
  void addAll(List<T> items);

  /// Clears all items from the cache.
  void clear();

  /// Retrieves an item from the cache by its ID.
  T? get(String id);

  /// Retrieves all items from the cache.
  List<T> getAll();
}
