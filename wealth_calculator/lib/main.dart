import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/product.dart';

/// Application entry point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all required services
  await ApplicationInitialize().startApplication();

  runApp(ProductLocalization(child: const MyApp()));
}

/// Root application widget with clean architecture
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StateInitialize(
      child: MaterialApp(
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

        // Navigation
        initialRoute: AppRouter.initialRoute,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
