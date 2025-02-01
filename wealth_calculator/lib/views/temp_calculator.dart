import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/bloc/TempCalculatorBloc/tempBloc.dart';
import 'package:wealth_calculator/bloc/TempCalculatorBloc/tempEvent.dart';
import 'package:wealth_calculator/bloc/TempCalculatorBloc/tempState.dart';
import 'package:wealth_calculator/widgets/CommonWidgets/custom_sliver_appbar.dart';
import 'package:wealth_calculator/widgets/CommonWidgets/total_price.dart';
import 'package:wealth_calculator/widgets/InventoryWidgets/ItemDialogs.dart';
import 'package:wealth_calculator/widgets/calculator_list.dart';

class CalculatorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TempInventoryBloc()..add(LoadInventoryData()),
      child: Scaffold(
        backgroundColor: const Color(0xFF2C3E50),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            "Varlık Hesaplama Makinesi",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        floatingActionButton:
            BlocBuilder<TempInventoryBloc, TempInventoryState>(
          builder: (context, state) {
            if (state is InventoryLoaded) {
              return FloatingActionButton(
                onPressed: () {
                  ItemDialogs.showSelectItemDialog(
                    context,
                    state.goldPrices,
                    state.currencyPrices,
                    (wealth, amount) {
                      ItemDialogs.showEditItemDialog(
                        context,
                        MapEntry(wealth, 0),
                        (wealth, amount) {
                          context
                              .read<TempInventoryBloc>()
                              .add(AddOrUpdateWealth(wealth, amount));
                        },
                      );
                    },
                    hiddenItems: [
                      'Altın (ONS/\$)',
                      'Altın (\$/kg)',
                      'Altın (Euro/kg)',
                      'Külçe Altın (\$)'
                    ],
                  );
                },
                backgroundColor: const Color(0xFF3498DB),
                child: const Icon(Icons.add, size: 32),
              );
            }
            return Container();
          },
        ),
        body: BlocConsumer<TempInventoryBloc, TempInventoryState>(
          listener: (context, state) {
            if (state is InventoryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Hata: Veriler yüklenemedi'),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            } else if (state is PricesLoaded) {
              context.read<TempInventoryBloc>().add(LoadInventoryData());
            }
          },
          builder: (context, state) {
            if (state is InventoryLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                ),
              );
            } else if (state is InventoryLoaded) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2C3E50),
                      Color(0xFF3498DB),
                    ],
                  ),
                ),
                child: CustomScrollView(
                  slivers: [
                    CustomSliverAppBar(
                      expandedHeight: MediaQuery.of(context).size.height * 0.35,
                      collapsedHeight:
                          MediaQuery.of(context).size.height * 0.35,
                      flexibleSpaceBackground: TotalPrice(
                        totalPrice: state.totalPrice,
                        segments: state.segments,
                        colors: state.colors,
                      ),
                      onAddPressed: () {},
                      bloc: context.read<TempInventoryBloc>(),
                    ),
                    SliverFillRemaining(
                      child: TempInventoryListWidget(
                        savedWealths: state.savedWealths,
                        colors: state.colors,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text(
                  'Veriler yüklenirken hata oldu',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
