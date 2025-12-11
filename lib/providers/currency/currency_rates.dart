import 'package:flutter_riverpod/flutter_riverpod.dart';

final currencyRatesProvider = Provider<Map<String, double>>((ref) {
  return {
    "USD": 1.0,
    "EUR": 0.92,
    "GBP": 0.79,
    "JPY": 158,
    "PHP": 58,
  };
});
