import 'package:flutter/material.dart';

/// Utility class for showing snackbars with proper async handling
class SnackbarHelper {
  SnackbarHelper._();

  /// Shows a snackbar with custom styling
  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Shows an error snackbar (red background)
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message,
      backgroundColor: Colors.red,
      duration: duration,
    );
  }

  /// Shows a success snackbar (green background)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }

  /// Shows an info snackbar (blue background)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message,
      backgroundColor: const Color(0xFF3498DB),
      duration: duration,
    );
  }

  /// Shows a warning snackbar (orange background)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message,
      backgroundColor: Colors.orange,
      duration: duration,
    );
  }

  /// Shows a custom styled snackbar with custom background color
  static void showCustom(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context,
      message,
      backgroundColor: backgroundColor,
      duration: duration,
      action: action,
    );
  }
}
