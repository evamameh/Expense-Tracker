import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../expenses_notifier.dart';
import 'date_range_provider.dart';
import '../../core/expense/expense_totals.dart';

final spendingTrendsProvider = Provider<Map<int, double>>((ref) {
  final expenses = ref.watch(expensesNotifierProvider);
  final dateRange = ref.watch(dateRangeProvider);

  if (dateRange == null) return {};

  final filtered = expenses.where((e) =>
      !e.date.isBefore(dateRange.start) &&
      !e.date.isAfter(dateRange.end),
  );

  final daily = <int, double>{};
  for (var e in filtered) {
    final day = e.date.day;
    final amount = expenseTotalInBaseCurrency(e);
    daily[day] = (daily[day] ?? 0) + amount;
  }

  return daily;
});
