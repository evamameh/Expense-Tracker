import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../expenses_notifier.dart';
import '../currency/selected_currency.dart';
import '../currency/currency_rates.dart';
import '../computed/date_range_provider.dart';

import '../../models/expense.dart';
import '../../core/currency/currency_converter.dart';
import '../../core/expense/expense_totals.dart';

  final convertedExpensesProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expensesNotifierProvider);
  final selectedCurrency = ref.watch(selectedCurrencyProvider);
  final rates = ref.watch(currencyRatesProvider);
  final dateRange = ref.watch(dateRangeProvider);

  // 🔹 DEFAULT MONTH = CURRENT MONTH
  final now = DateTime.now();
  final defaultMonth = DateTime(now.year, now.month);

  // 🔹 Filter expenses by date range OR current month
  final filtered = expenses.where((e) {
    if (dateRange != null) {
      return !e.date.isBefore(dateRange.start) &&
          !e.date.isAfter(dateRange.end);
    }

    return e.date.year == defaultMonth.year &&
        e.date.month == defaultMonth.month;
  });

  // 🔹 Convert each expense to selected currency
  return filtered.map((e) {
    final baseAmount = expenseTotalInBaseCurrency(e);

    final convertedAmount = CurrencyConverter.convert(
      baseAmount,
      e.currency,
      selectedCurrency,
      rates,
    );

    return e.copyWith(
      amount: convertedAmount,
      currency: selectedCurrency,
    );
  }).toList();
});
