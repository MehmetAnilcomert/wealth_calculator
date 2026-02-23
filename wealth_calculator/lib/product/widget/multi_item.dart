import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/theme/custom_colors.dart';

class MultiItemDialogs {
  static void showMultiSelectItemDialog(
    BuildContext context,
    List<WealthPrice> futureGoldPrices,
    List<WealthPrice> futureCurrencyPrices,
    List<WealthPrice> futureEquityPrices,
    List<WealthPrice> futureCommodityPrices,
    Function(List<WealthPrice>) onItemsSelected, {
    List<String> disabledItems = const [],
    List<String> hiddenItems = const [],
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: context.general.colorScheme.transparent,
          child: MultiSelectItemDialog(
            futureGoldPrices: futureGoldPrices,
            futureCurrencyPrices: futureCurrencyPrices,
            futureEquityPrices: futureEquityPrices,
            futureCommodityPrices: futureCommodityPrices,
            onItemsSelected: onItemsSelected,
            disabledItems: disabledItems,
            hiddenItems: hiddenItems,
          ),
        );
      },
    );
  }
}

class MultiSelectItemDialog extends StatefulWidget {
  final List<WealthPrice> futureGoldPrices;
  final List<WealthPrice> futureCurrencyPrices;
  final List<WealthPrice> futureEquityPrices;
  final List<WealthPrice> futureCommodityPrices;
  final Function(List<WealthPrice>) onItemsSelected;
  final List<String> disabledItems;
  final List<String> hiddenItems;

  const MultiSelectItemDialog({
    super.key,
    required this.futureGoldPrices,
    required this.futureCurrencyPrices,
    required this.futureEquityPrices,
    required this.futureCommodityPrices,
    required this.onItemsSelected,
    this.disabledItems = const [],
    this.hiddenItems = const [],
  });

  @override
  _MultiSelectItemDialogState createState() => _MultiSelectItemDialogState();
}

class _MultiSelectItemDialogState extends State<MultiSelectItemDialog> {
  final Map<String, List<WealthPrice>> _selectedItemsByCategory = {
    'Altın': [],
    'Döviz': [],
    'Hisse Senetleri': [],
    'Emtia': [],
  };
  String _selectedOption = LocaleKeys.gold.tr();

  List<WealthPrice> getSelectedList() {
    switch (_selectedOption) {
      case 'Döviz':
        return widget.futureCurrencyPrices;
      case 'Hisse Senetleri':
        return widget.futureEquityPrices;
      case 'Emtia':
        return widget.futureCommodityPrices;
      case 'Altın':
      default:
        return widget.futureGoldPrices;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    final allItems = getSelectedList()
        .where((item) => !widget.hiddenItems.contains(item.title))
        .toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.gradientStart,
            colorScheme.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.blackOverlay10,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.whiteOverlay10,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.selectItems.tr(),
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.whiteOverlay20,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedOption,
                          style:
                              TextStyle(color: colorScheme.onPrimaryContainer),
                        ),
                        Icon(Icons.arrow_drop_down,
                            color: colorScheme.onPrimaryContainer),
                      ],
                    ),
                  ),
                  onSelected: (String result) {
                    setState(() {
                      _selectedOption = result;
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    _buildPopupMenuItem(
                        LocaleKeys.gold.tr(), Icons.monetization_on),
                    _buildPopupMenuItem(
                        LocaleKeys.currency.tr(), Icons.currency_exchange),
                    _buildPopupMenuItem(
                        LocaleKeys.stocks.tr(), Icons.show_chart),
                    _buildPopupMenuItem(
                        LocaleKeys.commodities.tr(), Icons.diamond),
                  ],
                ),
              ],
            ),
          ),
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: allItems
                      .map((price) => _buildListItem(
                            price,
                            _selectedItemsByCategory[_selectedOption]
                                    ?.contains(price) ??
                                false,
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    LocaleKeys.cancel.tr(),
                    style: TextStyle(
                        color: colorScheme.onPrimaryContainer.withAlpha(179)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    List<WealthPrice> allSelectedItems =
                        _selectedItemsByCategory.values
                            .expand((items) => items)
                            .toList();
                    widget.onItemsSelected(allSelectedItems);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: colorScheme.onPrimary,
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(LocaleKeys.ok.tr()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon) {
    final colorScheme = context.general.colorScheme;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildListItem(WealthPrice price, bool isSelected) {
    final colorScheme = context.general.colorScheme;
    final isDisabled = widget.disabledItems.contains(price.title);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDisabled
            ? colorScheme.whiteOverlay10.withAlpha(13)
            : colorScheme.whiteOverlay10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          price.title,
          style: TextStyle(
            color: isDisabled
                ? colorScheme.disabledText
                : colorScheme.onPrimaryContainer,
            fontSize: 16,
          ),
        ),
        enabled: !isDisabled,
        onTap: isDisabled
            ? null
            : () {
                setState(() {
                  if (isSelected) {
                    _selectedItemsByCategory[_selectedOption]?.remove(price);
                  } else {
                    _selectedItemsByCategory[_selectedOption]?.add(price);
                  }
                });
              },
        trailing: isSelected
            ? Icon(Icons.check_circle, color: colorScheme.tertiary)
            : Icon(Icons.circle_outlined,
                color: colorScheme.onPrimaryContainer.withAlpha(179)),
      ),
    );
  }
}
