import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_bloc.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_event.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_state.dart';
import 'package:wealth_calculator/l10n/app_localizations.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/widget/multi_item.dart';

abstract class PricesScreenUtils {
  static String getAppBarTitle(int index, AppLocalizations l10n) {
    final titles = [
      l10n.goldPrices,
      l10n.currencyPrices,
      l10n.stocksBist,
      l10n.commoditiesPrices,
      l10n.portfolioIndividual,
    ];
    return titles[index.clamp(0, 6)];
  }

  static void onAddPressed(BuildContext context) {
    MultiItemDialogs.showMultiSelectItemDialog(
      context,
      context.read<PricesBloc>().state is PricesLoaded
          ? (context.read<PricesBloc>().state as PricesLoaded).goldPrices
          : [],
      context.read<PricesBloc>().state is PricesLoaded
          ? (context.read<PricesBloc>().state as PricesLoaded).currencyPrices
          : [],
      context.read<PricesBloc>().state is PricesLoaded
          ? (context.read<PricesBloc>().state as PricesLoaded).equityPrices
          : [],
      context.read<PricesBloc>().state is PricesLoaded
          ? (context.read<PricesBloc>().state as PricesLoaded).commodityPrices
          : [],
      (List<WealthPrice> selectedWealths) {
        context.read<PricesBloc>().add(AddCustomPrice(selectedWealths));
      },
      hiddenItems: [
        'Altın (ONS/\$)',
        'Altın (\$/kg)',
        'Altın (Euro/kg)',
        'Külçe Altın (\$)',
      ],
    );
  }
}
