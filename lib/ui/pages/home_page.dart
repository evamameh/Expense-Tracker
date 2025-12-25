import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/expenses_notifier.dart';
import '../../providers/currency/selected_currency.dart';
import '../../providers/currency/currency_rates.dart';
import '../../providers/computed/selected_month_provider.dart';
import '../../providers/computed/expenses_by_category.dart';

import '../../core/currency/currency_converter.dart';
import '../../core/expense/expense_totals.dart';

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

    const monthlyBudgetPHP = 250000.0;

    // 🔹 TOTAL SPENT (split-aware + centralized conversion)
    final totalSpent = expenses
        .where((e) =>
            e.date.year == selectedMonth.year &&
            e.date.month == selectedMonth.month)
        .fold<double>(
          0.0,
          (sum, e) {
            final baseAmount = expenseTotalInBaseCurrency(e);
            return sum +
                CurrencyConverter.convert(
                  baseAmount,
                  e.currency,
                  selectedCurrency,
                  rates,
                );
          },
        );

    // 🔹 Monthly budget converted
    final monthlyBudget = CurrencyConverter.convert(
      monthlyBudgetPHP,
      "PHP",
      selectedCurrency,
      rates,
    );

    final remaining = monthlyBudget - totalSpent;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C14),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Month Selector
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedMonth,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    ref.read(selectedMonthProvider.notifier).state =
                        DateTime(picked.year, picked.month);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_monthName(selectedMonth.month)} ${selectedMonth.year}",
                      style:
                          const TextStyle(fontSize: 22, color: Colors.white),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Currency Selector
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

              // 🔹 Budget Card
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
                      value: (totalSpent / monthlyBudget).clamp(0.0, 1.0),
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

              // 🔹 Top Categories (UNCHANGED logic)
              const Text(
                "Top Categories",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              Column(
                children: () {
                  final categoriesData =
                      ref.watch(expensesByCategoryProvider);

                  final sorted = categoriesData.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));

                  return sorted.map((entry) {
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
                  }).toList();
                }(),
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
                children: expenses.reversed
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
