import 'package:flutter/material.dart';
import 'package:wealth_calculator/services/wealthPrice.dart';
import 'package:wealth_calculator/inventory.dart';
import 'package:wealth_calculator/widgets/wealthWidget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emtia Fiyatları',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GoldPricesScreen(),
    );
  }
}

class GoldPricesScreen extends StatefulWidget {
  @override
  _GoldPricesScreenState createState() => _GoldPricesScreenState();
}

class _GoldPricesScreenState extends State<GoldPricesScreen> {
  late Future<List<WealthPrice>> futureGoldPrices;
  late Future<List<WealthPrice>> futureCurrencyPrices;

  @override
  void initState() {
    super.initState();
    futureGoldPrices = fetchGoldPrices();
    futureCurrencyPrices = fetchCurrencyPrices();
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Fiyatlar'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InventoryScreen(
                          futureGoldPrices, futureCurrencyPrices)),
                );
              },
              icon: Icon(Icons.inventory),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            FutureBuilder<List<WealthPrice>>(
              future: futureGoldPrices,
              builder: (context, goldPriceSnapshot) {
                if (goldPriceSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (goldPriceSnapshot.hasError) {
                  return Center(
                      child: Text('Error: ${goldPriceSnapshot.error}'));
                } else if (!goldPriceSnapshot.hasData ||
                    goldPriceSnapshot.data!.isEmpty) {
                  return Center(child: Text('No gold price data found'));
                } else {
                  return buildPricesTab(goldPriceSnapshot.data!);
                }
              },
            ),
            FutureBuilder<List<WealthPrice>>(
              future: futureCurrencyPrices,
              builder: (context, goldPriceSnapshot) {
                if (goldPriceSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (goldPriceSnapshot.hasError) {
                  return Center(
                      child: Text('Error: ${goldPriceSnapshot.error}'));
                } else if (!goldPriceSnapshot.hasData ||
                    goldPriceSnapshot.data!.isEmpty) {
                  return Center(child: Text('No gold price data found'));
                } else {
                  return buildPricesTab(goldPriceSnapshot.data!);
                }
              },
            ),
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.agriculture), text: 'Altın'),
            Tab(icon: Icon(Icons.attach_money), text: 'Döviz'),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
        ),
      ),
    );
  }
}
