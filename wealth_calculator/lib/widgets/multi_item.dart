import 'package:flutter/material.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';

class MultiItemDialogs {
  static void showMultiSelectItemDialog(
    BuildContext context,
    List<WealthPrice> futureGoldPrices,
    List<WealthPrice> futureCurrencyPrices,
    List<WealthPrice> futureEquityPrices,
    Function(List<WealthPrice>) onItemsSelected, {
    List<String> disabledItems = const [],
    List<String> hiddenItems = const [],
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return MultiSelectItemDialog(
          futureGoldPrices: futureGoldPrices,
          futureCurrencyPrices: futureCurrencyPrices,
          futureEquityPrices: futureEquityPrices,
          onItemsSelected: onItemsSelected,
          disabledItems: disabledItems,
          hiddenItems: hiddenItems,
        );
      },
    );
  }
}

class MultiSelectItemDialog extends StatefulWidget {
  final List<WealthPrice> futureGoldPrices;
  final List<WealthPrice> futureCurrencyPrices;
  final List<WealthPrice> futureEquityPrices;
  final Function(List<WealthPrice>) onItemsSelected;
  final List<String> disabledItems;
  final List<String> hiddenItems;

  MultiSelectItemDialog({
    required this.futureGoldPrices,
    required this.futureCurrencyPrices,
    required this.futureEquityPrices,
    required this.onItemsSelected,
    this.disabledItems = const [],
    this.hiddenItems = const [],
  });

  @override
  _MultiSelectItemDialogState createState() => _MultiSelectItemDialogState();
}

class _MultiSelectItemDialogState extends State<MultiSelectItemDialog> {
  List<WealthPrice> _selectedItems = [];
  String _selectedOption = 'Altın Seç';

  @override
  Widget build(BuildContext context) {
    final allItems = [
      ...widget.futureGoldPrices,
      ...widget.futureCurrencyPrices,
      ...widget.futureEquityPrices
    ].where((item) => !widget.hiddenItems.contains(item.title)).toList();

    return AlertDialog(
      title: Text('Seçim Yapın'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PopupMenuButton<String>(
            icon: ElevatedButton(
              onPressed: null,
              child: Text('$_selectedOption'),
            ),
            onSelected: (String result) {
              setState(() {
                _selectedOption = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Döviz Seç',
                child: Text('Döviz Seç'),
              ),
              const PopupMenuItem<String>(
                value: 'Altın Seç',
                child: Text('Altın Seç'),
              ),
              const PopupMenuItem<String>(
                value: 'Hisse Senetleri Seç',
                child: Text('Hisse Senetleri Seç'),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var price in _selectedOption == 'Altın Seç'
                      ? widget.futureGoldPrices
                      : _selectedOption == 'Döviz Seç'
                          ? widget.futureCurrencyPrices
                          : widget.futureEquityPrices)
                    ListTile(
                      title: Text(price.title),
                      enabled: !widget.disabledItems.contains(price.title),
                      textColor: widget.disabledItems.contains(price.title)
                          ? Colors.grey
                          : null,
                      onTap: widget.disabledItems.contains(price.title)
                          ? null
                          : () {
                              setState(() {
                                if (_selectedItems.contains(price)) {
                                  _selectedItems.remove(price);
                                } else {
                                  _selectedItems.add(price);
                                }
                              });
                            },
                      trailing: _selectedItems.contains(price)
                          ? Icon(Icons.check)
                          : null,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onItemsSelected(_selectedItems);
            Navigator.of(context).pop();
          },
          child: Text('Tamam'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('İptal'),
        ),
      ],
    );
  }
}
