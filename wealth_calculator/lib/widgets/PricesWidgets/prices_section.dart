import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/bloc/PricesBloc/pricesBloc.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/widgets/wealth_card.dart';

Widget buildPricesSection(BuildContext context, String type, String query) {
  return BlocBuilder<PricesBloc, PricesState>(
    builder: (context, state) {
      if (state is PricesLoading) {
        return Center(child: CircularProgressIndicator());
      } else if (state is PricesError) {
        return Center(child: Text('Error: ${state.message}'));
      } else if (state is PricesLoaded) {
        List<WealthPrice> prices = [];
        if (type == 'goldPrices') {
          prices = state.goldPrices;
        } else if (type == 'currencyPrices') {
          prices = state.currencyPrices;
        } else if (type == 'equityPrices') {
          prices = state.equityPrices;
        }

        prices = prices
            .where((price) =>
                price.title.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return buildEquityPricesTab(prices);
      } else {
        return Center(child: Text('No data available'));
      }
    },
  );
}
