import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../expenses_notifier.dart';

// This provider should handle splits correctly
final expensesByCategoryProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(expensesNotifierProvider);
  final Map<String, double> categoryTotals = {};

  for (final expense in expenses) {
    if (expense.splits != null && expense.splits!.isNotEmpty) {
      // Handle split expenses - add each split to its respective category
      for (final entry in expense.splits!.entries) {
        final category = entry.key;
        final amount = entry.value;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }
    } else {
      // Handle single category expense
      final category = expense.category;
      final amount = expense.amount;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }
  }

  return categoryTotals;
});
