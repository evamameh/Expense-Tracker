import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/computed/expenses_by_category.dart';
import '../../providers/computed/spending_trends.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryTotals = ref.watch(expensesByCategoryProvider);
    final trendTotals = ref.watch(spendingTrendsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1C14),
        title: const Text("Analytics", style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===================== PIE CHART =====================
            const Text(
              "Expenses by Category",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),

            Container(
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
            ),

            const SizedBox(height: 40),

            // ===================== LINE CHART =====================
            const Text(
              "Daily Spending Trend",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF12291D),
                borderRadius: BorderRadius.circular(20),
              ),
              height: 280,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      color: Colors.greenAccent,
                      barWidth: 3,
                      isCurved: true,
                      spots: _buildLineSpots(trendTotals),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= PIE SECTIONS =================
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

  // ================= LINE CHART SPOTS =================
  List<FlSpot> _buildLineSpots(Map<int, double> data) {
    final sortedKeys = data.keys.toList()..sort();

    return sortedKeys.map((day) {
      return FlSpot(day.toDouble(), data[day] ?? 0);
    }).toList();
  }
}
