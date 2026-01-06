import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_bloc.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_event.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_state.dart';
import 'package:wealth_calculator/product/widget/CommonWidgets/custom_sliver_appbar.dart';
import 'package:wealth_calculator/product/widget/CommonWidgets/total_price.dart';
import 'package:wealth_calculator/product/widget/InventoryWidgets/item_dialogs.dart';
import 'package:wealth_calculator/product/widget/calculator_list.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';

class CalculatorView extends StatelessWidget {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalculatorBloc()..add(const LoadCalculatorData()),
      child: Scaffold(
        backgroundColor: const Color(0xFF2C3E50),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            LocaleKeys.wealthCalculator.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        floatingActionButton: BlocBuilder<CalculatorBloc, CalculatorState>(
          builder: (context, state) {
            if (state is CalculatorLoaded) {
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
                              .read<CalculatorBloc>()
                              .add(AddOrUpdateCalculatorWealth(wealth, amount));
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
            return const SizedBox.shrink();
          },
        ),
        body: BlocConsumer<CalculatorBloc, CalculatorState>(
          listener: (context, state) {
            if (state is CalculatorError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${LocaleKeys.error.tr()}: ${LocaleKeys.noDataAvailable.tr()}'),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is CalculatorLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                ),
              );
            } else if (state is CalculatorLoaded) {
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
                      bloc: context.read<CalculatorBloc>(),
                    ),
                    SliverFillRemaining(
                      child: CalculatorListWidget(
                        savedWealths: state.savedWealths,
                        colors: state.colors,
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
      ),
    );
  }
}
