import 'package:flutter_riverpod/flutter_riverpod.dart';

final currencyRatesProvider = Provider<Map<String, double>>((ref) {
  return {
    "PHP": 1.0,      
    "USD": 59.12,     
    "EUR": 63.87,     
    "GBP": 74.21,     
    "JPY": 0.40,      
  };
});
