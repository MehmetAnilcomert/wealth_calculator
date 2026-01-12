import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_bloc.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_screen_cubit.dart';
import 'package:wealth_calculator/feature/inventory/viewmodel/inventory_bloc.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_bloc.dart';
import 'package:wealth_calculator/feature/splash/viewmodel/splash_cubit.dart';
import 'package:wealth_calculator/product/state/container/product_state_items.dart';
import 'package:wealth_calculator/product/state/viewmodel/product_viewmodel.dart';

/// State initialization for BLoC providers
@immutable
final class StateInitialize extends StatelessWidget {
  const StateInitialize({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductViewmodel>.value(
          value: ProductStateItems.productViewModel,
        ),
        // Feature states
        BlocProvider(create: (context) => SplashCubit()),
        BlocProvider(create: (context) => PricesScreenCubit()),
        BlocProvider(create: (context) => PricesBloc()),
        BlocProvider(create: (context) => InventoryBloc()),
        BlocProvider(
          create: (context) => InvoiceBloc(),
        ),
      ],
      child: child,
    );
  }
}
