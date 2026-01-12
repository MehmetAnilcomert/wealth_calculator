import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/widget/CommonWidgets/circular_painter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/theme/custom_colors.dart';

class CircularMoneyState extends StatelessWidget {
  final double totalAmount;
  final List<double> segments;
  final List<Color> colors;
  final double gapPercentage;

  const CircularMoneyState({
    super.key,
    required this.totalAmount,
    required this.segments,
    required this.colors,
    this.gapPercentage = 0.03,
  });

  String _formatAmount(double amount) {
    if (amount >= 1000000000) {
      // Milyar
      return '${(amount / 1000000000).toStringAsFixed(2)} ${LocaleKeys.milyar.tr()} TL';
    } else if (amount >= 1000000) {
      // Milyon
      return '${(amount / 1000000).toStringAsFixed(2)}${LocaleKeys.milyon.tr()} TL';
    } else if (amount >= 1000) {
      // Bin
      return '${(amount / 1000).toStringAsFixed(2)}${LocaleKeys.bin.tr()} TL';
    } else {
      return '${amount.toStringAsFixed(2)} TL';
    }
  }

  double _calculateFontSize(BuildContext context, String text) {
    const baseSize = 28.0;
    if (text.length > 12) {
      return baseSize * (12 / text.length);
    }
    return baseSize;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    final formattedAmount = _formatAmount(totalAmount);
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
            colorScheme.gradientStart.withAlpha(204),
            colorScheme.gradientEnd.withAlpha(204),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.blackOverlay20,
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${LocaleKeys.total.tr()}:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer.withAlpha(204),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedAmount,
                    style: TextStyle(
                      fontSize: _calculateFontSize(context, formattedAmount),
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: colorScheme.blackOverlay30,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (totalAmount >=
                      1000) // Sadece büyük sayılar için detaylı gösterim
                    Text(
                      detailedAmount,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onPrimaryContainer.withAlpha(153),
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
