import 'package:flutter/material.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';

class WealthPriceCard extends StatelessWidget {
  final WealthPrice wealthPrice;

  WealthPriceCard({required this.wealthPrice});

  @override
  Widget build(BuildContext context) {
    Color changeColor =
        wealthPrice.change.startsWith('-') ? Colors.red : Colors.green;
    return Container(
      margin: EdgeInsets.all(5),
      width: 180,
      height: 180,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 218, 211, 211),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            wealthPrice.title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Alış Fiyatı: ${wealthPrice.buyingPrice}',
            style: TextStyle(
              fontSize: 14.0,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            'Satış Fiyatı: ${wealthPrice.sellingPrice}',
            style: TextStyle(
              fontSize: 14.0,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            'Change: ${wealthPrice.change}',
            style: TextStyle(
              fontSize: 14.0,
              color: changeColor,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            'Saati: ${wealthPrice.time}',
            style: TextStyle(
              fontSize: 14.0,
              color: const Color.fromARGB(255, 99, 98, 98),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildPricesTab(List<WealthPrice> prices) {
  List<Row> rows = [];
  for (var i = 0; i < prices.length; i += 2) {
    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          WealthPriceCard(wealthPrice: prices[i]),
          if (i + 1 < prices.length)
            WealthPriceCard(wealthPrice: prices[i + 1]),
        ],
      ),
    );
  }

  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 20),
      child: Column(
        children: rows,
      ),
    ),
  );
}
