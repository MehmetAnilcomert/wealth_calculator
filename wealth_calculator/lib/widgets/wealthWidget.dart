import 'package:flutter/material.dart';
import 'package:wealth_calculator/services/wealthPrice.dart';

Widget buildPricesTab(List<WealthPrice> goldPrices) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DataTable(
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
          rows: goldPrices.map((goldPrice) {
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
      ],
    ),
  );
}
