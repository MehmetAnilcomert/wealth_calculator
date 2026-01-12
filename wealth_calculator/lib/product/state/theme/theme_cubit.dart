import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'theme_state.dart';

/// Cubit for managing theme state
class ThemeCubit extends Cubit<ThemeState> {
  /// Initialize ThemeCubit with optional [initialThemeMode]
  ThemeCubit({ThemeMode initialThemeMode = ThemeMode.dark})
    : super(ThemeState(themeMode: initialThemeMode));

  /// Change theme mode
  void setThemeMode(ThemeMode mode) {
    if (state.themeMode != mode) {
      emit(ThemeState(themeMode: mode));
    }
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    final newMode = switch (state.themeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.light,
    };
    emit(ThemeState(themeMode: newMode));
  }

  /// Switch to light theme
  void setLightTheme() => setThemeMode(ThemeMode.light);

  /// Switch to dark theme
  void setDarkTheme() => setThemeMode(ThemeMode.dark);

  /// Switch to system theme
  void setSystemTheme() => setThemeMode(ThemeMode.system);

  /// Check if current theme is dark
  bool isDarkMode(Brightness systemBrightness) {
    if (state.themeMode == ThemeMode.system) {
      return systemBrightness == Brightness.dark;
    }
    return state.themeMode == ThemeMode.dark;
  }

  /// Check if using system theme
  bool get isSystemMode => state.themeMode == ThemeMode.system;
}
