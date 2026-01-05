import 'package:flutter/material.dart';

/// Application-wide constants
@immutable
final class AppConstants {
  const AppConstants._();

  /// Splash screen duration
  static const Duration splashDuration = Duration(seconds: 3);

  /// Maximum loading timeout
  static const Duration maxLoadingTimeout = Duration(seconds: 7);

  /// Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('tr'),
  ];
}

/// Color constants
@immutable
final class AppColors {
  const AppColors._();

  static const Color primaryBlue = Color(0xFF2C3E50);
  static const Color secondaryBlue = Color(0xFF3498DB);
  static const Color splashBackground = Colors.blue;
}
