import 'package:flutter/material.dart';
import 'dart:math';

import 'package:wealth_calculator/widgets/CommonWidgets/circular_painter.dart';

class CircularMoneyState extends StatelessWidget {
  final double totalAmount;
  final List<double> segments;
  final List<Color> colors;
  final double gapPercentage;

  const CircularMoneyState({
    Key? key,
    required this.totalAmount,
    required this.segments,
    required this.colors,
    this.gapPercentage = 0.03,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.height * 0.27,
      height: MediaQuery.of(context).size.height * 0.3,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.height * 0.3,
                MediaQuery.of(context).size.height * 0.3),
            painter: CircularMoneyStatePainter(
              segments: segments,
              colors: colors,
              gapPercentage: gapPercentage,
            ),
          ),
          Center(
            child: Text(
              '${totalAmount.toStringAsFixed(2)} TL',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
