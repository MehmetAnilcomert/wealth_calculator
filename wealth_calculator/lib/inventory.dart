import 'package:flutter/material.dart';
import 'package:wealth_calculator/services/wealthPrice.dart';

class InventoryScreen extends StatefulWidget {
  final Future<List<WealthPrice>> futureGoldPrices;

  InventoryScreen(this.futureGoldPrices);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Map<WealthPrice, int> selectedItems = {};

  @override
  Widget build(BuildContext context) {
    double totalPrice = _calculateTotalPrice(); // Toplam fiyatı hesapla

    return Scaffold(
      appBar: AppBar(
        title: Text('Varlıklar'),
      ),
      body: FutureBuilder<List<WealthPrice>>(
        future: widget.futureGoldPrices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Veri bulunamadı'));
          } else {
            return ListView(
              children: selectedItems.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key.title),
                  subtitle: Text('Miktar: ${entry.value}'),
                  onTap: () {
                    _showEditDialog(context, entry);
                  },
                );
              }).toList(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSelectItemDialog(context, widget.futureGoldPrices);
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

  void _showSelectItemDialog(
      BuildContext context, Future<List<WealthPrice>> future) {
    future.then((List<WealthPrice> goldPrices) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Seçiniz'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  for (var goldPrice in goldPrices)
                    ListTile(
                      title: Text(goldPrice.title),
                      onTap: () {
                        Navigator.of(context).pop();
                        _showEditDialog(context, MapEntry(goldPrice, 0));
                      },
                    ),
                ],
              ),
            ),
          );
        },
      );
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
