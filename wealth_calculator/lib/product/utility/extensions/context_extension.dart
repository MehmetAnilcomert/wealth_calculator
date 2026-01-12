import 'package:flutter/material.dart';

/// Extension for BuildContext to provide easy access to Theme and MediaQuery
extension ContextExtension on BuildContext {
  /// Access to general theme properties
  GeneralContext get general => GeneralContext(this);

  /// Access to MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Screen width
  double get width => mediaQuery.size.width;

  /// Screen height
  double get height => mediaQuery.size.height;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => mediaQuery.viewInsets.bottom > 0;
}

/// General context helper for accessing theme properties
class GeneralContext {
  /// Creates a GeneralContext with the given BuildContext
  const GeneralContext(this.context);

  /// The BuildContext
  final BuildContext context;

  /// Access to ColorScheme
  ColorScheme get colorScheme => Theme.of(context).colorScheme;

  /// Access to TextTheme
  TextTheme get textTheme => Theme.of(context).textTheme;

  /// Access to ThemeData
  ThemeData get theme => Theme.of(context);

  /// Check if current theme is dark
  bool get isDarkMode => colorScheme.brightness == Brightness.dark;

  /// Check if current theme is light
  bool get isLightMode => colorScheme.brightness == Brightness.light;
}
