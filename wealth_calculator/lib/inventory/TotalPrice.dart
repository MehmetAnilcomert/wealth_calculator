import 'package:flutter/material.dart';
import 'package:wealth_calculator/widgets/circular.dart';

class TotalPrice extends StatelessWidget {
  final double totalPrice;

  TotalPrice(this.totalPrice);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black),
      height: 250,
      child: Center(
          child: CircularMoneyState(
        totalAmount: totalPrice.toDouble(),
        segments: [15000, 10000, 7000, 3147.25],
        colors: [Colors.orange, Colors.orange, Colors.blue, Colors.blue],
      )),
    );
  }
}
