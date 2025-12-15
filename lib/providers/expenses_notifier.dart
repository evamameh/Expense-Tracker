import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../mock/mock_expenses.dart';

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  ExpensesNotifier() : super(List.from(mockExpenses));

  void addExpense(Expense expense) {
    state = [...state, expense];
    
    // If expense has splits, update each category separately
    if (expense.splits != null && expense.splits!.isNotEmpty) {
      // Process splits - each category should be updated with its split amount
      for (final entry in expense.splits!.entries) {
        final category = entry.key;
        final amount = entry.value;
        print('Processing split: $category = $amount'); // Debug
        
        // Update budget or category tracking for each split
        // Make sure this processes each category correctly
      }
    } else {
      // Process single category expense
      print('Processing single expense: ${expense.category} = ${expense.amount}');
    }
  }

  void updateExpense(Expense updated) {
    state = state.map((e) => e.id == updated.id ? updated : e).toList();
  }

  void deleteExpense(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  /// convenience for adding raw (not used for splits)
  void addExpenseRaw({
    required double amount,
    required String category,
    required DateTime date,
    required String currency,
    String? note,
    bool isRecurring = false,
    bool hasReceipt = false,
    Map<String, double>? splits,
    int recurrenceIntervalMonths = 1,
    String? templateId,
  }) {
    final e = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: category,
      date: date,
      currency: currency,
      note: note,
      isRecurring: isRecurring,
      hasReceipt: hasReceipt,
      splits: splits,
      recurrenceIntervalMonths: recurrenceIntervalMonths,
      templateId: templateId,
    );
    addExpense(e);
  }
}

final expensesNotifierProvider =
    StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) => ExpensesNotifier());
