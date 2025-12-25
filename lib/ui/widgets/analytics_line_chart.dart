import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsLineChart extends StatelessWidget {
  final Map<int, double> trendTotals;

  const AnalyticsLineChart({
    super.key,
    required this.trendTotals,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12291D),
        borderRadius: BorderRadius.circular(20),
      ),
      height: 280,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final day = value.toInt();
                  if (day <= 0) return const SizedBox.shrink();
                  return Text(
                    day.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  );
                },
              ),
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              color: Colors.greenAccent,
              barWidth: 3,
              isCurved: true,
              spots: _buildLineSpots(),
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildLineSpots() {
    final sortedKeys = trendTotals.keys.toList()..sort();

    return sortedKeys.map((day) {
      return FlSpot(day.toDouble(), trendTotals[day] ?? 0);
    }).toList();
  }
}
