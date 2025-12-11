class CategoryBudget {
  final String category;
  final double limit;
  final double spent;

  CategoryBudget({
    required this.category,
    required this.limit,
    required this.spent,
  });

  CategoryBudget copyWith({
    String? category,
    double? limit,
    double? spent,
  }) {
    return CategoryBudget(
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
    );
  }
}
