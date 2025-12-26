import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../expenses_notifier.dart';
import 'date_range_provider.dart';
import '../currency/selected_currency.dart';
import '../currency/currency_rates.dart';
import '../../core/currency/currency_converter.dart';
import '../../core/expense/expense_totals.dart';

final expensesByCategoryProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(expensesNotifierProvider);
  final dateRange = ref.watch(dateRangeProvider);
  final selectedCurrency = ref.watch(selectedCurrencyProvider);
  final rates = ref.watch(currencyRatesProvider);

  if (dateRange == null) return {};

  final filtered = expenses.where((e) =>
    !e.date.isBefore(dateRange.start) &&
    !e.date.isAfter(dateRange.end));
    
  final byCategory = <String, double>{};

  for (final e in filtered) {
    final baseAmount = expenseTotalInBaseCurrency(e);
    final converted = CurrencyConverter.convert(
      baseAmount,
      e.currency,
      selectedCurrency,
      rates,
    );
    final cat = e.category;
    byCategory[cat] = (byCategory[cat] ?? 0) + converted;
  }

  return byCategory;
});
