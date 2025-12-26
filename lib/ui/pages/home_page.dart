import 'package:expense_tracker/providers/budget_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/expenses_notifier.dart';
import '../../providers/currency/selected_currency.dart';
import '../../providers/currency/currency_rates.dart';
import '../../providers/computed/date_range_provider.dart';

import '../../core/currency/currency_converter.dart';
import '../../core/expense/expense_totals.dart';

import '../widgets/progress_bar.dart';
import '../widgets/transaction_item.dart';
import '../widgets/budget_bar.dart';
import '../widgets/category_card.dart';
import '../widgets/currency_selector.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesNotifierProvider);
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final rates = ref.watch(currencyRatesProvider);
    final dateRange = ref.watch(dateRangeProvider);

    final defaultMonth = DateTime(2025, 12);

    const monthlyBudgetPHP = 50000.0;

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

    // 🔹 TOP CATEGORIES (DECEMBER BY DEFAULT)
    final categories =
        expensesByCategoryInBaseCurrency(filteredExpenses).entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C14),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateRange == null
                        ? "December 2025"
                        : "${dateRange.start.month}/${dateRange.start.day}"
                            " - ${dateRange.end.month}/${dateRange.end.day}",
                    style:
                        const TextStyle(fontSize: 22, color: Colors.white),
                  ),
                  Row(
                    children: [
                      if (dateRange != null)
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white70),
                          tooltip: "Clear date range",
                          onPressed: () {
                            ref
                                .read(dateRangeProvider.notifier)
                                .state = null;
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.date_range,
                            color: Colors.white),
                        onPressed: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                            initialDateRange: dateRange,
                          );

                          if (picked != null) {
                            ref
                                .read(dateRangeProvider.notifier)
                                .state = picked;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🔹 Currency Selector
              const CurrencySelector(),

              const SizedBox(height: 20),

              // 🔹 Budget Card
              const BudgetCard(),

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
                children: categories.map((entry) {
                  final spentConverted = CurrencyConverter.convert(
                    entry.value,
                    "PHP",
                    selectedCurrency,
                    rates,
                  );
                  return CategoryCard(
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
}
