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
        return SelectItemDialog(
          futureGoldPrices: futureGoldPrices,
          futureCurrencyPrices: futureCurrencyPrices,
          onItemSelected: onItemSelected,
          disabledItems: disabledItems,
          hiddenItems: hiddenItems,
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
        return AlertDialog(
          title: Text('Miktarı Giriniz'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Miktar'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                int amount = int.tryParse(controller.text) ?? 0;
                onSave(entry.key, amount);
                Navigator.of(context).pop();
              },
              child: Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }
}

class SelectItemDialog extends StatefulWidget {
  final List<WealthPrice> futureGoldPrices;
  final List<WealthPrice> futureCurrencyPrices;
  final Function(SavedWealths, int) onItemSelected;
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

    // Eğer widget.futureGoldPrices ve widget.futureCurrencyPrices List türündeyse:
    goldPrices = widget.futureGoldPrices
        .where((price) => !widget.hiddenItems.contains(price.title))
        .toList();

    currencyPrices = widget.futureCurrencyPrices
        .where((price) => !widget.hiddenItems.contains(price.title))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(selectedOption),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            PopupMenuButton<String>(
              icon: ElevatedButton(
                onPressed: null,
                child: Text('Diğer Seçenekler'),
              ),
              onSelected: (String result) {
                setState(() {
                  selectedOption = result;
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
              ],
            ),
            ListBody(
              children: <Widget>[
                for (var price in selectedOption == 'Altın Seç'
                    ? goldPrices
                    : currencyPrices)
                  ListTile(
                    title: Text(price.title),
                    enabled: !widget.disabledItems.contains(price.title),
                    textColor: widget.disabledItems.contains(price.title)
                        ? Colors.grey
                        : null,
                    onTap: widget.disabledItems.contains(price.title)
                        ? null
                        : () async {
                            Navigator.of(context).pop();

                            SavedWealthsdao wealthsDao = SavedWealthsdao();
                            SavedWealths? existingWealth =
                                await wealthsDao.getWealthByType(price.title);

                            if (existingWealth != null) {
                              widget.onItemSelected(
                                  existingWealth, existingWealth.amount);
                            } else {
                              widget.onItemSelected(
                                SavedWealths(
                                  id: DateTime.now().millisecondsSinceEpoch,
                                  type: price.title,
                                  amount: 0,
                                ),
                                0,
                              );
                            }
                          },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
