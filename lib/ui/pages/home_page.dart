import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/computed/monthly_total_provider.dart';
import '../../providers/expenses_notifier.dart';
import '../../providers/currency/selected_currency.dart';
import '../../providers/currency/currency_rates.dart';
import '../../providers/computed/selected_month_provider.dart';
import '../../providers/computed/date_range_provider.dart';
import '../../providers/computed/expenses_by_category.dart';

import '../../core/currency/currency_converter.dart';

import '../widgets/progress_bar.dart';
import '../widgets/transaction_item.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesNotifierProvider);
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final rates = ref.watch(currencyRatesProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final dateRange = ref.watch(dateRangeProvider);

    const monthlyBudgetPHP = 50000.0;

    // 🔹 FILTER EXPENSES (date range > month fallback)
    final filteredExpenses = expenses.where((e) {
      if (dateRange != null) {
        return !e.date.isBefore(dateRange.start) &&
            !e.date.isAfter(dateRange.end);
      }

      return e.date.year == selectedMonth.year &&
          e.date.month == selectedMonth.month;
    }).toList();

    final totalSpent = ref.watch(monthlyTotalProvider);

    // 🔹 Monthly budget converted
    final monthlyBudget = CurrencyConverter.convert(
      monthlyBudgetPHP,
      "PHP",
      selectedCurrency,
      rates,
    );

    final remaining = monthlyBudget - totalSpent;

    // 🔹 Top categories (already filtered by provider)
    final categoriesData = ref.watch(expensesByCategoryProvider);

    final sortedCategories = categoriesData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C14),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Date selector (range)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateRange == null
                          ? "${_monthName(selectedMonth.month)} ${selectedMonth.year}"
                          : "${dateRange.start.month}/${dateRange.start.day} - "
                              "${dateRange.end.month}/${dateRange.end.day}",
                      style:
                          const TextStyle(fontSize: 22, color: Colors.white),
                    ),
                    const Icon(Icons.date_range, color: Colors.white),
                  ],
                ),
              ),

              if (dateRange != null)
                TextButton(
                  onPressed: () {
                    ref.read(dateRangeProvider.notifier).state = null;
                  },
                  child: const Text(
                    "Clear date range",
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                ),

              const SizedBox(height: 20),

              // 🔹 Currency selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["USD", "EUR", "GBP", "JPY", "PHP"].map((c) {
                    return Padding(
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
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Budget card
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
                          color: remaining >= 0
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          remaining >= 0 ? "Safe" : "Over Budget",
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "${remaining.toStringAsFixed(2)} $selectedCurrency",
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "/ ${monthlyBudget.toStringAsFixed(2)} $selectedCurrency",
                      style: const TextStyle(color: Colors.white54),
                    ),

                    const SizedBox(height: 18),

                    ProgressBar(
                      value:
                          (totalSpent / monthlyBudget).clamp(0.0, 1.0),
                      color: Colors.greenAccent,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "You've spent ${totalSpent.toStringAsFixed(2)} $selectedCurrency so far.",
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 🔹 Top Categories
              const Text(
                "Top Categories",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              Column(
                children: sortedCategories.map((entry) {
                  final spentConverted = CurrencyConverter.convert(
                    entry.value,
                    "PHP",
                    selectedCurrency,
                    rates,
                  );

                  return _categoryCard(
                    category: entry.key,
                    spent: spentConverted,
                    currency: selectedCurrency,
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // 🔹 Recent Transactions
              const Text(
                "Recent Transactions",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Column(
                children: filteredExpenses.reversed
                    .take(5)
                    .map((e) => TransactionItem(expense: e))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryCard({
    required String category,
    required double spent,
    required String currency,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12291D),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(
            "${spent.toStringAsFixed(2)} $currency",
            style: const TextStyle(color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }

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
}
