import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers
import '../../providers/computed/monthly_total.dart';
import '../../providers/computed/expenses_by_category.dart';
import '../../providers/expenses_notifier.dart';
import '../../providers/currency/selected_currency.dart';
import '../../providers/currency/currency_rates.dart';
import '../../providers/computed/selected_month_provider.dart';
import '../../providers/budget_notifier.dart';

// Widgets
import '../widgets/progress_bar.dart';
import '../widgets/transaction_item.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSpent = ref.watch(monthlyTotalProvider).toDouble();
    final expenses = ref.watch(expensesNotifierProvider);
    final byCategory = ref.watch(expensesByCategoryProvider);
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final rates = ref.watch(currencyRatesProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final budgets = ref.watch(budgetNotifierProvider);

    // ===========================
    //   MAIN BUDGET IN PHP
    // ===========================
    const monthlyBudgetPHP = 250000.0;

    // ===========================
    //   CONVERSION FUNCTION
    //   PHP → selected currency
    // ===========================
    double convert(double amount) {
      final rate = rates[selectedCurrency] ?? 1.0;
      return amount / rate; // PHP to selected currency
    }

    final remaining = monthlyBudgetPHP - totalSpent;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C14),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              

              // ===========================
              //     MONTH SELECTOR
              // ===========================
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedMonth,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                    helpText: "Select Month",
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Colors.greenAccent,
                            onPrimary: Colors.black,
                            surface: Color(0xFF0B1C14),
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    ref.read(selectedMonthProvider.notifier).state =
                        DateTime(picked.year, picked.month);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${_monthName(selectedMonth.month)} ${selectedMonth.year}",
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                    const Icon(Icons.notifications_none, color: Colors.white),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===========================
              //     CURRENCY SELECTOR
              // ===========================
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final c in ["USD", "EUR", "GBP", "JPY", "PHP"])
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => ref
                              .read(selectedCurrencyProvider.notifier)
                              .state = c,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedCurrency == c
                                  ? Colors.greenAccent
                                  : const Color(0xFF1A2E23),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              c,
                              style: TextStyle(
                                color: selectedCurrency == c
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===========================
              //         BALANCE CARD
              // ===========================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF12291D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Safe",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      "${convert(remaining).toStringAsFixed(2)} $selectedCurrency",
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "/ ${convert(monthlyBudgetPHP).toStringAsFixed(2)} $selectedCurrency",
                      style: const TextStyle(color: Colors.white54),
                    ),

                    const SizedBox(height: 18),

                    ProgressBar(
                      value: (totalSpent / monthlyBudgetPHP).clamp(0, 1),
                      color: Colors.greenAccent,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "You've spent ${convert(totalSpent).toStringAsFixed(2)} $selectedCurrency so far.",
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===========================
              //       SUMMARY CARDS
              // ===========================
              Row(
                children: [
                  _summaryCard(
                    title: "Total Spent",
                    value:
                        "${convert(totalSpent).toStringAsFixed(2)} $selectedCurrency",
                    icon: Icons.trending_down,
                    iconColor: Colors.redAccent,
                  ),
                  const SizedBox(width: 16),
                  _summaryCard(
                    title: "Total Saved",
                    value:
                        "${convert(remaining).toStringAsFixed(2)} $selectedCurrency",
                    icon: Icons.trending_up,
                    iconColor: Colors.greenAccent,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ===========================
              //     TOP CATEGORIES
              // ===========================
              const Text(
                "Top Categories",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Column(
                children: byCategory.entries.map((entry) {
                  final category = entry.key;
                  final spent = entry.value.toDouble();
                  final limit = budgets[category]?.limit ?? 1.0;

                  return _categoryCard(
                    category: category,
                    spent: convert(spent),
                    limit: convert(limit),
                    percent:
                        (spent / limit * 100).clamp(0, 100).toDouble(),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // ===========================
              //   RECENT TRANSACTIONS
              // ===========================
              const Text(
                "Recent Transactions",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Column(
                children: expenses.reversed
                    .map((e) => TransactionItem(expense: e))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MONTH NAME HELPER
  String _monthName(int m) {
    const names = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return names[m - 1];
  }

  // SUMMARY CARD WIDGET
  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF12291D),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  // CATEGORY CARD WIDGET
  Widget _categoryCard({
    required String category,
    required double spent,
    required double limit,
    required double percent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12291D),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              Text("${percent.toStringAsFixed(0)}%",
                  style: const TextStyle(color: Colors.orangeAccent)),
            ],
          ),
          const SizedBox(height: 6),
          ProgressBar(
              value: (spent / limit).clamp(0, 1), color: Colors.greenAccent),
          const SizedBox(height: 4),
          Text(
            "${spent.toStringAsFixed(2)} / ${limit.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}
