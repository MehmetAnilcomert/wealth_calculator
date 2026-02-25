import 'package:core/core.dart';
import 'package:get_it/get_it.dart';
import 'package:wealth_calculator/product/cache/product_cache.dart';
import 'package:wealth_calculator/product/service/manager/product_network_manager.dart';
import 'package:wealth_calculator/feature/profile/viewmodel/user_profile_cubit.dart';
import 'package:wealth_calculator/product/service/user_profile_dao.dart';
import 'package:wealth_calculator/product/state/viewmodel/product_viewmodel.dart';

/// A container class for managing product state instances.
/// This class utilizes the GetIt package for dependency injection,
final class ProductContainer {
  ProductContainer._();

  /// the service locator for dependency injection.
  static final GetIt _getit = GetIt.I;

  /// Sets up the necessary dependencies for the product state container.
  static Future<void> setUp() async {
    _getit
      ..registerSingleton(
        ProductNetworkManager.base(),
      )
      ..registerSingleton(ProductCache(cacheManager: HiveCacheManager()));

    // Initialize cache before other dependencies
    await _getit<ProductCache>().initialize();

    _getit
      ..registerLazySingleton(ProductViewmodel.new)
      ..registerSingleton(UserProfileDao())
      ..registerLazySingleton(
        () => UserProfileCubit(dao: _getit<UserProfileDao>()),
      );
  }

  /// Reads an instance of type [T] from the service locator then returns it.
  static T read<T extends Object>() => _getit<T>();
}
