import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/utility/constants/enums/locales.dart';

@immutable

/// A class that sets up localization for the application using EasyLocalization
/// ( Product localization manager )
class ProductLocalization extends EasyLocalization {
  /// Initializes localization settings for the application
  /// Parameters:
  /// - [child]: The root widget of the application
  ProductLocalization({required super.child, super.key})
      : super(
          supportedLocales: _supportedLocales,
          path: _translationsPath,
          useOnlyLangCode: true,
        );

  /// List of supported locales in the application
  static final List<Locale> _supportedLocales = [
    Locales.tr.locale,
    Locales.en.locale,
  ];

  /// The path to the translations assets
  static const String _translationsPath = 'assets/translations';

  /// Updates the application's locale
  static Future<void> updateLang({
    required BuildContext context,
    required Locale locale,
  }) =>
      context.setLocale(locale);
}
