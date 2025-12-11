import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../expenses_notifier.dart';

final spendingTrendsProvider = Provider((ref) {
  final expenses = ref.watch(expensesNotifierProvider);

  final daily = <int, double>{};

  for (var e in expenses) {
    daily[e.date.day] = (daily[e.date.day] ?? 0) + e.amount;
  }

  return daily;
});
