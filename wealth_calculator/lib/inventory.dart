import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  List<WealthPrice> goldPrices = [];
  List<WealthPrice> currencyPrices = [];
  double totalPrice = 0;
  List<double> segments = [];
  List<Color> colors = [];
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
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Fetch saved wealths and prices concurrently
      final results = await Future.wait([
        SavedWealthsdao().getAllWealths(),
        widget.futureGoldPrices,
        widget.futureCurrencyPrices,
      ]);

      setState(() {
        savedWealths = results[0] as List<SavedWealths>;
        goldPrices = results[1] as List<WealthPrice>;
        currencyPrices = results[2] as List<WealthPrice>;
        _calculateTotalPrice(); // Calculate total price and segments based on new data
      });
    } catch (e) {
      // Handle error
      setState(() {
        savedWealths = [];
        goldPrices = [];
        currencyPrices = [];
        totalPrice = 0;
      });
    }
  }

  void _calculateTotalPrice() {
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

    // Calculate segments
    segments = calculateSegments(
      {for (var wealth in savedWealths) wealth: wealth.amount},
      goldPrices,
      currencyPrices,
      colorMap,
    );
    colors = [
      for (var wealth in savedWealths) colorMap[wealth.type] ?? Colors.grey
    ];
  }

  List<double> calculateSegments(
      Map<SavedWealths, int> selectedItems,
      List<WealthPrice> goldPrices,
      List<WealthPrice> currencyPrices,
      Map<String, Color> colorMap) {
    List<double> segments = [];
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
    }

    if (total > 0) {
      segments = segments.map((segment) => (segment / total) * 360).toList();
    }
    return segments;
  }

  void _deleteWealth(int id) async {
    await SavedWealthsdao().deleteWealth(id);
    setState(() {
      savedWealths.removeWhere((wealth) => wealth.id == id);
      _calculateTotalPrice(); // Recalculate after deletion
    });
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
      setState(() {
        int index = savedWealths.indexWhere((w) => w.id == updatedWealth.id);
        if (index != -1) {
          savedWealths[index] = updatedWealth;
        }
        _calculateTotalPrice(); // Recalculate after update
      });
    } else {
      SavedWealths newWealth = SavedWealths(
        id: DateTime.now().millisecondsSinceEpoch,
        type: wealth.type,
        amount: amount,
      );
      await wealthsDao.insertWealth(newWealth);
      setState(() {
        savedWealths.add(newWealth);
        _calculateTotalPrice(); // Recalculate after adding new wealth
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Varlık Hesaplama Makinesi',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey,
        ),
        body: CustomScrollView(
          slivers: [
            // SliverAppBar for TotalPrice
            SliverAppBar(
              expandedHeight: 200.0, // Adjust height as needed
              collapsedHeight: 250,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: TotalPrice(
                  totalPrice: totalPrice,
                  segments: segments,
                  colors: colors,
                ),
              ),
              actions: [
                // Adding FloatingActionButton to AppBar's actions
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, top: 2),
                  child: FloatingActionButton(
                    backgroundColor: Color.fromARGB(255, 59, 150, 223),
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
            ),
            // SliverList for WealthList
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (savedWealths.isEmpty) {
                    return Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 150),
                        child: Text(
                          'Varlık Bulunamadı',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    );
                  } else {
                    final wealth = savedWealths[index];
                    return ListTile(
                      title: Text('${wealth.type}'),
                      titleTextStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 21),
                      subtitle: Text('Miktar: ${wealth.amount}'),
                      subtitleTextStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      tileColor: Colors.blueGrey,
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 235, 235, 235),
                        ),
                        onPressed: () {
                          _deleteWealth(wealth.id);
                        },
                      ),
                      onTap: () {
                        ItemDialogs.showEditItemDialog(
                          context,
                          MapEntry(wealth, wealth.amount),
                          _editWealth,
                        );
                      },
                    );
                  }
                },
                childCount: savedWealths.isEmpty ? 1 : savedWealths.length,
              ),
            ),
          ],
        ));
  }
}
