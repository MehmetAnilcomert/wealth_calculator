import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/theme/custom_theme.dart';

/// Creates a light color scheme.
final class LightColorScheme extends CustomTheme {
  /// Creates a light color scheme.
  LightColorScheme(super.textTheme);

  /// Returns the light color scheme used in the application.
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      // Ana uygulama renkleri (mevcut uygulamadan)
      primary: Color(0xFF3498DB), // Açık mavi - buttons, icons, primary actions
      surfaceTint: Color(0xFF3498DB),
      onPrimary: Color(0xffffffff), // Beyaz - primary üzerindeki text
      primaryContainer: Color(0xFF2C3E50), // Koyu lacivert - AppBar, containers
      onPrimaryContainer:
          Color(0xffffffff), // Beyaz - primaryContainer üzerindeki text

      // Secondary renkler
      secondary: Color(0xFF34495E), // Orta ton koyu mavi
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color.fromARGB(255, 90, 189, 255), // Açık mavi FAB
      onSecondaryContainer: Color(0xffffffff),

      // Tertiary - success/positive
      tertiary: Color(0xFF27AE60), // Yeşil - success, positive
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xFFD5F4E6), // Açık yeşil background
      onTertiaryContainer: Color(0xFF1E8449),

      // Error - hata/negatif
      error: Color(0xFFE74C3C), // Kırmızı - errors, negative, delete
      onError: Color(0xffffffff),
      errorContainer: Color(0xFFEF5350), // red.shade400 equivalent
      onErrorContainer: Color(0xffffffff),

      // Surface ve background
      surface: Color(0xffffffff), // Beyaz - main surface
      onSurface: Color(0xFF000000), // Siyah - text on surface
      onSurfaceVariant: Color(0xFF757575), // Grey[600] - secondary text

      // Outline ve borders
      outline: Color(0xFFBDBDBD), // Grey[400] - borders, dividers
      outlineVariant: Color(0xFFE0E0E0), // Grey[300] - subtle borders

      // Shadow ve scrim
      shadow: Color(0xFF000000),
      scrim: Color(0x66000000), // Semi-transparent black

      // Inverse colors
      inverseSurface: Color(0xFF1B2838), // Çok koyu mavi - chart backgrounds
      inversePrimary: Color(0xFF3498DB),

      // Fixed colors
      primaryFixed: Color(0xFF3498DB),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xFF2980B9), // Darker blue
      onPrimaryFixedVariant: Color(0xffffffff),

      secondaryFixed: Color(0xFF2C3E50),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xFF1A252F),
      onSecondaryFixedVariant: Color(0xffffffff),

      tertiaryFixed: Color(0xFF27AE60),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xFF1E8449),
      onTertiaryFixedVariant: Color(0xffffffff),

      // Surface variants
      surfaceDim: Color(0xFFE0E0E0),
      surfaceBright: Color(0xffffffff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xFFF5F5F5), // Very light grey
      surfaceContainer: Color(0xFFEEEEEE), // Light grey
      surfaceContainerHigh: Color(0xFFE0E0E0), // Grey[300]
      surfaceContainerHighest: Color(0xFFBDBDBD), // Grey[400]
    );
  }

  /// Creates a light theme data with using the light color scheme and
  /// superclass theme method.
  ThemeData light() {
    return theme(lightScheme());
  }
}
