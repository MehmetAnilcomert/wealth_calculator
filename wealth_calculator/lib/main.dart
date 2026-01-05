import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryBloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/pricesBloc.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesEvent.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_bloc.dart';
import 'package:wealth_calculator/bloc/PricesScreenCubit.dart';
import 'package:wealth_calculator/bloc/LocalizationCubit/localization_cubit.dart';
import 'package:wealth_calculator/l10n/app_localizations.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';
import 'package:wealth_calculator/services/Notification.dart';
import 'package:wealth_calculator/views/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  tz.initializeTimeZones();

  final databaseHelper = DbHelper.instance;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LocalizationCubit()),
        BlocProvider(create: (context) => PricesScreenCubit()),
        BlocProvider(
          create: (context) => PricesBloc()..add(LoadPrices()),
        ),
        BlocProvider(
          create: (context) => InventoryBloc()..add(LoadInventoryData()),
        ),
        BlocProvider(
          create: (context) => InvoiceBloc(),
        ),
      ],
      child: BlocBuilder<LocalizationCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: const [
              Locale('en'),
              Locale('tr'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
