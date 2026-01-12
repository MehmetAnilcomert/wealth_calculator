import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/theme/custom_theme.dart';

/// A class representing the dark color scheme for the application.
final class DarkColorScheme extends CustomTheme {
  /// Creates an instance of [DarkColorScheme] with the given [textTheme].
  DarkColorScheme(super.textTheme);

  /// Returns the dark color scheme used in the application.
  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      // Ana uygulama renkleri (dark mode)
      primary:
          Color(0xFF5DADE2), // Daha açık mavi - buttons, icons, primary actions
      surfaceTint: Color(0xFF5DADE2),
      onPrimary: Color(0xFF000000), // Siyah - primary üzerindeki text
      primaryContainer:
          Color(0xFF1C2833), // Çok koyu lacivert - AppBar, containers
      onPrimaryContainer:
          Color(0xffffffff), // Beyaz - primaryContainer üzerindeki text

      // Secondary renkler
      secondary: Color(0xFF2C3E50), // Koyu mavi
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xFF3498DB), // Mavi FAB
      onSecondaryContainer: Color(0xffffffff),

      // Tertiary - success/positive
      tertiary: Color(0xFF2ECC71), // Yeşil - success, positive
      onTertiary: Color(0xFF000000),
      tertiaryContainer: Color(0xFF1E4D2B), // Koyu yeşil background
      onTertiaryContainer: Color(0xFF7DCEA0),

      // Error - hata/negatif
      error: Color(0xFFEC7063), // Açık kırmızı - errors, negative, delete
      onError: Color(0xFF000000),
      errorContainer: Color(0xFFE74C3C), // Koyu kırmızı
      onErrorContainer: Color(0xffffffff),

      // Surface ve background
      surface: Color(0xFF121212), // Koyu gri - main surface
      onSurface: Color(0xFFE0E0E0), // Açık gri - text on surface
      onSurfaceVariant: Color(0xFFB0B0B0), // Orta gri - secondary text

      // Outline ve borders
      outline: Color(0xFF424242), // Koyu gri - borders, dividers
      outlineVariant: Color(0xFF2C2C2C), // Daha koyu gri - subtle borders

      // Shadow ve scrim
      shadow: Color(0xFF000000),
      scrim: Color(0x99000000), // Daha koyu semi-transparent black

      // Inverse colors
      inverseSurface: Color(0xFFE0E0E0), // Açık gri
      inversePrimary: Color(0xFF2980B9), // Koyu mavi

      // Fixed colors
      primaryFixed: Color(0xFF5DADE2),
      onPrimaryFixed: Color(0xFF000000),
      primaryFixedDim: Color(0xFF3498DB),
      onPrimaryFixedVariant: Color(0xFF000000),

      secondaryFixed: Color(0xFF2C3E50),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xFF1A252F),
      onSecondaryFixedVariant: Color(0xffffffff),

      tertiaryFixed: Color(0xFF2ECC71),
      onTertiaryFixed: Color(0xFF000000),
      tertiaryFixedDim: Color(0xFF27AE60),
      onTertiaryFixedVariant: Color(0xFF000000),

      // Surface variants
      surfaceDim: Color(0xFF0A0A0A),
      surfaceBright: Color(0xFF2C2C2C),
      surfaceContainerLowest: Color(0xFF000000),
      surfaceContainerLow: Color(0xFF1A1A1A), // Very dark grey
      surfaceContainer: Color(0xFF1E1E1E), // Dark grey
      surfaceContainerHigh: Color(0xFF2C2C2C), // Medium dark grey
      surfaceContainerHighest: Color(0xFF3A3A3A), // Lighter dark grey
    );
  }

  /// Returns the ThemeData for the dark theme.
  ThemeData dark() {
    return theme(darkScheme());
  }
}
