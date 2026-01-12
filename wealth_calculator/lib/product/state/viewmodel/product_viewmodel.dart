import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/cache/product_cache.dart';
import 'package:wealth_calculator/product/state/base/base_cubit.dart';
import 'package:wealth_calculator/product/state/container/product_state_container.dart';
import 'package:wealth_calculator/product/state/viewmodel/product_state.dart';

/// A ViewModel class for managing product-related state.
final class ProductViewmodel extends BaseCubit<ProductState> {
  /// Creates an instance of [ProductViewmodel] with the given initial state.
  ProductViewmodel() : super(const ProductState());

  /// Changes the theme mode of the application and saves it to cache.
  void changeThemeMode({required ThemeMode themeMode}) {
    emit(state.copyWith(themeMode: themeMode));

    // Save theme preference to cache
    final productCache = ProductContainer.read<ProductCache>();
    productCache.saveThemeMode(themeMode);
  }

  /// Changes the locale of the application.
  void changeLanguage({required BuildContext context, required Locale locale}) {
    emit(state.copyWith(locale: locale));
    context.setLocale(locale);
  }
}
