import 'package:flutter/material.dart';
import 'package:wealth_calculator/widgets/circular.dart';

class TotalPrice extends StatelessWidget {
  final double totalPrice;
  final List<double> segments;
  final List<Color> colors;

  TotalPrice({
    required this.totalPrice,
    required this.segments,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.blueGrey),
      height: 235,
      child: Center(
        child: CircularMoneyState(
          totalAmount: totalPrice,
          segments: segments,
          colors: colors,
        ),
      ),
    );
  }
}
