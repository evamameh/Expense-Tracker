import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount, {String symbol = "\$"}) {
    return "$symbol${amount.toStringAsFixed(2)}";
  }

  static String date(DateTime date) {
    return DateFormat("MMM dd, yyyy").format(date);
  }

  static String compact(double number) {
    return NumberFormat.compact().format(number);
  }
}
