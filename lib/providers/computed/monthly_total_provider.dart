import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../expenses_notifier.dart';
import '../currency/selected_currency.dart';
import '../currency/currency_rates.dart';
import 'selected_month_provider.dart';
import 'date_range_provider.dart';

import '../../core/currency/currency_converter.dart';
import '../../core/expense/expense_totals.dart';

final monthlyTotalProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesNotifierProvider);
  final selectedCurrency = ref.watch(selectedCurrencyProvider);
  final rates = ref.watch(currencyRatesProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  final dateRange = ref.watch(dateRangeProvider);

  final filteredExpenses = expenses.where((e) {
    if (dateRange != null) {
      return !e.date.isBefore(dateRange.start) &&
             !e.date.isAfter(dateRange.end);
    }

    return e.date.year == selectedMonth.year &&
           e.date.month == selectedMonth.month;
  });

  return filteredExpenses.fold<double>(
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
});
