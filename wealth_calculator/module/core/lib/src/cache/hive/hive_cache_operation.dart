import 'package:core/src/cache/core/cache_model.dart';
import 'package:core/src/cache/core/cache_operation.dart';
import 'package:hive/hive.dart';

/// A Hive-based implementation of [CacheOperation] for managing cached items.
final class HiveCacheOperation<T extends CacheModel> extends CacheOperation<T> {
  /// Creates a [HiveCacheOperation] instance with the Hive box named after the type [T].
  HiveCacheOperation() {
    _box = Hive.box<T>(name: T.toString());
  }

  /// The Hive box used for caching.
  late final Box<T> _box;

  @override
  void add(T item) {
    _box.put(item.id, item);
  }

  @override
  void addAll(List<T> items) {
    _box.addAll(items);
  }

  @override
  void clear() {
    _box.clear();
  }

  @override
  T? get(String id) {
    return _box.get(id);
  }

  @override
  List<T> getAll() {
    return _box.getAll(_box.keys).where((e) => e != null).cast<T>().toList();
  }

  @override
  void remove(String id) {
    _box.delete(id);
  }

  @override
  void removeAll(List<String> ids) {
    _box.deleteAll(ids);
  }
}
