import 'package:flutter/widgets.dart';
import 'package:wealth_calculator/product/service/manager/product_network_manager.dart';
import 'package:wealth_calculator/product/state/container/product_state_items.dart';
import 'package:wealth_calculator/product/state/viewmodel/product_viewmodel.dart';

/// A base state class that provides common functionality for stateful widgets.
abstract class BaseState<T extends StatefulWidget> extends State<T> {
  /// Provides access to the [ProductNetworkManager] instance.
  ProductNetworkManager get networkManager => ProductStateItems.networkManager;

  /// Provides access to the [ProductViewmodel] instance.
  ProductViewmodel get productViewModel => ProductStateItems.productViewModel;
}
