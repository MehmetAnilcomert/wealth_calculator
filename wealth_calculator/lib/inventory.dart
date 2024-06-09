import 'package:flutter/material.dart';
import 'package:wealth_calculator/inventory/ItemDialogs.dart';
import 'package:wealth_calculator/inventory/TotalPrice.dart';
import 'package:wealth_calculator/inventory/WealthList.dart';
import 'package:wealth_calculator/modals/Wealths.dart';
import 'package:wealth_calculator/services/Wealthsdao.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';

class InventoryScreen extends StatefulWidget {
  final Future<List<WealthPrice>> futureGoldPrices;
  final Future<List<WealthPrice>> futureCurrencyPrices;

  InventoryScreen(this.futureGoldPrices, this.futureCurrencyPrices);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<SavedWealths>> futureSavedWealths;
  late Map<SavedWealths, int> selectedItems = {};

  @override
  void initState() {
    super.initState();
    futureSavedWealths = SavedWealthsdao().getAllWealths();
  }

  void _refreshWealths() {
    setState(() {
      futureSavedWealths = SavedWealthsdao().getAllWealths();
    });
  }

  void _deleteWealth(int id) async {
    await SavedWealthsdao().deleteWealth(id);
    _refreshWealths();
  }

  void _editWealth(SavedWealths wealth, int amount) async {
    SavedWealthsdao wealthsDao = SavedWealthsdao();
    SavedWealths? existingWealth =
        await wealthsDao.getWealthByType(wealth.type);

    if (existingWealth != null) {
      // Update existing wealth
      SavedWealths updatedWealth = SavedWealths(
        id: existingWealth.id,
        type: existingWealth.type,
        amount: amount,
      );
      await wealthsDao.updateWealth(updatedWealth);
    } else {
      // Insert new wealth
      SavedWealths newWealth = SavedWealths(
        id: DateTime.now().millisecondsSinceEpoch,
        type: wealth.type,
        amount: amount,
      );
      await wealthsDao.insertWealth(newWealth);
    }

    _refreshWealths();
  }

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
              future: futureSavedWealths,
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
                              child: WealthList(
                                selectedItems: selectedItems,
                                onDelete: _deleteWealth,
                                onEdit: (entry) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => EditItemDialog(
                                      entry: entry,
                                      onSave: _editWealth,
                                    ),
                                  );
                                },
                              ),
                            ),
                            TotalPrice(totalPrice),
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
          showDialog(
            context: context,
            builder: (context) => SelectItemDialog(
              futureGoldPrices: widget.futureGoldPrices,
              futureCurrencyPrices: widget.futureCurrencyPrices,
              onItemSelected: (wealth, amount) {
                showDialog(
                  context: context,
                  builder: (context) => EditItemDialog(
                    entry: MapEntry(wealth, amount),
                    onSave: _editWealth,
                  ),
                );
              },
            ),
          );
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
}
