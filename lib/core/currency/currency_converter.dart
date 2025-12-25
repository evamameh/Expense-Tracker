class CurrencyConverter {
  static double toPHP(
    double amount,
    String from,
    Map<String, double> rates,
  ) {
    return amount * (rates[from] ?? 1.0);
  }

  static double fromPHP(
    double php,
    String to,
    Map<String, double> rates,
  ) {
    return php / (rates[to] ?? 1.0);
  }

  static double convert(
    double amount,
    String from,
    String to,
    Map<String, double> rates,
  ) {
    final php = toPHP(amount, from, rates);
    return fromPHP(php, to, rates);
  }
}
