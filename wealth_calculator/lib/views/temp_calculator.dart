import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        body: BlocConsumer<TempInventoryBloc, TempInventoryState>(
          listener: (context, state) {
            if (state is InventoryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
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
                    bloc: context.read<TempInventoryBloc>(),
                  ),
                  SliverFillRemaining(
                    child: TempInventoryListWidget(
                      savedWealths: state.savedWealths,
                      colors: state.colors,
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: Text('Unknown state'));
            }
          },
        ),
      ),
    );
  }
}
