import '../models/expense.dart';

class MockData {
  static List<Expense> generateExpenses() {
    return [
      Expense(
        id: "1",
        amount: 120.50,
        category: "Food",
        date: DateTime.now().subtract(const Duration(days: 1)),
        currency: "USD",
        note: "Lunch with friends",
      ),
      Expense(
        id: "2",
        amount: 250.00,
        category: "Transportation",
        date: DateTime.now().subtract(const Duration(days: 2)),
        currency: "USD",
        note: "Grab ride",
      ),
      Expense(
        id: "3",
        amount: 899.99,
        category: "Shopping",
        date: DateTime.now().subtract(const Duration(days: 3)),
        currency: "USD",
        note: "New shoes",
      ),
      Expense(
        id: "4",
        amount: 60.00,
        category: "Bills",
        date: DateTime.now().subtract(const Duration(days: 4)),
        currency: "USD",
      ),
      Expense(
        id: "5",
        amount: 45.75,
        category: "Entertainment",
        date: DateTime.now().subtract(const Duration(days: 5)),
        currency: "USD",
        note: "Movie",
      ),
    ];
  }
}
