import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents the state of the product module.
/// This class holds various state properties related to the product,
class ProductState extends Equatable {
  /// Creates an instance of [ProductState] with the given parameters.
  const ProductState({this.locale, this.themeMode = ThemeMode.system});

  /// The current theme mode of the application.
  final ThemeMode themeMode;

  /// The current locale of the application.
  final Locale? locale;

  @override
  List<Object?> get props => [themeMode, locale];

  /// Creates a copy of the current [ProductState] with updated properties.
  ProductState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return ProductState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}
