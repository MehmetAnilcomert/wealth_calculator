import 'package:flutter/material.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/modals/Wealths.dart';
import 'package:wealth_calculator/services/Wealthsdao.dart';

class SelectItemDialog extends StatelessWidget {
  final Future<List<WealthPrice>> futureGoldPrices;
  final Future<List<WealthPrice>> futureCurrencyPrices;
  final Function onItemSelected;

  SelectItemDialog({
    required this.futureGoldPrices,
    required this.futureCurrencyPrices,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<WealthPrice>>>(
      future: Future.wait([futureGoldPrices, futureCurrencyPrices]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Fiyat bilgileri bulunamadı'));
        } else {
          List<WealthPrice> goldPrices = snapshot.data![0];
          List<WealthPrice> currencyPrices = snapshot.data![1];

          return AlertDialog(
            title: Text('Altın Seç'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      _showCurrencyList(context, currencyPrices,
                          goldPrices); // Bu kısımda sıkıntı var incele ve düzelt Ekranda kalıyor kalmazsa döviz seçilip eklenemiyor
                    },
                    child: Text('Döviz Seç'),
                  ),
                  ListBody(
                    children: <Widget>[
                      for (var price in goldPrices)
                        ListTile(
                          title: Text(price.title),
                          onTap: () async {
                            Navigator.of(context).pop();
                            _handleItemSelection(price.title, onItemSelected);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  void _showCurrencyList(BuildContext context, List<WealthPrice> currencyPrices,
      List<WealthPrice> goldPrices) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Döviz Seç'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showPriceList(context, goldPrices, currencyPrices);
                  },
                  child: Text('Altın Seç'),
                ),
                ListBody(
                  children: <Widget>[
                    for (var price in currencyPrices)
                      ListTile(
                        title: Text(price.title),
                        onTap: () async {
                          Navigator.of(context).pop();
                          _handleItemSelection(price.title, onItemSelected);
                        },
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

  void _showPriceList(BuildContext context, List<WealthPrice> prices,
      List<WealthPrice> otherPrices) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Altın Seç'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListBody(
                  children: <Widget>[
                    for (var price in prices)
                      ListTile(
                        title: Text(price.title),
                        onTap: () async {
                          Navigator.of(context).pop();
                          _handleItemSelection(price.title, onItemSelected);
                        },
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

  void _handleItemSelection(String type, Function onItemSelected) async {
    SavedWealthsdao wealthsDao = SavedWealthsdao();
    SavedWealths? existingWealth = await wealthsDao.getWealthByType(type);

    if (existingWealth != null) {
      onItemSelected(existingWealth, existingWealth.amount);
    } else {
      onItemSelected(
          SavedWealths(
              id: DateTime.now().millisecondsSinceEpoch, type: type, amount: 0),
          0);
    }
  }
}
