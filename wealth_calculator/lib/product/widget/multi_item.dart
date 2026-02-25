import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/theme/custom_colors.dart';

/// Locale-independent category keys for the multi-select dialog.
enum _Category { gold, currency, stocks, commodities }

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
  State<MultiSelectItemDialog> createState() => _MultiSelectItemDialogState();
}

class _MultiSelectItemDialogState extends State<MultiSelectItemDialog> {
  final Map<_Category, List<WealthPrice>> _selectedItemsByCategory = {
    _Category.gold: [],
    _Category.currency: [],
    _Category.stocks: [],
    _Category.commodities: [],
  };
  _Category _selectedCategory = _Category.gold;

  List<WealthPrice> getSelectedList() {
    switch (_selectedCategory) {
      case _Category.currency:
        return widget.futureCurrencyPrices;
      case _Category.stocks:
        return widget.futureEquityPrices;
      case _Category.commodities:
        return widget.futureCommodityPrices;
      case _Category.gold:
        return widget.futureGoldPrices;
    }
  }

  String _categoryLabel(_Category cat) {
    switch (cat) {
      case _Category.gold:
        return LocaleKeys.gold.tr();
      case _Category.currency:
        return LocaleKeys.currency.tr();
      case _Category.stocks:
        return LocaleKeys.stocks.tr();
      case _Category.commodities:
        return LocaleKeys.commodities.tr();
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
                PopupMenuButton<_Category>(
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
                          _categoryLabel(_selectedCategory),
                          style:
                              TextStyle(color: colorScheme.onPrimaryContainer),
                        ),
                        Icon(Icons.arrow_drop_down,
                            color: colorScheme.onPrimaryContainer),
                      ],
                    ),
                  ),
                  onSelected: (_Category result) {
                    setState(() {
                      _selectedCategory = result;
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<_Category>>[
                    _buildPopupMenuItem(
                        _Category.gold, Icons.monetization_on, LocaleKeys.gold.tr()),
                    _buildPopupMenuItem(
                        _Category.currency, Icons.currency_exchange, LocaleKeys.currency.tr()),
                    _buildPopupMenuItem(
                        _Category.stocks, Icons.show_chart, LocaleKeys.stocks.tr()),
                    _buildPopupMenuItem(
                        _Category.commodities, Icons.diamond, LocaleKeys.commodities.tr()),
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
                            _selectedItemsByCategory[_selectedCategory]
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

  PopupMenuItem<_Category> _buildPopupMenuItem(
      _Category value, IconData icon, String label) {
    final colorScheme = context.general.colorScheme;
    return PopupMenuItem<_Category>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Text(label),
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
                    _selectedItemsByCategory[_selectedCategory]?.remove(price);
                  } else {
                    _selectedItemsByCategory[_selectedCategory]?.add(price);
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
