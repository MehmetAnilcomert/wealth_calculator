import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/Bloc/InventoryBloc/InventoryBloc.dart';
import 'package:wealth_calculator/bloc/Bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/bloc/Bloc/PricesBloc/pricesBloc.dart';
import 'package:wealth_calculator/bloc/Bloc/PricesBloc/PricesEvent.dart';
import 'package:wealth_calculator/views/PriceViews.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GoldPricesBloc()..add(LoadGoldPrices()),
          child: PricesScreen(),
        ),
        BlocProvider(
          create: (context) => InventoryBloc()..add(LoadInventoryData()),
        ),
      ],
      child: MaterialApp(
        title: 'Emtia Fiyatları',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: PricesScreen(),
      ),
    );
  }
}
