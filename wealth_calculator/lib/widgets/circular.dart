import 'package:flutter/material.dart';
import 'dart:math';

class CircularMoneyState extends StatelessWidget {
  final double totalAmount;
  final List<double> segments;
  final List<Color> colors;

  const CircularMoneyState({
    Key? key,
    required this.totalAmount,
    required this.segments,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(200, 200),
            painter: CircularMoneyStatePainter(
              segments: segments,
              colors: colors,
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

class CircularMoneyStatePainter extends CustomPainter {
  final List<double> segments;
  final List<Color> colors;

  CircularMoneyStatePainter({required this.segments, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2;
    for (int i = 0; i < segments.length; i++) {
      final sweepAngle =
          2 * pi * (segments[i] / segments.reduce((a, b) => a + b));
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..color = colors[i];

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
