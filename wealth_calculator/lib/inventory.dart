import 'package:flutter/material.dart';
import 'package:wealth_calculator/services/wealthPrice.dart';

class InventoryScreen extends StatefulWidget {
  final Future<List<WealthPrice>> futureGoldPrices;
  final Future<List<WealthPrice>> futureCurrencyPrices;

  InventoryScreen(this.futureGoldPrices, this.futureCurrencyPrices);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Map<WealthPrice, int> selectedItems = {};

  @override
  Widget build(BuildContext context) {
    double totalPrice = _calculateTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text('Varlıklar'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<WealthPrice>>(
              future: widget.futureGoldPrices,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Fiyatı bulunamadı'));
                } else {
                  return buildPriceList(snapshot.data!, 'Varlık Fiyatları');
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
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50,
          child: Center(
            child: Text('Toplam: ${totalPrice.toInt()}'),
          ),
        ),
      ),
    );
  }

  Widget buildPriceList(List<WealthPrice> prices, String title) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: ListView(
            children: selectedItems.entries.map((entry) {
              return ListTile(
                title: Text(entry.key.title),
                subtitle: Text('Miktar: ${entry.value}'),
                onTap: () {
                  _showEditDialog(context, entry);
                },
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
                              _showEditDialog(context, MapEntry(price, 0));
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
                              _showEditDialog(context, MapEntry(price, 0));
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

  void _showEditDialog(BuildContext context, MapEntry<WealthPrice, int> entry) {
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
                setState(() {
                  selectedItems[entry.key] = int.tryParse(controller.text) ?? 0;
                });
                Navigator.of(context).pop();
              },
              child: Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  double _calculateTotalPrice() {
    double totalPrice = 0;

    selectedItems.forEach((key, value) {
      double price = double.parse(key.buyingPrice.replaceAll(',', '.').trim());
      totalPrice += price * value;
    });

    return totalPrice;
  }
}
