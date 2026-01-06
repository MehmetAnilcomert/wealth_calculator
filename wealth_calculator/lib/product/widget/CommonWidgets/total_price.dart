import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/widget/CommonWidgets/circular.dart';

class TotalPrice extends StatelessWidget {
  final double totalPrice;
  final List<double> segments;
  final List<Color> colors;

  const TotalPrice({
    super.key,
    required this.totalPrice,
    required this.segments,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E50),
            Color(0xFF3498DB),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CircularMoneyState(
                  totalAmount: totalPrice,
                  segments: segments,
                  colors: colors,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
