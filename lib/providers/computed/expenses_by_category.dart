import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../expenses_notifier.dart';

final expensesByCategoryProvider = Provider((ref) {
  final expenses = ref.watch(expensesNotifierProvider);

  final totals = <String, double>{};

  for (var e in expenses) {
    totals[e.category] = (totals[e.category] ?? 0) + e.amount;
  }

  return totals;
});
