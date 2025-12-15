// home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers
import '../../providers/computed/monthly_total.dart';
import '../../providers/computed/expenses_by_category.dart';
import '../../providers/expenses_notifier.dart';
import '../../providers/currency/selected_currency.dart';
import '../../providers/currency/currency_rates.dart';
import '../../providers/computed/selected_month_provider.dart';

// Widgets
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

    // -----------------------------
    // BASE MONTHLY BUDGET (IN PHP)
    // -----------------------------
    const monthlyBudgetPHP = 250000.0;

    // -----------------------------
    // CONVERSION HELPERS
    // -----------------------------
    // Convert ANY expense TO PHP
    double convertToPHP(double amount, String fromCurrency) {
      final rate = (rates[fromCurrency] ?? 1.0).toDouble();
      return amount * rate;
    }

    // Convert PHP → selectedCurrency for UI
    double convertFromPHP(double phpAmount) {
      final rate = (rates[selectedCurrency] ?? 1.0).toDouble();
      return phpAmount / rate;
    }

    // -----------------------------
    // TOTAL SPENT FOR SELECTED MONTH (PHP)
    // -----------------------------
    final totalSpentPHP = expenses
        .where((e) =>
            e.date.year == selectedMonth.year &&
            e.date.month == selectedMonth.month)
        .fold<double>(0.0, (sum, e) => sum + convertToPHP(e.amount, e.currency));

    // Values converted to UI currency
    final totalSpent = convertFromPHP(totalSpentPHP);
    final remaining = convertFromPHP(monthlyBudgetPHP - totalSpentPHP);
    final monthlyBudgetConverted = convertFromPHP(monthlyBudgetPHP);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C14),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -----------------------------
              // MONTH PICKER
              // -----------------------------
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
                              fontSize: 22, color: Colors.white),
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

              // -----------------------------
              // CURRENCY SELECTOR
              // -----------------------------
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

              // -----------------------------
              // STATIC CURRENCY CONVERSION RATES
              // -----------------------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF12291D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Exchange Rates (to ${selectedCurrency})",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Show all rates converted to the selected currency
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: rates.entries
                          .where((entry) => entry.key != selectedCurrency) // Exclude selected currency
                          .map((entry) => _rateCard(
                                currency: entry.key,
                                rate: _convertRate(entry.value.toDouble(), selectedCurrency, rates),
                                selectedCurrency: selectedCurrency,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // -----------------------------
              // BALANCE CARD
              // -----------------------------
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

                    // Remaining balance
                    Text(
                      "${remaining.toStringAsFixed(2)} $selectedCurrency",
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Monthly budget
                    Text(
                      "/ ${monthlyBudgetConverted.toStringAsFixed(2)} $selectedCurrency",
                      style: const TextStyle(color: Colors.white54),
                    ),

                    const SizedBox(height: 18),

                    // Progress bar (spent)
                    ProgressBar(
                      value: (totalSpentPHP / monthlyBudgetPHP).clamp(0, 1),
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

              const SizedBox(height: 20),

              // -----------------------------
              // SUMMARY CARDS
              // -----------------------------
              Row(
                children: [
                  _summaryCard(
                    title: "Total Spent",
                    value:
                        "${totalSpent.toStringAsFixed(2)} $selectedCurrency",
                    icon: Icons.trending_down,
                    iconColor: Colors.redAccent,
                  ),
                  const SizedBox(width: 16),
                  _summaryCard(
                    title: "Total Saved",
                    value:
                        "${remaining.toStringAsFixed(2)} $selectedCurrency",
                    icon: Icons.trending_up,
                    iconColor: Colors.greenAccent,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // -----------------------------
              // TOP CATEGORIES SUMMARY
              // -----------------------------
              const Text(
                "Top Categories",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // categories based on expenses
              Column(
                children: () {
                  final categoriesData = ref.watch(expensesByCategoryProvider);
                  
                  // Convert to list and sort by spending amount (highest first)
                  final sortedCategories = categoriesData.entries
                      .map((entry) => MapEntry(entry.key, entry.value.toDouble()))
                      .toList()
                      ..sort((a, b) => b.value.compareTo(a.value));

                  return sortedCategories.map((entry) {
                    final category = entry.key;
                    final spentPHP = entry.value;
                    final spentConverted = convertFromPHP(spentPHP);

                    return _categoryCard(
                      category: category,
                      spent: spentConverted,
                    );
                  }).toList();
                }(),
              ),

              const SizedBox(height: 28),

              // -----------------------------
              // RECENT TRANSACTIONS
              // -----------------------------
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

  // Month name helper
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

  // Summary card widget
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

  // Simple category card (no budgets here)
  Widget _categoryCard({
    required String category,
    required double spent,
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
          Text("${spent.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.greenAccent)),
        ],
      ),
    );
  }

  // Helper function to convert rates based on selected currency
  double _convertRate(double phpRate, String targetCurrency, Map<String, num> rates) {
    if (targetCurrency == "PHP") {
      return phpRate;
    }
    
    // Convert from PHP to target currency
    final targetRate = (rates[targetCurrency] ?? 1.0).toDouble();
    return phpRate / targetRate;
  }

  // Currency rate card widget
  Widget _rateCard({
    required String currency,
    required double rate,
    required String selectedCurrency,
  }) {
    // Get currency symbol
    String getCurrencySymbol(String curr) {
      switch (curr) {
        case 'USD': return '\$';
        case 'EUR': return '€';
        case 'GBP': return '£';
        case 'JPY': return '¥';
        case 'PHP': return '₱';
        default: return curr;
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E23),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currency,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${getCurrencySymbol(selectedCurrency)}${rate.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
