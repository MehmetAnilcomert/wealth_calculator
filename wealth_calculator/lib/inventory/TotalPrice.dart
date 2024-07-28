import 'package:flutter/material.dart';
import 'package:wealth_calculator/widgets/circular.dart';

class TotalPrice extends StatelessWidget {
  final double totalPrice;

  TotalPrice(this.totalPrice);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.blueGrey),
      height: 235,
      child: Center(
          child: CircularMoneyState(
        totalAmount: totalPrice.toDouble(),
        segments: [5000, 10000],
        colors: [Colors.blue, const Color.fromARGB(255, 226, 137, 5)],
      )),
    );
  }
}
