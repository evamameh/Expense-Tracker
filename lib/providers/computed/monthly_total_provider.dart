import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../expenses_notifier.dart';
import '../currency/selected_currency.dart';
import '../currency/currency_rates.dart';
import 'date_range_provider.dart';

import '../../core/currency/currency_converter.dart';
import '../../core/expense/expense_totals.dart';

final monthlyTotalProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesNotifierProvider);
  final selectedCurrency = ref.watch(selectedCurrencyProvider);
  final rates = ref.watch(currencyRatesProvider);
  final dateRange = ref.watch(dateRangeProvider);

  if (dateRange == null) return 0.0;

  final filteredExpenses = expenses.where((e) =>
    !e.date.isBefore(dateRange.start) &&
    !e.date.isAfter(dateRange.end)
  );

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
