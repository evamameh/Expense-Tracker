// lib/utils/formatters.dart

import 'package:intl/intl.dart';

class Formatters {
  /// Format currency with 2 decimal places
  static String currency(double amount, {String symbol = "\$"}) {
    return "$symbol${amount.toStringAsFixed(2)}";
  }

  /// Format DateTime → "Oct 11, 2024"
  static String date(DateTime date) {
    return DateFormat("MMM dd, yyyy").format(date);
  }

  /// Format number for compact display, e.g. 1000 → "1K"
  static String compact(double number) {
    return NumberFormat.compact().format(number);
  }
}
