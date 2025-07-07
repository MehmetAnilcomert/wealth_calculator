import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationCubit extends Cubit<Locale> {
  static const String _languageKey = 'selected_language';

  LocalizationCubit() : super(const Locale('en')) {
    _loadSavedLanguage();
  }

  void setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    emit(Locale(languageCode));
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    if (savedLanguage != null) {
      emit(Locale(savedLanguage));
    }
  }

  bool get isEnglish => state.languageCode == 'en';
  bool get isTurkish => state.languageCode == 'tr';
}
