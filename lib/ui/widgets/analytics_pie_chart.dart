import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const AnalyticsPieChart({
    super.key,
    required this.categoryTotals,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const Center(
        child: Text(
          'No data for this period',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12291D),
        borderRadius: BorderRadius.circular(20),
      ),
      height: 260,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 50,
          sections: _buildPieSections(categoryTotals),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, double> totals) {
    final colors = [
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.lightBlueAccent,
      Colors.pinkAccent,
      Colors.yellowAccent,
    ];

    int index = 0;

    return totals.entries.map((entry) {
      final section = PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        radius: 60,
        title: entry.key,
        titleStyle: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );

      index++;
      return section;
    }).toList();
  }
}
