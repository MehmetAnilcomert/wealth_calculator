import 'package:flutter/material.dart';
import 'package:wealth_calculator/services/Wealths.dart';
import 'package:wealth_calculator/services/Wealthsdao.dart';
import 'package:wealth_calculator/services/wealthPrice.dart';

class InventoryScreen extends StatefulWidget {
  final Future<List<WealthPrice>> futureGoldPrices;
  final Future<List<WealthPrice>> futureCurrencyPrices;

  InventoryScreen(this.futureGoldPrices, this.futureCurrencyPrices);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Map<SavedWealths, int> selectedItems = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Varlık Hesaplayıcı'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<SavedWealths>>(
              future: SavedWealthsdao().getAllWealths(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Varlık bulunamadı'));
                } else {
                  selectedItems = {
                    for (var wealth in snapshot.data!) wealth: wealth.amount,
                  };
                  return FutureBuilder<List<List<WealthPrice>>>(
                    future: Future.wait(
                        [widget.futureGoldPrices, widget.futureCurrencyPrices]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Hata: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Fiyat bilgisi bulunamadı'));
                      } else {
                        double totalPrice = _calculateTotalPrice(
                            snapshot.data![0], snapshot.data![1]);
                        return Column(
                          children: [
                            Expanded(
                                child: buildPriceList(
                                    selectedItems.keys.toList())),
                            Container(
                              height: 50,
                              child: Center(
                                child: Text('Toplam: ${totalPrice.toInt()}'),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSelectItemDialog(
              context, widget.futureGoldPrices, widget.futureCurrencyPrices);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  double _calculateTotalPrice(
      List<WealthPrice> goldPrices, List<WealthPrice> currencyPrices) {
    double totalPrice = 0;

    selectedItems.forEach((key, value) {
      double price = 0.0;
      for (var gold in goldPrices) {
        if (gold.title == key.type) {
          price = double.parse(gold.buyingPrice.replaceAll(',', '.').trim());
          break;
        }
      }
      if (price == 0.0) {
        for (var currency in currencyPrices) {
          if (currency.title == key.type) {
            price =
                double.parse(currency.buyingPrice.replaceAll(',', '.').trim());
            break;
          }
        }
      }
      totalPrice += price * value;
    });

    return totalPrice;
  }

  Widget buildPriceList(List<SavedWealths> prices) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: selectedItems.entries.map((entry) {
              return ListTile(
                title: Text(entry.key.type),
                subtitle: Text('Miktar: ${entry.value}'),
                tileColor: const Color.fromARGB(255, 35, 143, 41),
                onTap: () {
                  _showEditDialog(context, entry);
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.black),
                  iconSize: 35,
                  focusColor: Colors.grey,
                  onPressed: () async {
                    await SavedWealthsdao().deleteWealth(entry.key.id);
                    setState(() {
                      selectedItems.remove(entry.key);
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showSelectItemDialog(
    BuildContext context,
    Future<List<WealthPrice>> futureGoldPrices,
    Future<List<WealthPrice>> futureCurrencyPrices,
  ) {
    futureGoldPrices.then((List<WealthPrice> goldPrices) {
      showDialog(
          context: context,
          builder: (context) {
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
                        for (var price in goldPrices)
                          ListTile(
                            title: Text(price.title),
                            onTap: () {
                              Navigator.of(context).pop();
                              _showEditDialog(
                                  context,
                                  MapEntry(
                                      SavedWealths(
                                          id: DateTime.now()
                                              .millisecondsSinceEpoch,
                                          type: price.title,
                                          amount: 0),
                                      0));
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
                              context,
                              widget.futureGoldPrices,
                              widget.futureCurrencyPrices);
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
                            onTap: () {
                              Navigator.of(context).pop();
                              _showEditDialog(
                                  context,
                                  MapEntry(
                                      SavedWealths(
                                          id: DateTime.now()
                                              .millisecondsSinceEpoch,
                                          type: price.title,
                                          amount: 0),
                                      0));
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

  void _showEditDialog(
      BuildContext context, MapEntry<SavedWealths, int> entry) {
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
              onPressed: () async {
                int amount = int.tryParse(controller.text) ?? 0;
                setState(() {
                  selectedItems[entry.key] = amount;
                });

                // Yeni varlığı veritabanına ekle
                SavedWealths newWealth = SavedWealths(
                  id: DateTime.now()
                      .millisecondsSinceEpoch, // ID olarak benzersiz bir değer kullanın
                  type: entry.key.type,
                  amount: amount,
                );

                await SavedWealthsdao().insertWealth(newWealth);

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
