import 'package:gen/gen.dart';
import 'package:flutter/foundation.dart';

/// Application environment manager class.
final class ProductEnvironment {
  /// Sets up the product configuration for the current environment.
  ProductEnvironment.setup(ProductConfiguration configuration) {
    _configuration = configuration;
  }

  /// Sets up the product configuration with kDebugMode automatically.
  ProductEnvironment.general() {
    _configuration = kDebugMode ? DevEnv() : ProdEnv();
  }

  /// Gets the product configuration for the current environment.
  static late final ProductConfiguration _configuration;
}

// All environment configuration items written into the gen package in module
// folder. Then they are added into this enum so that they can be accessed easily.
/// Enum for accessing environment configuration items.
enum EnvironmentItems {
  /// The base URL for API requests.
  baseUrl,

  /// The API key for accessing services.
  apiKey;

  /// Gets the value of the environment item.
  String get value {
    switch (this) {
      case EnvironmentItems.baseUrl:
        return ProductEnvironment._configuration.baseUrl;
      case EnvironmentItems.apiKey:
        return ProductEnvironment._configuration.apiKey;
    }
  }
}
