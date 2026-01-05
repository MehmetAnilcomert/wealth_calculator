import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/inventory/model/wealth_history_model.dart';

class PriceHistoryChart extends StatelessWidget {
  final List<WealthHistory> pricesHistory;

  const PriceHistoryChart({
    Key? key,
    required this.pricesHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedHistory = List<WealthHistory>.from(pricesHistory)
      ..sort((a, b) => a.date.compareTo(b.date));

    return Container(
      padding: const EdgeInsets.only(
          top: 50.0, left: 18.0, right: 24.0, bottom: 30.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2C3E50),
            Color(0xFF3498DB),
          ],
        ),
      ),
      child: AspectRatio(
        aspectRatio: 1.8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LineChart(
            LineChartData(
              backgroundColor: const Color(0xFF1B2838),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 50000,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white.withOpacity(0.1),
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
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
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
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
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
                  color: const Color(0xFF3498DB),
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: const Color(0xFF3498DB),
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3498DB).withOpacity(0.2),
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
                        const TextStyle(color: Colors.white, fontSize: 12),
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
