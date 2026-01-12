import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/theme/dark_theme/dark_color_scheme.dart';

/// The custom dark theme class.
final class CustomDarkTheme {
  /// The constructor for the custom dark theme.
  CustomDarkTheme() {
    final colorScheme = DarkColorScheme.darkScheme();
    themeData = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
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

  /// The dark theme data.
  late final ThemeData themeData;
}
