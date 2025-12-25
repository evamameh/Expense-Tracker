import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recurring_expense.dart';
import '../models/expense.dart';
import 'expenses_notifier.dart';

class RecurringNotifier extends StateNotifier<List<RecurringExpense>> {
  RecurringNotifier() : super([]);

  void createFromExpense(Expense expense, {required int intervalMonths}) {
    final template = RecurringExpense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      originalExpenseId: expense.id,
      category: expense.category,
      amount: expense.amount,
      currency: expense.currency,
      intervalMonths: intervalMonths,
      nextDate: DateTime(expense.date.year, expense.date.month + intervalMonths, expense.date.day),
    );

    state = [...state, template];
  }

  void generateDueExpenses(WidgetRef ref) {
    final now = DateTime.now();

    for (final r in state) {
      if (now.isAfter(r.nextDate)) {
        final newExpense = Expense(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: r.amount,
          category: r.category,
          currency: r.currency,
          date: r.nextDate,
        );

        ref.read(expensesNotifierProvider.notifier).addExpense(newExpense);

        final updated = r.copyWith(
          nextDate: DateTime(
            r.nextDate.year,
            r.nextDate.month + r.intervalMonths,
            r.nextDate.day,
          ),
        );

        state = [
          for (final t in state)
            if (t.id == r.id) updated else t
        ];
      }
    }
  }
}

final recurringNotifierProvider =
    StateNotifierProvider<RecurringNotifier, List<RecurringExpense>>(
  (ref) => RecurringNotifier(),
);
