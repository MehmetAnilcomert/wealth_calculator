import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';

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
          backgroundColor: Colors.transparent,
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

  MultiSelectItemDialog({
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
  Map<String, List<WealthPrice>> _selectedItemsByCategory = {
    'Altın': [],
    'Döviz': [],
    'Hisse Senetleri': [],
    'Emtia': [],
  };
  String _selectedOption = 'Altın';

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
    final allItems = getSelectedList()
        .where((item) => !widget.hiddenItems.contains(item.title))
        .toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E50),
            Color(0xFF3498DB),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seçim Yapın',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedOption,
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.white),
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
                    _buildPopupMenuItem('Altın', Icons.monetization_on),
                    _buildPopupMenuItem('Döviz', Icons.currency_exchange),
                    _buildPopupMenuItem('Hisse Senetleri', Icons.show_chart),
                    _buildPopupMenuItem('Emtia', Icons.diamond),
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
                padding: EdgeInsets.symmetric(vertical: 8),
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
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'İptal',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                SizedBox(width: 8),
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
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF3498DB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Tamam'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Color(0xFF3498DB)),
          SizedBox(width: 12),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildListItem(WealthPrice price, bool isSelected) {
    final isDisabled = widget.disabledItems.contains(price.title);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isDisabled ? 0.05 : 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          price.title,
          style: TextStyle(
            color: isDisabled ? Colors.white38 : Colors.white,
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
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.circle_outlined, color: Colors.white70),
      ),
    );
  }
}
