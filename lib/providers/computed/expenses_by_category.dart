import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../expenses_notifier.dart';
import 'selected_month_provider.dart';
import 'date_range_provider.dart';
import '../../core/expense/expense_totals.dart';

final expensesByCategoryProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(expensesNotifierProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  final range = ref.watch(dateRangeProvider);

  final filteredExpenses = expenses.where((e) {
    if (range != null) {
      return e.date.isAfter(range.start.subtract(const Duration(days: 1))) &&
             e.date.isBefore(range.end.add(const Duration(days: 1)));
    }

    // fallback to month-based filtering
    return e.date.year == selectedMonth.year &&
           e.date.month == selectedMonth.month;
  }).toList();

  return expensesByCategoryInBaseCurrency(filteredExpenses);
});
