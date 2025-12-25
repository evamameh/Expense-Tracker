import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/expense.dart';
import '../../providers/expenses_notifier.dart';
import '../../providers/budget_notifier.dart';
import '../../providers/currency/currency_rates.dart';

import '../../core/currency/currency_converter.dart';
import '../../core/expense/expense_totals.dart';

class EditExpensePage extends ConsumerStatefulWidget {
  final Expense expense;

  const EditExpensePage({super.key, required this.expense});

  @override
  ConsumerState<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends ConsumerState<EditExpensePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late DateTime _selectedDate;
  late String _selectedCategory;
  late String _selectedCurrency;

  late bool _hasReceipt;
  late bool _isRecurring;

  @override
  void initState() {
    super.initState();

    final baseAmount = expenseTotalInBaseCurrency(widget.expense);

    _amountController =
        TextEditingController(text: baseAmount.toStringAsFixed(2));
    _noteController =
        TextEditingController(text: widget.expense.note ?? '');

    _selectedDate = widget.expense.date;
    _selectedCategory = widget.expense.category;
    _selectedCurrency = widget.expense.currency;

    _hasReceipt = widget.expense.hasReceipt;
    _isRecurring = widget.expense.isRecurring;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _onCurrencyChange(
    String newCurrency,
    Map<String, double> rates,
  ) {
    final oldAmount = double.tryParse(_amountController.text) ?? 0.0;

    final converted = CurrencyConverter.convert(
      oldAmount,
      _selectedCurrency,
      newCurrency,
      rates,
    );

    setState(() {
      _selectedCurrency = newCurrency;
      _amountController.text = converted.toStringAsFixed(2);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    final updated = widget.expense.copyWith(
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      currency: _selectedCurrency,
      hasReceipt: _hasReceipt,
      isRecurring: _isRecurring,

      // 🔒 Preserve splits
      splits: widget.expense.splits,
      recurrenceIntervalMonths:
          widget.expense.recurrenceIntervalMonths,
    );

    ref.read(expensesNotifierProvider.notifier).updateExpense(updated);
    Navigator.pop(context);
  }

  void _delete() {
    ref
        .read(expensesNotifierProvider.notifier)
        .deleteExpense(widget.expense.id);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetNotifierProvider);
    final rates = ref.watch(currencyRatesProvider);

    final categories = budgets.keys.isNotEmpty
        ? budgets.keys.toList()
        : [
            "Groceries",
            "Transport",
            "Dining",
            "Shopping",
            "Bills",
            "Fun",
            "Health",
            "Subscriptions",
            "Other"
          ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C14),
      appBar: AppBar(
        title: const Text("Edit Expense"),
        backgroundColor: const Color(0xFF12291D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 🔹 Currency selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["USD", "EUR", "GBP", "JPY", "PHP"].map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => _onCurrencyChange(c, rates),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedCurrency == c
                                ? Colors.greenAccent
                                : const Color(0xFF1A2E23),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            c,
                            style: TextStyle(
                              color: _selectedCurrency == c
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

              // 🔹 Amount
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: _input("Amount"),
                validator: (v) =>
                    v == null || double.tryParse(v) == null
                        ? "Enter valid amount"
                        : null,
              ),

              const SizedBox(height: 16),

              // 🔹 Category + Date
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      dropdownColor: const Color(0xFF12291D),
                      items: categories
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  style:
                                      const TextStyle(color: Colors.white),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedCategory = v!),
                      decoration: _input("Category"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                        "${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A2E23)),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 🔹 Note
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: _input("Note (optional)"),
              ),

              const SizedBox(height: 16),

              SwitchListTile(
                value: _hasReceipt,
                onChanged: (v) => setState(() => _hasReceipt = v),
                title: const Text("Has Receipt?",
                    style: TextStyle(color: Colors.white)),
                activeThumbColor: Colors.greenAccent,
              ),

              SwitchListTile(
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v),
                title: const Text("Recurring Expense",
                    style: TextStyle(color: Colors.white)),
                 activeThumbColor: Colors.greenAccent,
              ),

              // 🔒 Split Indicator (READ-ONLY)
              _splitIndicator(widget.expense, rates),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Save Changes",
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _delete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Delete Expense",
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 READ-ONLY SPLIT INDICATOR
  Widget _splitIndicator(Expense expense, Map<String, double> rates) {
    if (expense.splits == null || expense.splits!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12291D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.call_split, color: Colors.greenAccent, size: 20),
              SizedBox(width: 8),
              Text(
                "Split Breakdown",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Icon(Icons.lock, color: Colors.white38, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          ...expense.splits!.entries.map((e) {
            final converted = CurrencyConverter.convert(
              e.value,
              expense.currency,
              _selectedCurrency,
              rates,
            );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key,
                      style:
                          const TextStyle(color: Colors.white70)),
                  Text(
                    "${converted.toStringAsFixed(2)} $_selectedCurrency",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          const Text(
            "Splits are read-only. Edit from Add Expense.",
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF12291D),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
