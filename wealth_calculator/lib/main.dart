import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wealth_calculator/l10n/app_localizations.dart';
import 'package:wealth_calculator/product/product.dart';

/// Application entry point
Future<void> main() async {
  // Initialize all required services
  await ApplicationInitialize.init();

  runApp(const MyApp());
}

/// Root application widget with clean architecture
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StateInitialize(
      child: BlocBuilder<LocalizationCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            // Localization
            locale: locale,
            supportedLocales: AppConstants.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Theme
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),

            // Navigation
            initialRoute: AppRouter.initialRoute,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
