import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/budget_notifier.dart';
import '../../providers/expenses_notifier.dart';
import '../../providers/currency/selected_currency.dart';
import '../../providers/currency/currency_rates.dart';

import '../widgets/progress_bar.dart';

class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetNotifierProvider);
    final expenses = ref.watch(expensesNotifierProvider);

    // CURRENCY SYSTEM
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final rates = ref.watch(currencyRatesProvider);

    double convertToPHP(double amount, String fromCurrency) {
      final rate = (rates[fromCurrency] ?? 1.0).toDouble();
      return amount * rate;
    }

    double convertFromPHP(double amountPHP, String toCurrency) {
      final rate = (rates[toCurrency] ?? 1.0).toDouble();
      return amountPHP / rate;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PAGE TITLE
              const Text(
                "Budgets",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // CURRENCY SELECTOR (SAME AS HOME PAGE)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final c in ["USD", "EUR", "GBP", "JPY", "PHP"])
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => ref
                              .read(selectedCurrencyProvider.notifier)
                              .state = c,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedCurrency == c
                                  ? Colors.greenAccent
                                  : const Color(0xFF1A2E23),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              c,
                              style: TextStyle(
                                color: selectedCurrency == c
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // LIST OF BUDGET CARDS
              Expanded(
                child: ListView(
                  children: budgets.entries.map((entry) {
                    final category = entry.key;
                    final limitPHP = entry.value.limit;

                    // Calculate spent in PHP (respecting splits if any)
                    final spentPHP = expenses
                        .where((e) => _expenseAffectsCategory(e, category))
                        .fold<double>(
                          0.0,
                          (sum, e) {
                            // if split exists and has this category, add split amount
                            if (e.splits != null && e.splits!.isNotEmpty) {
                              return sum + (e.splits![category] ?? 0.0) * ( (rates[e.currency] ?? 1.0).toDouble() );
                            }
                            // otherwise whole amount goes to e.category
                            return sum + convertToPHP(e.amount, e.currency);
                          },
                        );

                    // Convert to selected currency
                    final spent = convertFromPHP(spentPHP, selectedCurrency);
                    final limit = convertFromPHP(limitPHP, selectedCurrency);

                    // ensure percent is a double for ProgressBar
                    final percent = (limit == 0) ? 0.0 : (spent / limit).clamp(0, 1.0).toDouble();

                    final isOver = spent > limit;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12291D),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HEADER ROW with edit button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              Row(
                                children: [
                                  // Edit icon
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white70),
                                    onPressed: () async {
                                      final newLimit = await _showEditLimitDialog(
                                          context,
                                          category,
                                          limit,
                                          selectedCurrency);
                                      if (newLimit != null) {
                                        // convert entered limit from selectedCurrency -> PHP,
                                        // because provider stores limits in PHP in this app
                                        final enteredAsDouble = newLimit;
                                        final toPHP = enteredAsDouble * (rates[selectedCurrency] ?? 1.0);
                                        // call your notifier update function (common name: updateLimit)
                                        ref
                                            .read(budgetNotifierProvider.notifier)
                                            .updateLimit(category, toPHP.toDouble());
                                      }
                                    },
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isOver
                                          ? Colors.redAccent
                                          : Colors.greenAccent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isOver ? "Over Budget" : "Safe",
                                      style: TextStyle(
                                        color:
                                            isOver ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Progress Bar
                          ProgressBar(
                            value: percent,
                            color: Colors.greenAccent,
                          ),

                          const SizedBox(height: 6),

                          // Spent
                          Text(
                            "${spent.toStringAsFixed(2)} $selectedCurrency spent",
                            style:
                                const TextStyle(color: Colors.white70, fontSize: 14),
                          ),

                          // Limit
                          Text(
                            "Limit: ${limit.toStringAsFixed(2)} $selectedCurrency",
                            style:
                                const TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: checks whether an expense affects given category (if splits exist, check splits)
  bool _expenseAffectsCategory(dynamic e, String category) {
    // e is expected to be Expense model; allow null-safety
    try {
      if (e.splits != null && e.splits!.isNotEmpty) {
        return e.splits!.containsKey(category);
      }
      return e.category == category;
    } catch (_) {
      return false;
    }
  }

  /// Shows a dialog to edit the limit.
  /// Returns the entered limit in the currently selected currency (or null if cancelled).
  Future<double?> _showEditLimitDialog(
      BuildContext context, String category, double currentLimit, String currency) {
    final controller = TextEditingController(text: currentLimit.toStringAsFixed(2));
    return showDialog<double>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF12291D),
          title: Text("Edit Limit — $category", style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Limit ($currency)",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF0B1C14),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              const Text("Enter the new monthly limit for this category.",
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                final val = double.tryParse(text.replaceAll(',', ''));
                if (val == null) {
                  // show local validation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter a valid number")),
                  );
                  return;
                }
                Navigator.of(ctx).pop(val);
              },
              child: const Text("Save", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
