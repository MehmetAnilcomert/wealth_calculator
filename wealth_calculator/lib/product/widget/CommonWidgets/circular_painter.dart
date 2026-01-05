import 'dart:math';
import 'package:flutter/material.dart';

class CircularMoneyStatePainter extends CustomPainter {
  final List<double> segments;
  final List<Color> colors;
  final double gapPercentage; // Gap percentage

  CircularMoneyStatePainter({
    required this.segments,
    required this.colors,
    this.gapPercentage = 0.02, // Default gap percentage
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2;
    final double total =
        segments.fold(0.0, (a, b) => a + b); // Ensure total is double

    for (int i = 0; i < segments.length; i++) {
      final segmentValue = segments[i];
      final segmentPercentage = segmentValue / total;

      // Adjust the start and end angles to include gaps
      final gapAngle = 2 * pi * gapPercentage;
      final sweepAngle = 2 * pi * (segmentPercentage - gapPercentage);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..color = colors[i]
        ..strokeCap = StrokeCap.round; // Rounded ends

      // Draw the segment
      canvas.drawArc(
        rect,
        startAngle + gapAngle / 2, // Start with half of the gap
        sweepAngle,
        false,
        paint,
      );

      // Update the start angle for the next segment
      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
