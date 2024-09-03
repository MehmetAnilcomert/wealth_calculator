import 'package:flutter/material.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';

class WealthPriceCard extends StatelessWidget {
  final WealthPrice equity;

  WealthPriceCard({required this.equity});

  @override
  Widget build(BuildContext context) {
    String tarih = equity.type.index == 2 ? 'Tarih' : 'Saat';
    Color changeColor = equity.change.startsWith('-')
        ? Colors.red
        : const Color.fromARGB(255, 67, 155, 70);
    Icon icon = equity.change.startsWith('-')
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

    double _getHeightValue() {
      double heightValue;
      if (equity.type.index == 2) {
        heightValue = MediaQuery.of(context).size.height * 0.41;
        return heightValue;
      } else if (equity.type.index == 0) {
        heightValue = MediaQuery.of(context).size.height * 0.3;
        return heightValue;
      } else {
        heightValue = MediaQuery.of(context).size.height * 0.245;
        return heightValue;
      }
    }

    return Container(
      margin: EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * 0.473,
      height: _getHeightValue(),
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
          if (equity.currentPrice != null)
            Text(
              'Anlık fiyat: ${equity.currentPrice}',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
            ),
          if (equity.currentPrice != null) SizedBox(height: 8.0),
          Text(
            'En yüksek fiyat: ${equity.buyingPrice}',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'En düşük fiyat: ${equity.sellingPrice}',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.0),
          if (equity.volume != null)
            Text(
              'Volume: ${equity.volume}',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
            ),
          if (equity.volume != null) SizedBox(height: 4.0),
          if (equity.changeAmount != null)
            Text(
              'Değişim (miktar): ${equity.changeAmount}',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          SizedBox(height: 4.0),
          Row(
            children: [
              Text(
                'Değişim(%): ${equity.change}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: changeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon,
            ],
          ),
          SizedBox(height: 4.0),
          Text(
            '${tarih}: ${equity.time}',
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
          WealthPriceCard(equity: equities[i]),
          if (i + 1 < equities.length) WealthPriceCard(equity: equities[i + 1]),
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
