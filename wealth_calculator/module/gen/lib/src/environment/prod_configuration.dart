/// Defines the product configuration for the production environment.
/// Project configuration items are specified here.
abstract class ProductConfiguration {
  /// The base URL for API requests in the production environment.
  String get baseUrl;

  /// The API key for accessing services in the production environment.
  String get apiKey;
}
