import 'package:flutter/material.dart';
import 'package:wealth_calculator/inventory.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/services/DataScraping.dart';
import 'package:wealth_calculator/widgets/wealthCard.dart';

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
            FutureBuilder(
              future: Future.wait([futureGoldPrices, futureCurrencyPrices]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.error),
                    tooltip: 'Hata: ${snapshot.error}',
                  );
                } else {
                  return IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InventoryScreen(
                            futureGoldPrices,
                            futureCurrencyPrices,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.inventory),
                  );
                }
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            FutureBuilder<List<WealthPrice>>(
              future: futureGoldPrices,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No gold price data found'));
                } else {
                  return buildPricesTab(snapshot.data!);
                }
              },
            ),
            FutureBuilder<List<WealthPrice>>(
              future: futureCurrencyPrices,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No currency price data found'));
                } else {
                  return buildPricesTab(snapshot.data!);
                }
              },
            ),
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.gpp_good), text: 'Altın'),
            Tab(icon: Icon(Icons.attach_money), text: 'Döviz'),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
        ),
      ),
    );
  }
}
