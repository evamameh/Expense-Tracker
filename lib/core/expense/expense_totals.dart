import '../../models/expense.dart';

double expenseTotalInBaseCurrency(Expense expense) {
  if (expense.splits != null && expense.splits!.isNotEmpty) {
    return expense.splits!.values.fold(0.0, (a, b) => a + b);
  }
  return expense.amount;
}

double expenseTotalForCategoryInBaseCurrency(
  List<Expense> expenses,
  String category,
) {
  return expenses.fold<double>(0.0, (sum, e) {
    if (e.splits != null && e.splits!.containsKey(category)) {
      return sum + (e.splits![category] ?? 0.0);
    }
    if (e.category == category) {
      return sum + e.amount;
    }
    return sum;
  });
}

Map<String, double> expensesByCategoryInBaseCurrency(
  List<Expense> expenses,
) {
  final Map<String, double> totals = {};

  for (final e in expenses) {
    if (e.splits != null && e.splits!.isNotEmpty) {
      e.splits!.forEach((category, amount) {
        totals[category] = (totals[category] ?? 0) + amount;
      });
    } else {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
  }

  return totals; 
}

