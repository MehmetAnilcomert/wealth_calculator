/// A mixin that defines the structure for cacheable models.
mixin CacheModel {
  /// The unique identifier for the cache model.
  String get id;

  /// Creates the model from a dynamic JSON representation.
  CacheModel fromDynamicJson(dynamic json);

  /// Converts the model to a JSON representation.
  Map<String, dynamic> toJson();
}
