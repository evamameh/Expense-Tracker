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

    final total = categoryTotals.values.fold<double>(0, (s, v) => s + v);

    final colors = [
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.lightBlueAccent,
      Colors.pinkAccent,
      Colors.yellowAccent,
      Colors.purpleAccent,
      Colors.redAccent,
      Colors.cyanAccent,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12291D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: _buildPieSections(categoryTotals, colors),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // percentages legend
          Column(
            children: categoryTotals.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final cat = entry.value.key;
              final value = entry.value.value;
              final percent = total == 0 ? 0 : (value / total * 100);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cat,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Text(
                      '${percent.toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

List<PieChartSectionData> _buildPieSections(
  Map<String, double> totals,
  List<Color> colors,
) {
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

