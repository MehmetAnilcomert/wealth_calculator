import 'package:flutter/material.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/modals/Wealths.dart';
import 'package:wealth_calculator/services/Wealthsdao.dart';

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
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Miktarı Giriniz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Miktar',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'İptal',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        int amount = int.tryParse(controller.text) ?? 0;
                        onSave(entry.key, amount);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF3498DB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Kaydet'),
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

  SelectItemDialog({
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
  String selectedOption = 'Altın Seç';
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
                  selectedOption,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (String result) {
                    setState(() {
                      selectedOption = result;
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    _buildPopupMenuItem('Döviz Seç', Icons.currency_exchange),
                    _buildPopupMenuItem('Altın Seç', Icons.monetization_on),
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
                  children: [
                    ...(selectedOption == 'Altın Seç'
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

  Widget _buildListItem(WealthPrice price, BuildContext context) {
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
          color: isDisabled ? Colors.white38 : Colors.white70,
          size: 16,
        ),
      ),
    );
  }
}
