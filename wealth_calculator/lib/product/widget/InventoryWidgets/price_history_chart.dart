import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/inventory/model/wealth_history_model.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/theme/custom_colors.dart';

class PriceHistoryChart extends StatelessWidget {
  final List<WealthHistory> pricesHistory;

  const PriceHistoryChart({
    super.key,
    required this.pricesHistory,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    final sortedHistory = List<WealthHistory>.from(pricesHistory)
      ..sort((a, b) => a.date.compareTo(b.date));

    return Container(
      padding: const EdgeInsets.only(
          top: 50.0, left: 18.0, right: 24.0, bottom: 30.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.gradientStart,
            colorScheme.gradientEnd,
          ],
        ),
      ),
      child: AspectRatio(
        aspectRatio: 1.8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LineChart(
            LineChartData(
              backgroundColor: colorScheme.primaryContainer.withAlpha(204),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 50000,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: colorScheme.whiteOverlay10,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      String text = '';
                      if (value >= 1000) {
                        text = '${(value / 1000).toStringAsFixed(0)}K';
                      } else {
                        text = value.toStringAsFixed(0);
                      }
                      return Text(
                        text,
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer.withAlpha(179),
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < sortedHistory.length) {
                        final date = sortedHistory[index].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "${date.day}/${date.month}",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  colorScheme.onPrimaryContainer.withAlpha(179),
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    sortedHistory.length,
                    (index) => FlSpot(
                      index.toDouble(),
                      sortedHistory[index].totalPrice,
                    ),
                  ),
                  isCurved: true,
                  color: colorScheme.primary,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: colorScheme.onPrimaryContainer,
                        strokeWidth: 2,
                        strokeColor: colorScheme.primary,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withAlpha(51),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      final date = sortedHistory[touchedSpot.x.toInt()].date;
                      return LineTooltipItem(
                        '${touchedSpot.y.toStringAsFixed(2)} TL\n${date.day}/${date.month}/${date.year}',
                        TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 12),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
                getTouchLineStart: (data, index) => 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
