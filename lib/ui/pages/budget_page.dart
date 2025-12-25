import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/budget_notifier.dart';
import '../../providers/expenses_notifier.dart';
import '../../providers/currency/selected_currency.dart';
import '../../providers/currency/currency_rates.dart';

import '../../core/currency/currency_converter.dart';
import '../../core/expense/expense_totals.dart';

import '../widgets/progress_bar.dart';

class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetNotifierProvider);
    final expenses = ref.watch(expensesNotifierProvider);

    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final rates = ref.watch(currencyRatesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Budgets",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Currency selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["USD", "EUR", "GBP", "JPY", "PHP"].map((c) {
                    return Padding(
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
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  children: budgets.entries.map((entry) {
                    final category = entry.key;

                    // 🔹 Budget limit (stored in PHP)
                    final limit = CurrencyConverter.convert(
                      entry.value.limit,
                      "PHP",
                      selectedCurrency,
                      rates,
                    );

                    // 🔹 Total spent for category (split-aware, base currency)
                    final spentBase = expenseTotalForCategoryInBaseCurrency(
                      expenses,
                      category,
                    );

                    final spent = CurrencyConverter.convert(
                      spentBase,
                      "PHP",
                      selectedCurrency,
                      rates,
                    );

                    final percent =
                        limit == 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);

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
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),

                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white70),
                                    onPressed: () async {
                                      final updated =
                                          await _editLimitDialog(
                                        context,
                                        category,
                                        limit,
                                        selectedCurrency,
                                      );

                                      if (updated != null) {
                                        final newLimitPHP =
                                            CurrencyConverter.convert(
                                          updated,
                                          selectedCurrency,
                                          "PHP",
                                          rates,
                                        );

                                        ref
                                            .read(budgetNotifierProvider
                                                .notifier)
                                            .updateLimit(
                                              category,
                                              newLimitPHP,
                                            );
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
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isOver ? "Over Budget" : "Safe",
                                      style: TextStyle(
                                        color: isOver
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          ProgressBar(
                            value: percent,
                            color: Colors.greenAccent,
                          ),

                          const SizedBox(height: 6),

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

  Future<double?> _editLimitDialog(
    BuildContext context,
    String category,
    double current,
    String currency,
  ) {
    final controller =
        TextEditingController(text: current.toStringAsFixed(2));

    return showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF12291D),
        title: Text(
          "Edit Limit — $category",
          style: const TextStyle(color: Colors.white),
        ),
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
            child: const Text("Cancel",
                style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Enter a valid number")),
                );
                return;
              }
              Navigator.pop(ctx, val);
            },
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
