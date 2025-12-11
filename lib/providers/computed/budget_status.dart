import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../budget_notifier.dart';
import '../computed/expenses_by_category.dart';

final budgetStatusProvider = Provider((ref) {
  final budgets = ref.watch(budgetNotifierProvider);
  final expenses = ref.watch(expensesByCategoryProvider);

  return budgets.map((category, budget) {
    final spent = expenses[category] ?? 0;
    final percent = spent / budget.limit;

    String status;
    if (percent < 0.8) {
      status = "Safe";
    } else if (percent < 1.0) {
      status = "Nearing Limit";
    } else {
      status = "Over Budget";
    }

    return MapEntry(category, status);
  });
});
