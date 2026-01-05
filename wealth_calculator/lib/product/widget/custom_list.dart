import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/widget/wealth_card.dart';

class CustomPricesWidget extends StatelessWidget {
  final List<dynamic> customPrices;
  final Function() onAddPressed;
  final String query;
  final Function(WealthPrice) onDeletePrice;
  const CustomPricesWidget(
      {Key? key,
      required this.customPrices,
      required this.onAddPressed,
      required this.query,
      required this.onDeletePrice})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(height: 5),
            Expanded(
              child: customPrices.isEmpty
                  ? Center(child: Text('Henüz bir seçim yapılmadı.'))
                  : buildCustomPrices(customPrices, query),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: IconButton(
            onPressed: onAddPressed,
            icon: Icon(Icons.add, color: Colors.white),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
              elevation: MaterialStateProperty.all(4),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              padding: MaterialStateProperty.all(EdgeInsets.all(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCustomPrices(List<dynamic> customPrices, String query) {
    // Filtreleme işlemi
    List filteredPrices = customPrices.where((price) {
      return price.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return buildEquityPricesTab(filteredPrices, onDeletePrice);
  }
}
