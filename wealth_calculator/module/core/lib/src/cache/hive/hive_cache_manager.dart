import 'package:core/src/cache/core/cache_manager.dart';
import 'package:core/src/cache/core/cache_model.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

/// A cache manager implementation using Hive for local storage.
final class HiveCacheManager extends CacheManager {
  /// Creates a [HiveCacheManager] with the given [path].
  HiveCacheManager({super.path});

  @override
  Future<void> init({required List<CacheModel> items}) async {
    final documentPath =
        path ?? (await getApplicationDocumentsDirectory()).path;

    Hive.defaultDirectory = documentPath;

    for (final item in items) {
      Hive.registerAdapter('${item.runtimeType}', item.fromDynamicJson);
    }
  }

  @override
  Future<void> remove(String key) async {
    Hive.deleteAllBoxesFromDisk();
  }
}
