import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/ui/widgets/stat_card.dart';
import 'package:expense_tracker/ui/widgets/time_period_selector.dart';
import '../../providers/computed/expenses_by_category.dart';
import '../../providers/computed/spending_trends.dart';
import '../widgets/analytics_line_chart.dart';
import '../widgets/analytics_pie_chart.dart';



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

            TimePeriodSelector(),
            const SizedBox(height: 24),

            const Text(
              "Daily Spending Trend",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),

            AnalyticsLineChart(trendTotals: trendTotals),

            const SizedBox(height: 16),

            Row(
              children: const [
                Expanded(
                  child: StatCard(
                    label: 'AVG. DAILY',
                    value: '\$79.03',
                    changeText: '↑ 2%',
                    changeColor: Colors.greenAccent,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    label: 'PROJECTED',
                    value: '\$3,100',
                    subtitle: 'Est. End',
                    changeText: '',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    label: 'SAVED',
                    value: '\$120',
                    changeText: '↑ 8%',
                    changeColor: Colors.greenAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF10231A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3325),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.compare_arrows_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Compare to previous month',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {
                      bool isOn = false;
                      return Switch(
                        value: isOn,
                        activeThumbColor: Colors.white,
                        activeTrackColor: Colors.greenAccent,
                        onChanged: (val) {
                          setState(() => isOn = val);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),


            const SizedBox(height: 40),

            const Text(
              "Expenses by Category",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),

            AnalyticsPieChart(categoryTotals: categoryTotals),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
