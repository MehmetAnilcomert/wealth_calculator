import 'package:flutter/material.dart';
import 'package:wealth_calculator/gold_price.dart';
import 'package:wealth_calculator/inventory.dart';

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
  late Future<List<GoldPrice>> futureGoldPrices;

  @override
  void initState() {
    super.initState();
    futureGoldPrices = fetchGoldPrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gold Prices'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InventoryScreen(futureGoldPrices)),
              );
            },
            icon: Icon(Icons.inventory),
          ),
        ],
      ),
      body: FutureBuilder<List<GoldPrice>>(
        future: futureGoldPrices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Color.fromARGB(255, 97, 186, 250)!),
                columnSpacing: 15,
                dataRowColor:
                    MaterialStateColor.resolveWith((states) => Colors.yellow!),
                dividerThickness: 2,
                columns: const <DataColumn>[
                  DataColumn(label: Text('Türü')),
                  DataColumn(label: Text('Alış \nFiyatı')),
                  DataColumn(label: Text('Satış \nFiyatı')),
                  DataColumn(label: Text('Değişim')),
                ],
                rows: snapshot.data!.map((goldPrice) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(goldPrice.title)),
                      DataCell(Text(goldPrice.buyingPrice)),
                      DataCell(Text(goldPrice.sellingPrice)),
                      DataCell(Text(goldPrice.change)),
                    ],
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
