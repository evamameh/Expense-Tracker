import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../expenses_notifier.dart';
import 'date_range_provider.dart';
import '../../core/expense/expense_totals.dart';

final expensesByCategoryProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(expensesNotifierProvider);
  final dateRange = ref.watch(dateRangeProvider);

  if (dateRange == null) return {};

  final filtered = expenses.where((e) =>
    !e.date.isBefore(dateRange.start) &&
    !e.date.isAfter(dateRange.end)
  ).toList();

  return expensesByCategoryInBaseCurrency(filtered);
});
