import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/expense.dart';
import '../../providers/currency/selected_currency.dart';
import '../../providers/currency/currency_rates.dart';
import '../pages/edit_expense_page.dart';

class TransactionItem extends ConsumerWidget {
  final Expense expense;

  const TransactionItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final rates = ref.watch(currencyRatesProvider);

    double convertToPHP(double amount, String fromCurrency) {
      final rate = rates[fromCurrency] ?? 1.0;
      return amount * rate;
    }

    double convertFromPHP(double amountPHP, String toCurrency) {
      final rate = rates[toCurrency] ?? 1.0;
      return amountPHP / rate;
    }

    double amountInPHP = convertToPHP(expense.amount, expense.currency);
    double finalAmount = convertFromPHP(amountInPHP, selectedCurrency);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditExpensePage(expense: expense),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF12291D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2E23),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  expense.category[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Category + Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "${expense.date.month}/${expense.date.day}/${expense.date.year}",
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${finalAmount.toStringAsFixed(2)} $selectedCurrency",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (expense.hasReceipt)
                      const Icon(Icons.receipt_long,
                          color: Colors.white54, size: 16),
                    if (expense.isRecurring)
                      const Icon(Icons.repeat,
                          color: Colors.white54, size: 16),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
