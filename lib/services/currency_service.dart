class CurrencyService {
  static const Map<String, double> _exchangeRates = {
  'USD': 1.0,
  'EUR': 0.93,
  'PHP': 56.0,
  'JPY': 148.0,
  'GBP': 0.80,
};

  double convert({
    required double amount,
    required String from,
    required String to,
  }) {
    if (!_exchangeRates.containsKey(from) || !_exchangeRates.containsKey(to)) {
      throw Exception("Unsupported currency");
    }

    double inUsd = amount / _exchangeRates[from]!;
    double result = inUsd * _exchangeRates[to]!;

    return double.parse(result.toStringAsFixed(2));
  }

  List<String> getSupportedCurrencies() {
    return _exchangeRates.keys.toList();
  }
}
