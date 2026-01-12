import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/theme/light_theme/light_color_scheme.dart';

/// The custom light theme class.
final class CustomLightTheme {
  /// The constructor for the custom light theme.
  CustomLightTheme() {
    final colorScheme = LightColorScheme.lightScheme();
    themeData = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 2,
      ),
    );
  }

  /// The light theme data.
  late final ThemeData themeData;
}
