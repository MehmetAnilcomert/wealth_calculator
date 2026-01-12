import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/product.dart';
import 'package:wealth_calculator/product/state/container/product_state_items.dart';
import 'package:wealth_calculator/product/state/viewmodel/product_state.dart';

/// Application entry point
Future<void> main() async {
  // Initialize all required services
  await ApplicationInitialize().startApplication();

  runApp(ProductLocalization(child: const StateInitialize(child: MyApp())));
}

/// Root application widget with clean architecture
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Localization
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // Theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      themeMode: ProductStateItems.productViewModel.state.themeMode,
      // Navigation
      initialRoute: AppRouter.initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
