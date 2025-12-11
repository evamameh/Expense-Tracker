import 'package:flutter_riverpod/flutter_riverpod.dart';

class Budget {
  final double limit;
  Budget(this.limit);
}

final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, Map<String, Budget>>((ref) {
  return BudgetNotifier({
    "Groceries": Budget(500),
    "Transport": Budget(200),
    "Dining": Budget(200),
    "Fun": Budget(150),
    "Shopping": Budget(300),
    "Bills": Budget(400),
    "Subscriptions": Budget(100),
    "Health": Budget(150),
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
