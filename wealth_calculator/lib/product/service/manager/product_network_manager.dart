import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vexana/vexana.dart';
import 'package:wealth_calculator/product/init/config/product_environment.dart';

/// A class responsible for managing product network functionalities.
class ProductNetworkManager extends NetworkManager<EmptyModel> {
  /// Creates an instance of [ProductNetworkManager] with the provided [NetworkOptions].
  ProductNetworkManager.base()
      : super(
          options: BaseOptions(
            baseUrl: EnvironmentItems.baseUrl.value,
          ),
        );

  /// Handle error
  void listenErrorStatus({required ValueChanged<int> onErrorStatus}) {
    interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          onErrorStatus(error.response?.statusCode ?? HttpStatus.notFound);
          return handler.next(error);
        },
      ),
    );
  }
}
