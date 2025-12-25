class RecurringTemplate {
  final String id;
  final double amount;
  final String currency;
  final String note;
  final Map<String, double>? splits;
  final int intervalMonths; 
  DateTime nextDate;
  final bool active;

  RecurringTemplate({
    required this.id,
    required this.amount,
    required this.currency,
    required this.note,
    this.splits,
    required this.intervalMonths,
    required this.nextDate,
    this.active = true,
  });

  RecurringTemplate copyWith({
    String? id,
    double? amount,
    String? currency,
    String? note,
    Map<String, double>? splits,
    int? intervalMonths,
    DateTime? nextDate,
    bool? active,
  }) {
    return RecurringTemplate(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      note: note ?? this.note,
      splits: splits ?? this.splits,
      intervalMonths: intervalMonths ?? this.intervalMonths,
      nextDate: nextDate ?? this.nextDate,
      active: active ?? this.active,
    );
  }
}
