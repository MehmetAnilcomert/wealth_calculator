import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/widget/wealth_card.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';

class CustomPricesWidget extends StatelessWidget {
  final List<dynamic> customPrices;
  final Function() onAddPressed;
  final String query;
  final Function(WealthPrice) onDeletePrice;
  const CustomPricesWidget(
      {super.key,
      required this.customPrices,
      required this.onAddPressed,
      required this.query,
      required this.onDeletePrice});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 5),
            Expanded(
              child: customPrices.isEmpty
                  ? Center(child: const Text(LocaleKeys.noSelection).tr())
                  : buildCustomPrices(customPrices, query),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: IconButton(
            onPressed: onAddPressed,
            icon: Icon(Icons.add, color: colorScheme.onSecondaryContainer),
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all(colorScheme.secondaryContainer),
              elevation: WidgetStateProperty.all(4),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              padding: WidgetStateProperty.all(const EdgeInsets.all(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCustomPrices(List<dynamic> customPrices, String query) {
    // Filtreleme işlemi
    List filteredPrices = customPrices.where((price) {
      return price.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return buildEquityPricesTab(filteredPrices, onDeletePrice);
  }
}
