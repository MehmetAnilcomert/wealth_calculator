import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryBloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryState.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/widgets/InventoryWidgets/ItemDialogs.dart';
import 'package:wealth_calculator/widgets/CommonWidgets/total_price.dart';
import 'package:wealth_calculator/widgets/InventoryWidgets/list_widget.dart';
import 'package:wealth_calculator/widgets/InventoryWidgets/price_history_chart.dart';
import 'package:wealth_calculator/widgets/InventoryWidgets/swipable_appbar.dart';

class InventoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final inventoryBloc = BlocProvider.of<InventoryBloc>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Varlıklar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (inventoryBloc.state is InventoryLoaded) {
            final state = inventoryBloc.state as InventoryLoaded;
            ItemDialogs.showSelectItemDialog(
              context,
              state.goldPrices,
              state.currencyPrices,
              (wealth, amount) {
                ItemDialogs.showEditItemDialog(
                  context,
                  MapEntry(wealth, amount),
                  (wealth, amount) {
                    context
                        .read<InventoryBloc>()
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
          }
        },
        backgroundColor: const Color.fromARGB(255, 90, 189, 255),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        bloc: inventoryBloc,
        listener: (context, state) {
          if (state is InventoryError || state is PricesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Hata: Veriler yüklenemedi'),
                backgroundColor: Colors.red.shade400,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
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
                  SwipableAppBar(
                    expandedHeight: MediaQuery.of(context).size.height * 0.4,
                    collapsedHeight: MediaQuery.of(context).size.height * 0.4,
                    onAddPressed: () {},
                    bloc: inventoryBloc,
                    pages: [
                      // TotalPrice widget to show total price of all wealths in inventory at that moment,
                      TotalPrice(
                        totalPrice: state.totalPrice,
                        segments: state.segments,
                        colors: state.colors,
                      ),
                      // PriceHistoryChart widget to show wealth price history,
                      PriceHistoryChart(pricesHistory: state.pricesHistory),
                    ],
                  ),
                  SliverFillRemaining(
                    child: InventoryListWidget(
                      colors: state.colors,
                      savedWealths: state.savedWealths,
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
    );
  }
}
