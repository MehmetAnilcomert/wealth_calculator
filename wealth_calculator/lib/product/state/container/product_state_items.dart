import 'package:wealth_calculator/product/cache/product_cache.dart';
import 'package:wealth_calculator/product/service/manager/product_network_manager.dart';
import 'package:wealth_calculator/product/state/container/product_state_container.dart';
import 'package:wealth_calculator/feature/profile/viewmodel/user_profile_cubit.dart';
import 'package:wealth_calculator/product/state/viewmodel/product_viewmodel.dart';

/// A class that provides access to various product state items.
/// This class acts as a centralized point to retrieve instances
/// of different state-related items used in the product module.
/// For example, it provides access to the [ProductNetworkManager].
final class ProductStateItems {
  /// Creates an instance of [ProductStateItems].
  const ProductStateItems._();

  /// Provides access to the [ProductNetworkManager] instance.
  static ProductNetworkManager get networkManager =>
      ProductContainer.read<ProductNetworkManager>();

  /// Provides access to the [ProductCache] instance.
  static ProductCache get cacheManager => ProductContainer.read<ProductCache>();

  static ProductViewmodel get productViewModel =>
      ProductContainer.read<ProductViewmodel>();

  /// Provides access to the [UserProfileCubit] instance.
  static UserProfileCubit get userProfileCubit =>
      ProductContainer.read<UserProfileCubit>();
}
