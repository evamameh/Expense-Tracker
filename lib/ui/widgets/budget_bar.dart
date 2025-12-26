import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/computed/converted_expenses_provider.dart';
import '../../providers/currency/selected_currency.dart';
import '../../providers/currency/currency_rates.dart';
import '../../providers/computed/date_range_provider.dart';
import '../../core/currency/currency_converter.dart';
import '../../core/expense/expense_totals.dart';
import '../widgets/progress_bar.dart';

class BudgetCard extends ConsumerWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(convertedExpensesProvider);
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final rates = ref.watch(currencyRatesProvider);
    final dateRange = ref.watch(dateRangeProvider);

    const monthlyBudgetPHP = 50000.0;
    final defaultMonth = DateTime(2025, 12);

    final filteredExpenses = expenses.where((e) {
      if (dateRange != null) {
        return !e.date.isBefore(dateRange.start) &&
               !e.date.isAfter(dateRange.end);
      }
      return e.date.year == defaultMonth.year &&
             e.date.month == defaultMonth.month;
    }).toList();

    final totalSpent = filteredExpenses.fold<double>(
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

    final monthlyBudget = CurrencyConverter.convert(
      monthlyBudgetPHP,
      "PHP",
      selectedCurrency,
      rates,
    );

    final remaining = monthlyBudget - totalSpent;

    return Container(
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            value: monthlyBudget == 0
                ? 0
                : (totalSpent / monthlyBudget).clamp(0.0, 1.0),
            color: Colors.greenAccent,
          ),
          const SizedBox(height: 6),
          Text(
            "You've spent ${totalSpent.toStringAsFixed(2)} $selectedCurrency",
            style: const TextStyle(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}
