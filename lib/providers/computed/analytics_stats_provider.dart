import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../expenses_notifier.dart';
import '../currency/selected_currency.dart';
import '../currency/currency_rates.dart';
import 'date_range_provider.dart';
import '../../core/currency/currency_converter.dart';
import '../../core/expense/expense_totals.dart';

class AnalyticsStats {
  final double totalSpent;
  final double avgDaily;
  final double projected;

  const AnalyticsStats({
    required this.totalSpent,
    required this.avgDaily,
    required this.projected,
  });
}

final analyticsStatsProvider = Provider<AnalyticsStats>((ref) {
  final expenses = ref.watch(expensesNotifierProvider);
  final selectedCurrency = ref.watch(selectedCurrencyProvider);
  final rates = ref.watch(currencyRatesProvider);
  final dateRange = ref.watch(dateRangeProvider);

  if (dateRange == null) {
    return const AnalyticsStats(totalSpent: 0, avgDaily: 0, projected: 0);
  }

  final filtered = expenses.where((e) =>
      !e.date.isBefore(dateRange.start) &&
      !e.date.isAfter(dateRange.end));

  final totalSpent = filtered.fold<double>(0, (sum, e) {
    final base = expenseTotalInBaseCurrency(e);
    return sum +
        CurrencyConverter.convert(
          base,
          e.currency,
          selectedCurrency,
          rates,
        );
  });

  final daysInRange =
      dateRange.end.difference(dateRange.start).inDays + 1;
  final avgDaily = daysInRange == 0 ? 0.0 : totalSpent / daysInRange;

  // Project to full calendar month based on current rate
  final daysInMonth =
      DateTime(dateRange.start.year, dateRange.start.month + 1, 0)
          .day;
  final projected =
      daysInRange == 0 ? 0.0 : (avgDaily * daysInMonth).toDouble();

  return AnalyticsStats(
    totalSpent: totalSpent,
    avgDaily: avgDaily,
    projected: projected,
  );
});
