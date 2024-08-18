import 'package:flutter/material.dart';
import 'package:wealth_calculator/widgets/CommonWidgets/circular.dart';

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
      width: MediaQuery.of(context).size.height * 0.25,
      height: MediaQuery.of(context).size.height * 0.25, //235,
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
