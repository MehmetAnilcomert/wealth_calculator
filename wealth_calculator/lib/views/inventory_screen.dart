import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryBloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryState.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/widgets/InventoryWidgets/ItemDialogs.dart';
import 'package:wealth_calculator/widgets/CommonWidgets/total_price.dart';
import 'package:wealth_calculator/widgets/CommonWidgets/custom_sliver_appbar.dart';
import 'package:wealth_calculator/widgets/InventoryWidgets/list_widget.dart';

class InventoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final inventoryBloc = BlocProvider.of<InventoryBloc>(context);

    return Scaffold(
      backgroundColor: Color(0xFF2C3E50),
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
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
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
        backgroundColor: Color(0xFF3498DB),
        child: Icon(Icons.add, size: 32),
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        bloc: inventoryBloc,
        listener: (context, state) {
          if (state is InventoryError || state is PricesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hata: Veriler yüklenemedi'),
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
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
              ),
            );
          } else if (state is InventoryLoaded) {
            return Container(
              decoration: BoxDecoration(
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
                    expandedHeight: MediaQuery.of(context).size.height * 0.4,
                    collapsedHeight: MediaQuery.of(context).size.height * 0.4,
                    flexibleSpaceBackground: TotalPrice(
                      totalPrice: state.totalPrice,
                      segments: state.segments,
                      colors: state.colors,
                    ),
                    onAddPressed: () {},
                    bloc: inventoryBloc,
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
            return Center(
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
