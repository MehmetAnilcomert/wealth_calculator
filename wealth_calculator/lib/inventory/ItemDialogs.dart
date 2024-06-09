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
    return FutureBuilder<List<WealthPrice>>(
      future: futureGoldPrices,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Altın fiyatları bulunamadı'));
        } else {
          return AlertDialog(
            title: Text('Altın Seç'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  PopupMenuButton<String>(
                    icon: ElevatedButton(
                      onPressed: null,
                      child: Text('Diğer Seçenekler'),
                    ),
                    onSelected: (String result) {
                      Navigator.of(context).pop();
                      if (result == 'Döviz Seç') {
                        _showCurrencySelectItemDialog(
                            context, futureCurrencyPrices);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Döviz Seç',
                        child: Text('Döviz Seç'),
                      ),
                    ],
                  ),
                  ListBody(
                    children: <Widget>[
                      for (var price in snapshot.data!)
                        ListTile(
                          title: Text(price.title),
                          onTap: () async {
                            Navigator.of(context).pop();

                            SavedWealthsdao wealthsDao = SavedWealthsdao();
                            SavedWealths? existingWealth =
                                await wealthsDao.getWealthByType(price.title);

                            if (existingWealth != null) {
                              // Mevcut varlık güncelleme
                              onItemSelected(
                                  existingWealth, existingWealth.amount);
                            } else {
                              // Yeni varlık ekleme
                              onItemSelected(
                                  SavedWealths(
                                      id: DateTime.now().millisecondsSinceEpoch,
                                      type: price.title,
                                      amount: 0),
                                  0);
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
      },
    );
  }

  void _showCurrencySelectItemDialog(
      BuildContext context, Future<List<WealthPrice>> futureCurrencyPrices) {
    futureCurrencyPrices.then((List<WealthPrice> currencyPrices) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Döviz Seç'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    PopupMenuButton<String>(
                      icon: ElevatedButton(
                        onPressed: null,
                        child: Text('Diğer Seçenekler'),
                      ),
                      onSelected: (String result) {
                        Navigator.of(context).pop();
                        if (result == 'Altın Seç') {
                          _showSelectItemDialog(
                              context, futureGoldPrices, futureCurrencyPrices);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Altın Seç',
                          child: Text('Altın Seç'),
                        ),
                      ],
                    ),
                    ListBody(
                      children: <Widget>[
                        for (var price in currencyPrices)
                          ListTile(
                            title: Text(price.title),
                            onTap: () async {
                              Navigator.of(context).pop();

                              SavedWealthsdao wealthsDao = SavedWealthsdao();
                              SavedWealths? existingWealth =
                                  await wealthsDao.getWealthByType(price.title);

                              if (existingWealth != null) {
                                // Mevcut varlık güncelleme
                                onItemSelected(
                                    existingWealth, existingWealth.amount);
                              } else {
                                // Yeni varlık ekleme
                                onItemSelected(
                                    SavedWealths(
                                        id: DateTime.now()
                                            .millisecondsSinceEpoch,
                                        type: price.title,
                                        amount: 0),
                                    0);
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
    });
  }

  void _showSelectItemDialog(
    BuildContext context,
    Future<List<WealthPrice>> futureGoldPrices,
    Future<List<WealthPrice>> futureCurrencyPrices,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return SelectItemDialog(
          futureGoldPrices: futureGoldPrices,
          futureCurrencyPrices: futureCurrencyPrices,
          onItemSelected: onItemSelected,
        );
      },
    );
  }
}

class EditItemDialog extends StatelessWidget {
  final MapEntry<SavedWealths, int> entry;
  final Function onSave;

  EditItemDialog({required this.entry, required this.onSave});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(
      text: entry.value.toString(),
    );

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
  }
}
