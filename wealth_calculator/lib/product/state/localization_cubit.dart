import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global localization state management
class LocalizationCubit extends Cubit<Locale> {
  LocalizationCubit() : super(const Locale('en')) {
    _loadSavedLanguage();
  }

  static const String _languageKey = 'selected_language';

  /// Set the application language
  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    emit(Locale(languageCode));
  }

  /// Load saved language from preferences
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    if (savedLanguage != null) {
      emit(Locale(savedLanguage));
    }
  }

  /// Check if current language is English
  bool get isEnglish => state.languageCode == 'en';

  /// Check if current language is Turkish
  bool get isTurkish => state.languageCode == 'tr';
}
