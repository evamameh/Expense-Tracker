class RecurringExpense {
  final String id;
  final String originalExpenseId;
  final String category;
  final double amount;
  final String currency;
  final int intervalMonths;
  final DateTime nextDate;

  RecurringExpense({
    required this.id,
    required this.originalExpenseId,
    required this.category,
    required this.amount,
    required this.currency,
    required this.intervalMonths,
    required this.nextDate,
  });

  RecurringExpense copyWith({
    DateTime? nextDate,
  }) {
    return RecurringExpense(
      id: id,
      originalExpenseId: originalExpenseId,
      category: category,
      amount: amount,
      currency: currency,
      intervalMonths: intervalMonths,
      nextDate: nextDate ?? this.nextDate,
    );
  }
}
