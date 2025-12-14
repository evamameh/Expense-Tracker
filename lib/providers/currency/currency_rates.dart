import 'package:flutter_riverpod/flutter_riverpod.dart';

final currencyRatesProvider = Provider<Map<String, double>>((ref) {
  return {
    "PHP": 1.0,       // BASE currency
    "USD": 59.12,     // 1 USD = 59.12 PHP
    "EUR": 63.87,     // example
    "GBP": 74.21,     // example
    "JPY": 0.40,      // 1 JPY = 0.40 PHP
  };
});
