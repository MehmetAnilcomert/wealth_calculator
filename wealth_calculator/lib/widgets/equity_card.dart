import 'package:flutter/material.dart';
import 'package:wealth_calculator/modals/EquityModal.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';

class EquityCard extends StatelessWidget {
  final Equity equity;

  EquityCard({required this.equity});

  @override
  Widget build(BuildContext context) {
    Color changeColor = equity.changeAmount.startsWith('-')
        ? Colors.red
        : const Color.fromARGB(255, 67, 155, 70);
    Icon icon = equity.changeAmount.startsWith('-')
        ? Icon(
            Icons.trending_down,
            color: Colors.red,
            size: 26.0,
          )
        : Icon(
            Icons.trending_up,
            color: Colors.green,
            size: 26.0,
          );

    return Container(
      margin: EdgeInsets.all(5),
      width: 180,
      height: 220, // Adjust height if needed to fit more information
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 139, 202, 233),
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
            equity.title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Current Price: ${equity.currentPrice}',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            'Volume: ${equity.volume}',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.0),
          Row(
            children: [
              Text(
                'Change: ${equity.changeAmount}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: changeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              icon,
            ],
          ),
          SizedBox(height: 4.0),
          Text(
            'Time: ${equity.time}',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildEquityPricesTab(List<dynamic> equities) {
  List<Row> rows = [];
  for (var i = 0; i < equities.length; i += 2) {
    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          EquityCard(equity: equities[i]),
          if (i + 1 < equities.length) EquityCard(equity: equities[i + 1]),
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
