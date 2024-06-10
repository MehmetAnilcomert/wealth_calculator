import 'package:flutter/material.dart';

class TotalPrice extends StatelessWidget {
  final double totalPrice;

  TotalPrice(this.totalPrice);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.blueGrey),
      height: 50,
      child: Center(
        child: Text(
          'Toplam: ${totalPrice.toInt()} TL',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
