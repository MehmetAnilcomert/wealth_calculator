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
  List<SavedWealths> savedWealths = [];
  late Map<SavedWealths, int> selectedItems = {};
  double totalPrice = 0; // Global totalPrice değişkeni

  final Map<String, Color> colorMap = {
    'Altın (TL/GR)': Colors.yellow,
    'ABD Doları': Colors.green,
    'Euro': Colors.blue,
    'İngiliz Sterlini': Colors.purple,
    'TL': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    _loadWealths();
    _calculateTotalPrice();
  }

  Future<void> _loadWealths() async {
    try {
      savedWealths = await SavedWealthsdao().getAllWealths();
      if (savedWealths.isEmpty) {
        setState(() {
          savedWealths = [];
          totalPrice = 0; // Varlık bulunamadığında toplam fiyatı sıfırlıyoruz
        });
      } else {
        setState(() {});
        await _calculateTotalPrice(); // Veriler yüklendiğinde toplam fiyatı hesapla
      }
    } catch (e) {
      setState(() {
        savedWealths = [];
        totalPrice = 0; // Hata durumunda toplam fiyatı sıfırlıyoruz
      });
    }
  }

  void _refreshWealths() {
    setState(() {
      _calculateTotalPrice();
    });
  }

  void _deleteWealth(int id) async {
    await SavedWealthsdao().deleteWealth(id);
    savedWealths.removeWhere((wealth) => wealth.id == id);
    _refreshWealths();
  }

  void _editWealth(SavedWealths wealth, int amount) async {
    SavedWealthsdao wealthsDao = SavedWealthsdao();
    SavedWealths? existingWealth =
        await wealthsDao.getWealthByType(wealth.type);

    if (existingWealth != null) {
      SavedWealths updatedWealth = SavedWealths(
        id: existingWealth.id,
        type: existingWealth.type,
        amount: amount,
      );
      await wealthsDao.updateWealth(updatedWealth);
      int index = savedWealths.indexWhere((w) => w.id == updatedWealth.id);
      savedWealths[index] = updatedWealth;
    } else {
      SavedWealths newWealth = SavedWealths(
        id: DateTime.now().millisecondsSinceEpoch,
        type: wealth.type,
        amount: amount,
      );
      await wealthsDao.insertWealth(newWealth);
      savedWealths.add(newWealth);
    }

    _refreshWealths();
  }

  Future<void> _calculateTotalPrice() async {
    List<List<WealthPrice>> prices = await Future.wait(
        [widget.futureGoldPrices, widget.futureCurrencyPrices]);
    List<WealthPrice> goldPrices = prices[0];
    List<WealthPrice> currencyPrices = prices[1];

    double total = 0;

    for (var wealth in savedWealths) {
      double price = 0.0;
      for (var gold in goldPrices) {
        if (gold.title == wealth.type) {
          price = double.parse(gold.buyingPrice.replaceAll(',', '.').trim());
          break;
        }
      }
      if (price == 0.0) {
        for (var currency in currencyPrices) {
          if (currency.title == wealth.type) {
            price =
                double.parse(currency.buyingPrice.replaceAll(',', '.').trim());
            break;
          }
        }
      }
      total += price * wealth.amount;
    }

    setState(() {
      totalPrice = total;
    });
  }

  List<double> calculateSegments(
      Map<SavedWealths, int> selectedItems,
      List<WealthPrice> goldPrices,
      List<WealthPrice> currencyPrices,
      Map<String, Color> colorMap) {
    List<double> segments = [];
    List<Color> colors = [];
    double total = 0;

    for (var entry in selectedItems.entries) {
      double price = 0.0;
      for (var gold in goldPrices) {
        if (gold.title == entry.key.type) {
          price = double.parse(gold.buyingPrice.replaceAll(',', '.').trim());
          break;
        }
      }
      if (price == 0.0) {
        for (var currency in currencyPrices) {
          if (currency.title == entry.key.type) {
            price =
                double.parse(currency.buyingPrice.replaceAll(',', '.').trim());
            break;
          }
        }
      }
      double value = price * entry.value;
      total += value;
      segments.add(value);
      colors.add(colorMap[entry.key.type] ?? Colors.grey);
    }

    // Normalize the segments
    if (total > 0) {
      segments = segments.map((segment) => (segment / total) * 360).toList();
    }

    return segments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Varlık Hesaplayıcı',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey,
        ),
        body: Column(
          children: [
            Container(
                child: Stack(
              children: [
                Positioned(
                  child: FutureBuilder<List<List<WealthPrice>>>(
                    future: Future.wait(
                      [widget.futureGoldPrices, widget.futureCurrencyPrices],
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Hata: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        List<WealthPrice> goldPrices = snapshot.data![0];
                        List<WealthPrice> currencyPrices = snapshot.data![1];
                        List<double> segments = calculateSegments(
                          {
                            for (var wealth in savedWealths)
                              wealth: wealth.amount
                          },
                          goldPrices,
                          currencyPrices,
                          colorMap,
                        );
                        List<Color> colors = [
                          for (var wealth in savedWealths)
                            colorMap[wealth.type] ?? Colors.grey
                        ];

                        return TotalPrice(
                          totalPrice: totalPrice,
                          segments: segments,
                          colors: colors,
                        );
                      } else {
                        return Text('Veri bulunamadı');
                      }
                    },
                  ),
                ),
                Positioned(
                  right: 14,
                  top: 0, // FloatingActionButton'un konumu
                  child: FloatingActionButton(
                    backgroundColor: const Color.fromARGB(255, 56, 160, 246),
                    onPressed: () {
                      ItemDialogs.showSelectItemDialog(
                        context,
                        widget.futureGoldPrices,
                        widget.futureCurrencyPrices,
                        (wealth, amount) {
                          ItemDialogs.showEditItemDialog(
                            context,
                            MapEntry(wealth, amount),
                            _editWealth,
                          );
                        },
                        hiddenItems: [
                          'Altın (ONS/\$)',
                          'Altın (\$/kg)',
                          'Altın (Euro/kg)',
                          'Külçe Altın (\$)'
                        ],
                      );
                    },
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )),
            Expanded(
              child: savedWealths.isEmpty
                  ? Center(
                      child: Text(
                      'Varlık Bulunamadı',
                      style: TextStyle(fontSize: 25),
                    ))
                  : WealthList(
                      selectedItems: {
                        for (var wealth in savedWealths) wealth: wealth.amount,
                      },
                      onDelete: _deleteWealth,
                      onEdit: (entry) {
                        ItemDialogs.showEditItemDialog(
                          context,
                          entry,
                          _editWealth,
                        );
                      },
                    ),
            ),
          ],
        ));
  }
}
