import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wealth_calculator/l10n/app_localizations.dart';
import 'package:wealth_calculator/product/widget/CommonWidgets/circular_painter.dart';
import 'package:intl/intl.dart';

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

  String _formatAmount(double amount, AppLocalizations l10n) {
    if (amount >= 1000000000) {
      // Milyar
      return '${(amount / 1000000000).toStringAsFixed(2)} ${l10n.milyar} TL';
    } else if (amount >= 1000000) {
      // Milyon
      return '${(amount / 1000000).toStringAsFixed(2)}${l10n.milyon} TL';
    } else if (amount >= 1000) {
      // Bin
      return '${(amount / 1000).toStringAsFixed(2)}${l10n.bin} TL';
    } else {
      return '${amount.toStringAsFixed(2)} TL';
    }
  }

  double _calculateFontSize(BuildContext context, String text) {
    final baseSize = 28.0;
    if (text.length > 12) {
      return baseSize * (12 / text.length);
    }
    return baseSize;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formattedAmount = _formatAmount(totalAmount, l10n);
    final numberFormat = NumberFormat('#,##0.00', 'tr_TR');
    final detailedAmount = numberFormat.format(totalAmount);

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E50).withOpacity(0.8),
            Color(0xFF3498DB).withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size.fromWidth(MediaQuery.of(context).size.width * 0.8),
            painter: CircularMoneyStatePainter(
              segments: segments,
              colors: colors,
              gapPercentage: gapPercentage,
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${l10n.total}:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    formattedAmount,
                    style: TextStyle(
                      fontSize: _calculateFontSize(context, formattedAmount),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  if (totalAmount >=
                      1000) // Sadece büyük sayılar için detaylı gösterim
                    Text(
                      detailedAmount,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
