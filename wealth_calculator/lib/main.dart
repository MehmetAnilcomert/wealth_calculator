import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/product.dart';
import 'package:wealth_calculator/product/theme/dark_theme/custom_dark_theme.dart';
import 'package:wealth_calculator/product/theme/light_theme/custom_light_theme.dart';

/// Application entry point
Future<void> main() async {
  // Initialize all required services
  await ApplicationInitialize().startApplication();

  runApp(ProductLocalization(child: const StateInitialize(child: WealthCalculator())));
}

/// Root application widget with clean architecture
class WealthCalculator extends StatelessWidget {
  const WealthCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Localization
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // Theme
      theme: CustomLightTheme().themeData,
      darkTheme: CustomDarkTheme().themeData,
      themeMode: context
          .watch<ProductViewmodel>()
          .state
          .themeMode, // Listen to theme mode changes
      // Navigation
      initialRoute: AppRouter.initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
