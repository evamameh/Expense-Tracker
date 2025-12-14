// budget_page.dart

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

    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final rates = ref.watch(currencyRatesProvider);

    // Convert ANY currency to PHP
    double toPHP(double amount, String from) {
      final r = (rates[from] ?? 1.0).toDouble();
      return amount * r;
    }

    // Convert PHP → selected currency
    double fromPHP(double amountPHP, String to) {
      final r = (rates[to] ?? 1.0).toDouble();
      return amountPHP / r;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              const Text(
                "Budgets",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // CURRENCY SELECTOR
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
                    final limitPHP = entry.value.limit; // STORED IN PHP

                    // Calculate SPENT in PHP
                    final spentPHP = expenses
                        .where((e) => _affectsCategory(e, category))
                        .fold<double>(0.0, (sum, e) {
                      if (e.splits != null && e.splits!.containsKey(category)) {
                        return sum +
                            (e.splits![category] ?? 0.0) *
                                (rates[e.currency] ?? 1.0);
                      }
                      return sum + toPHP(e.amount, e.currency);
                    });

                    // Convert PHP → user selected currency
                    final spent = fromPHP(spentPHP, selectedCurrency);
                    final limit = fromPHP(limitPHP, selectedCurrency);

                    // percent MUST BE DOUBLE
                    final percent = (limit == 0)
                        ? 0.0
                        : (spent / limit).clamp(0.0, 1.0);

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
                          // TOP ROW: CATEGORY + EDIT + STATUS
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
                                  // EDIT BUTTON
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white70),
                                    onPressed: () async {
                                      final updated = await _editLimitDialog(
                                          context,
                                          category,
                                          limit,
                                          selectedCurrency);

                                      if (updated != null) {
                                        final newLimitPHP = updated *
                                            (rates[selectedCurrency] ?? 1.0);

                                        ref
                                            .read(budgetNotifierProvider.notifier)
                                            .updateLimit(
                                                category, newLimitPHP);
                                      }
                                    },
                                  ),

                                  // STATUS BADGE
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
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // PROGRESS BAR
                          ProgressBar(
                            value: percent, // FIXED: ALWAYS DOUBLE
                            color: Colors.greenAccent,
                          ),

                          const SizedBox(height: 6),

                          // DETAILS
                          Text(
                            "${spent.toStringAsFixed(2)} $selectedCurrency spent",
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            "Limit: ${limit.toStringAsFixed(2)} $selectedCurrency",
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13),
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

  bool _affectsCategory(e, String category) {
    if (e.splits != null && e.splits!.containsKey(category)) return true;
    return e.category == category;
  }

  // Dialog returns NEW LIMIT in selectedCurrency
  Future<double?> _editLimitDialog(BuildContext context, String category,
      double current, String currency) {
    final controller =
        TextEditingController(text: current.toStringAsFixed(2));

    return showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF12291D),
        title: Text("Edit Limit — $category",
            style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Limit ($currency)",
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF0B1C14),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter a valid number")));
                return;
              }
              Navigator.pop(ctx, val);
            },
            child: const Text("Save",
                style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
