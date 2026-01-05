import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_bloc.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_state.dart';

import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/widget/wealth_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';

Widget buildPricesSection(BuildContext context, String type, String query) {
  dynamic noop(WealthPrice price) {
    return 0;
  }

  return BlocBuilder<PricesBloc, PricesState>(
    builder: (context, state) {
      if (state is PricesLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is PricesError) {
        return Center(
          child: Text('${LocaleKeys.error.tr()}: ${state.message}'),
        );
      } else if (state is PricesLoaded) {
        List<WealthPrice> prices = [];
        if (type == 'goldPrices') {
          prices = state.goldPrices;
        } else if (type == 'currencyPrices') {
          prices = state.currencyPrices;
        } else if (type == 'equityPrices') {
          prices = state.equityPrices;
        } else if (type == 'commodityPrices') {
          prices = state.commodityPrices;
        }

        prices = prices
            .where((price) =>
                price.title.toLowerCase().contains(query.toLowerCase()))
            .toList();

        if (prices.isEmpty) {
          return Center(child: Text(LocaleKeys.noDataAvailable.tr()));
        }

        return buildEquityPricesTab(prices, noop);
      } else {
        return Center(child: Text(LocaleKeys.noDataAvailable.tr()));
      }
    },
  );
}
