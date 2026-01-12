import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';
import 'package:wealth_calculator/product/service/wealths_dao.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/theme/custom_colors.dart';

class ItemDialogs {
  static void showSelectItemDialog(
    BuildContext context,
    List<WealthPrice> futureGoldPrices,
    List<WealthPrice> futureCurrencyPrices,
    Function(SavedWealths, int) onItemSelected, {
    List<String> disabledItems = const [],
    List<String> hiddenItems = const [],
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SelectItemDialog(
            futureGoldPrices: futureGoldPrices,
            futureCurrencyPrices: futureCurrencyPrices,
            onItemSelected: onItemSelected,
            disabledItems: disabledItems,
            hiddenItems: hiddenItems,
          ),
        );
      },
    );
  }

  static void showEditItemDialog(
    BuildContext context,
    MapEntry<SavedWealths, int> entry,
    Function(SavedWealths, int) onSave,
  ) {
    final colorScheme = context.general.colorScheme;
    TextEditingController controller = TextEditingController(
      text: entry.value.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.enterAmount.tr(),
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: colorScheme.onPrimaryContainer),
                  decoration: InputDecoration(
                    labelText: LocaleKeys.amount.tr(),
                    labelStyle: TextStyle(
                        color: colorScheme.onPrimaryContainer.withAlpha(179)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: colorScheme.onPrimaryContainer.withAlpha(77)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        LocaleKeys.cancel.tr(),
                        style: TextStyle(
                            color:
                                colorScheme.onPrimaryContainer.withAlpha(179)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        int amount = int.tryParse(controller.text) ?? 0;
                        onSave(entry.key, amount);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: colorScheme.onPrimary,
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(LocaleKeys.save.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SelectItemDialog extends StatefulWidget {
  final List<WealthPrice> futureGoldPrices;
  final List<WealthPrice> futureCurrencyPrices;
  final Function(SavedWealths, int)? onItemSelected;
  final List<String> disabledItems;
  final List<String> hiddenItems;

  const SelectItemDialog({
    super.key,
    required this.futureGoldPrices,
    required this.futureCurrencyPrices,
    required this.onItemSelected,
    this.disabledItems = const [],
    this.hiddenItems = const [],
  });

  @override
  _SelectItemDialogState createState() => _SelectItemDialogState();
}

class _SelectItemDialogState extends State<SelectItemDialog> {
  String selectedOption = 'selectGold';
  List<WealthPrice> goldPrices = [];
  List<WealthPrice> currencyPrices = [];

  @override
  void initState() {
    super.initState();
    goldPrices = widget.futureGoldPrices
        .where((price) => !widget.hiddenItems.contains(price.title))
        .toList();
    currencyPrices = widget.futureCurrencyPrices
        .where((price) => !widget.hiddenItems.contains(price.title))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
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
                  selectedOption == 'selectGold'
                      ? LocaleKeys.selectGold.tr()
                      : LocaleKeys.selectCurrency.tr(),
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      color: colorScheme.onPrimaryContainer),
                  onSelected: (String result) {
                    setState(() {
                      selectedOption = result;
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    _buildPopupMenuItem(
                        'selectCurrency',
                        Icons.currency_exchange,
                        LocaleKeys.selectCurrency.tr()),
                    _buildPopupMenuItem('selectGold', Icons.monetization_on,
                        LocaleKeys.selectGold.tr()),
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
                  children: [
                    ...(selectedOption == 'selectGold'
                            ? goldPrices
                            : currencyPrices)
                        .map((price) => _buildListItem(price, context)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      String value, IconData icon, String text) {
    final colorScheme = context.general.colorScheme;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildListItem(WealthPrice price, BuildContext context) {
    final colorScheme = context.general.colorScheme;
    final isDisabled = widget.disabledItems.contains(price.title);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDisabled
            ? colorScheme.whiteOverlay05
            : colorScheme.whiteOverlay10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          price.title,
          style: TextStyle(
            color: isDisabled
                ? colorScheme.onPrimaryContainer.withAlpha(97)
                : colorScheme.onPrimaryContainer,
            fontSize: 16,
          ),
        ),
        enabled: !isDisabled,
        onTap: isDisabled
            ? null
            : () async {
                Navigator.of(context).pop();
                SavedWealthsdao wealthsDao = SavedWealthsdao();
                SavedWealths? existingWealth =
                    await wealthsDao.getWealthByType(price.title);

                if (existingWealth != null) {
                  widget.onItemSelected!(existingWealth, existingWealth.amount);
                } else {
                  widget.onItemSelected!(
                    SavedWealths(
                      id: DateTime.now().millisecondsSinceEpoch,
                      type: price.title,
                      amount: 0,
                    ),
                    0,
                  );
                }
              },
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDisabled
              ? colorScheme.onPrimaryContainer.withAlpha(97)
              : colorScheme.onPrimaryContainer.withAlpha(179),
          size: 16,
        ),
      ),
    );
  }
}
