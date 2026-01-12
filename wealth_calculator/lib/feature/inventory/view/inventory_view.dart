import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/inventory/viewmodel/inventory_bloc.dart';
import 'package:wealth_calculator/feature/inventory/viewmodel/inventory_event.dart';
import 'package:wealth_calculator/feature/inventory/viewmodel/inventory_state.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_state.dart';
import 'package:wealth_calculator/product/widget/InventoryWidgets/item_dialogs.dart';
import 'package:wealth_calculator/product/widget/CommonWidgets/total_price.dart';
import 'package:wealth_calculator/product/widget/InventoryWidgets/list_widget.dart';
import 'package:wealth_calculator/product/widget/InventoryWidgets/price_history_chart.dart';
import 'package:wealth_calculator/product/widget/InventoryWidgets/swipable_appbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/theme/custom_colors.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    final inventoryBloc = BlocProvider.of<InventoryBloc>(context);

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          LocaleKeys.assets.tr(),
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorScheme.transparent,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios, color: colorScheme.onPrimaryContainer),
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
        backgroundColor: colorScheme.secondaryContainer,
        child:
            Icon(Icons.add, size: 32, color: colorScheme.onSecondaryContainer),
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        bloc: inventoryBloc,
        listener: (context, state) {
          if (state is InventoryError || state is PricesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${LocaleKeys.error.tr()}: ${LocaleKeys.noDataAvailable.tr()}'),
                backgroundColor: colorScheme.deleteBackground,
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
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            );
          } else if (state is InventoryLoaded) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.gradientStart,
                    colorScheme.gradientEnd,
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
                      TotalPrice(
                        totalPrice: state.totalPrice,
                        segments: state.segments,
                        colors: state.colors,
                      ),
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
            return Center(
              child: Text(
                LocaleKeys.error.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
        },
      ),
    );
  }
}
