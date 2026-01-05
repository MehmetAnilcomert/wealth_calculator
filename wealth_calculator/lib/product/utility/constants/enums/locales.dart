import 'package:flutter/material.dart';

/// Enum representing supported locales in the application
enum Locales {
  /// Turkish locale
  tr(Locale('tr')),

  /// English locale
  en(Locale('en')); // English

  /// Constructor to initialize the locale
  const Locales(this.locale);

  /// The locale associated with the enum value
  final Locale locale;

  /// List of all supported locales
  static final List<Locale> supportedLocales = [
    for (var locale in Locales.values) locale.locale,
  ];
}
