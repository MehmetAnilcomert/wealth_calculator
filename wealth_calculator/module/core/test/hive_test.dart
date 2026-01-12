import 'dart:io';
import 'package:core/src/cache/hive/hive_cache_manager.dart';
import 'package:core/src/cache/hive/hive_cache_operation.dart';
import 'package:core/src/cache/hive/user_cache_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'core/hive_common_test.dart';

void main() {
  setUp(() async {
    // ÖNCE: Isar çekirdeğini ve DLL dosyalarını hazırla
    await initTests();

    // SONRA: Klasör temizliği
    final testDir = Directory('test/test_hive_cache');
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
    await testDir.create(recursive: true);

    final coreManager = HiveCacheManager(path: 'test/test_hive_cache');
    // Register UserCacheModel adapter before using it
    await coreManager.init(
      items: [UserCacheModel.empty()],
    );
  });

  test('Add a value into Hive cache', () {
    final userOperation = HiveCacheOperation<UserCacheModel>();
    // Eğer add metodu asenkron ise await eklemeyi unutma
    userOperation.add(UserCacheModel(name: 'Anıl', id: '1'));

    final item1 = userOperation.get('1');
    expect(item1, isNotNull);
    expect(item1?.name, 'Anıl');
  });
}
