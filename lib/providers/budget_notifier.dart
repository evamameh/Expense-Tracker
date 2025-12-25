import 'package:flutter_riverpod/flutter_riverpod.dart';

class Budget {
  final double limit;
  Budget(this.limit);
}

final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, Map<String, Budget>>((ref) {
  return BudgetNotifier({
    "Groceries": Budget(10500),
    "Transport": Budget(5000),
    "Dining": Budget(5000),
    "Fun": Budget(3000),
    "Shopping": Budget(2500),
    "Bills": Budget(4000),
    "Subscriptions": Budget(2000),
    "Health": Budget(3000),
  });
});

class BudgetNotifier extends StateNotifier<Map<String, Budget>> {
  BudgetNotifier(super.state);

  void updateLimit(String category, double newLimit) {
    state = {
      ...state,
      category: Budget(newLimit),
    };
  }
}
