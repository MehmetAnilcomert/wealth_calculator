import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents the state of the product module.
/// This class holds various state properties related to the product,
class ProductState extends Equatable {
  /// Creates an instance of [ProductState] with the given parameters.
  const ProductState({this.themeMode = ThemeMode.light});

  /// The current theme mode of the application.
  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];

  /// Creates a copy of the current [ProductState] with updated properties.
  ProductState copyWith({required ThemeMode themeMode}) {
    return ProductState(themeMode: themeMode);
  }
}
