import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../expenses_notifier.dart';

final monthlyTotalProvider = Provider((ref) {
  final expenses = ref.watch(expensesNotifierProvider);
  return expenses.fold(0.0, (sum, e) => sum + e.amount);
});
