import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../expenses_notifier.dart';

final currencyRatesProvider = Provider<Map<String, double>>((ref) {
  return {
    "USD": 1.0,
    "EUR": 0.92,
    "GBP": 0.80,
    "PHP": 56.0,
  };
});

final selectedCurrencyProvider = StateProvider<String>((ref) => "USD");

final convertedExpensesProvider = Provider((ref) {
  final expenses = ref.watch(expensesNotifierProvider);
  final rates = ref.watch(currencyRatesProvider);
  final selected = ref.watch(selectedCurrencyProvider);

  return expenses.map((e) {
    final baseUSD = e.amount / rates[e.currency]!;
    return baseUSD * rates[selected]!;
  }).toList();
});
