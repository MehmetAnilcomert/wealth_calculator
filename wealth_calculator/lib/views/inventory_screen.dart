import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryBloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryState.dart';
import 'package:wealth_calculator/widgets/InventoryWidgets/ItemDialogs.dart';
import 'package:wealth_calculator/widgets/CommonWidgets/total_price.dart';
import 'package:wealth_calculator/widgets/CommonWidgets/custom_sliver_appbar.dart';
import 'package:wealth_calculator/widgets/InventoryWidgets/list_widget.dart';

class InventoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mevcut Bloc'u kullanmak için BlocProvider.value kullanıyoruz
    final inventoryBloc = BlocProvider.of<InventoryBloc>(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Varlıklar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        bloc: inventoryBloc, // Aynı Bloc'u kullandığınızdan emin olun
        listener: (context, state) {
          if (state is InventoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hata: Veriler yüklenemedi'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is InventoryLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is InventoryLoaded) {
            return CustomScrollView(
              slivers: [
                CustomSliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * 0.35,
                  collapsedHeight: MediaQuery.of(context).size.height * 0.35,
                  flexibleSpaceBackground: TotalPrice(
                    totalPrice: state.totalPrice,
                    segments: state.segments,
                    colors: state.colors,
                  ),
                  onAddPressed: () {
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
                  },
                  bloc: inventoryBloc, // Aynı Bloc'u kullanın
                ),
                SliverFillRemaining(
                  child: InventoryListWidget(
                      colors: state.colors, savedWealths: state.savedWealths),
                ),
              ],
            );
          } else {
            return Center(child: Text('Veriler yüklenirken hata oldu'));
          }
        },
      ),
    );
  }
}
