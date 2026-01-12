import 'package:flutter/material.dart';

/// Extension to add custom colors to ColorScheme
extension CustomColors on ColorScheme {
  /// Gold color for gold-related items
  Color get gold => brightness == Brightness.light
      ? const Color(0xFFFFD700) // Gold
      : const Color(0xFFFFD700);

  /// Dollar color for USD currency
  Color get dollar => brightness == Brightness.light
      ? const Color(0xFF27AE60) // Green
      : const Color(0xFF2ECC71); // Lighter green

  /// Euro color for EUR currency
  Color get euro => brightness == Brightness.light
      ? const Color(0xFF1565C0) // Blue[700]
      : const Color(0xFF42A5F5); // Lighter blue

  /// Pound color for GBP currency
  Color get pound => brightness == Brightness.light
      ? const Color(0xFF7B1FA2) // Purple
      : const Color(0xFFBA68C8); // Lighter purple

  /// Turkish Lira color
  Color get turkishLira => brightness == Brightness.light
      ? const Color(0xFFE74C3C) // Red
      : const Color(0xFFEC7063); // Lighter red

  /// Warning color for medium priority
  Color get warning => brightness == Brightness.light
      ? const Color(0xFFF39C12) // Orange
      : const Color(0xFFFFB74D); // Lighter orange

  /// Caution color for low priority
  Color get caution => brightness == Brightness.light
      ? const Color(0xFFF1C40F) // Yellow
      : const Color(0xFFFFEB3B); // Lighter yellow

  /// Success color (alias for tertiary)
  Color get success => tertiary;

  /// Danger color (alias for error)
  Color get danger => error;

  /// Semi-transparent white overlays
  Color get whiteOverlay05 => Colors.white.withAlpha(13); // ~5%
  Color get whiteOverlay10 => Colors.white.withAlpha(26); // ~10%
  Color get whiteOverlay15 => Colors.white.withAlpha(38); // ~15%
  Color get whiteOverlay20 => Colors.white.withAlpha(51); // ~20%
  Color get whiteOverlay30 => Colors.white.withAlpha(77); // ~30%
  Color get whiteOverlay50 => Colors.white.withAlpha(128); // ~50%
  Color get whiteOverlay60 => Colors.white.withAlpha(153); // ~60%
  Color get whiteOverlay70 => Colors.white.withAlpha(179); // ~70%
  Color get whiteOverlay80 => Colors.white.withAlpha(204); // ~80%

  /// Semi-transparent black overlays
  Color get blackOverlay10 => Colors.black.withAlpha(26); // ~10%
  Color get blackOverlay20 => Colors.black.withAlpha(51); // ~20%
  Color get blackOverlay30 => Colors.black.withAlpha(77); // ~30%
  Color get blackOverlay40 => Colors.black.withAlpha(102); // ~40%

  /// Disabled text colors
  Color get disabledText => brightness == Brightness.light
      ? Colors.black.withAlpha(97) // ~38%
      : Colors.white.withAlpha(97); // ~38%

  /// Secondary text color (alias for onSurfaceVariant)
  Color get secondaryText => onSurfaceVariant;

  /// Subtle text color
  Color get subtleText => brightness == Brightness.light
      ? const Color(0xFF9E9E9E) // Grey[500]
      : const Color(0xFF757575); // Grey[600]

  /// Card gradient start (usually darker)
  Color get gradientStart => primaryContainer;

  /// Card gradient end (usually lighter)
  Color get gradientEnd => primary;

  /// Delete/swipe action background
  Color get deleteBackground => brightness == Brightness.light
      ? const Color(0xFFEF5350) // Red shade 400
      : const Color(0xFFE57373); // Red shade 300

  /// Chart background
  Color get chartBackground => brightness == Brightness.light
      ? const Color(0xFF1B2838)
      : const Color(0xFF0D1117);

  /// BlueGrey alternative
  Color get blueGrey => brightness == Brightness.light
      ? const Color(0xFF607D8B)
      : const Color(0xFF78909C);

  /// Transparent (for convenience)
  Color get transparent => Colors.transparent;
}
