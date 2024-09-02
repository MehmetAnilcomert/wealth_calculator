import 'package:flutter/material.dart';

class CustomPricesWidget extends StatelessWidget {
  final List<dynamic> customPrices;
  final Function() onAddPressed;
  final Widget Function() buildCustomPrices;

  const CustomPricesWidget({
    Key? key,
    required this.customPrices,
    required this.onAddPressed,
    required this.buildCustomPrices,
  }) : super(key: key);

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
                  : buildCustomPrices(),
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
}
