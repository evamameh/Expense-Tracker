class Expense {
  final String id;
  final double amount; 
  final String category;
  final DateTime date;
  final String currency;
  final String? note;
  final bool isRecurring;
  final bool hasReceipt;

  final Map<String, double>? splits;

  final int recurrenceIntervalMonths;

  final String? templateId;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.currency,
    this.note,
    this.isRecurring = false,
    this.hasReceipt = false,
    this.splits,
    this.recurrenceIntervalMonths = 1,
    this.templateId,
  });

  Expense copyWith({
    String? id,
    double? amount,
    String? category,
    DateTime? date,
    String? currency,
    String? note,
    bool? isRecurring,
    bool? hasReceipt,
    Map<String, double>? splits,
    int? recurrenceIntervalMonths,
    String? templateId,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      currency: currency ?? this.currency,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
      hasReceipt: hasReceipt ?? this.hasReceipt,
      splits: splits ?? this.splits,
      recurrenceIntervalMonths: recurrenceIntervalMonths ?? this.recurrenceIntervalMonths,
      templateId: templateId ?? this.templateId,
    );
  }
}
