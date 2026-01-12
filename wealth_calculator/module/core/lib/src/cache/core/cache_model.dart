mixin CacheModel {
  String get id;

  /// Creates the model from a dynamic JSON representation.
  CacheModel fromDynamicJson(dynamic json);

  /// Converts the model to a JSON representation.
  Map<String, dynamic> toJson();
}
