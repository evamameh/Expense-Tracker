import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/ui/widgets/stat_card.dart';
import 'package:expense_tracker/ui/widgets/time_period_selector.dart';
import 'package:expense_tracker/ui/widgets/analytics_line_chart.dart';
import 'package:expense_tracker/ui/widgets/analytics_pie_chart.dart';
import 'package:expense_tracker/ui/widgets/compare_previous_month_switch.dart';

import '../../providers/computed/expenses_by_category.dart';
import '../../providers/computed/spending_trends.dart';
import '../../providers/computed/date_range_provider.dart'; 


class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryTotals = ref.watch(expensesByCategoryProvider);
    final trendTotals = ref.watch(spendingTrendsProvider);
    final dateRange = ref.watch(dateRangeProvider);

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
            // ================= TIME PERIOD SELECTOR =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateRange == null
                      ? 'Select a date range'
                      : '${dateRange.start.month}/${dateRange.start.day}'
                        ' - ${dateRange.end.month}/${dateRange.end.day}',
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),

                Row(
                  children: [
                    if (dateRange != null)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        tooltip: "Clear date range",
                        onPressed: () {
                          ref.read(dateRangeProvider.notifier).state = null;
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.date_range, color: Colors.white),
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                          initialDateRange: dateRange,
                        );
                        if (picked != null) {
                          ref.read(dateRangeProvider.notifier).state = picked;
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ===================== LINE CHART =====================
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

            ComparePreviousMonthSwitch(),
            
            const SizedBox(height: 10),


            // ===================== PIE CHART =====================
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
