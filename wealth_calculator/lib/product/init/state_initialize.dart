import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/product/state/localization_cubit.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_bloc.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_event.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_screen_cubit.dart';
import 'package:wealth_calculator/feature/inventory/viewmodel/inventory_bloc.dart';
import 'package:wealth_calculator/feature/inventory/viewmodel/inventory_event.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_bloc.dart';

/// State initialization for BLoC providers
@immutable
final class StateInitialize extends StatelessWidget {
  const StateInitialize({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Global state
        BlocProvider(create: (context) => LocalizationCubit()),

        // Feature states
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
      child: child,
    );
  }
}
