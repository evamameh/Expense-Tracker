import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/expense.dart';
import '../../providers/expenses_notifier.dart';
import '../../providers/currency/selected_currency.dart';
import '../../providers/budget_notifier.dart';
import '../../providers/recurring_notifier.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({super.key});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;

  bool _isRecurring = false;
  int _recurrenceMonths = 1;

  bool _hasReceipt = false;

  // SPLITS
  bool _useSplits = false;
  final List<_SplitRow> _splitRows = [];

  @override
  void initState() {
    super.initState();
    _splitRows.add(_SplitRow(category: "Groceries"));
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

  void _addSplitRow() {
    setState(() => _splitRows.add(_SplitRow(category: "Other")));
  }

  void _removeSplitRow(int index) {
    if (_splitRows.length > 1) {
      setState(() => _splitRows.removeAt(index));
    }
  }

  // SAVE EXPENSE ========================================================
  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final currency = ref.read(selectedCurrencyProvider);
    final category = _selectedCategory ?? "Other";

    double? amount =
        double.tryParse(_amountController.text.replaceAll(",", ""));

    Map<String, double>? splits;

    if (_useSplits) {
      splits = {};

      for (final row in _splitRows) {
        final double? v = double.tryParse(row.controller.text.trim());
        if (v != null && v > 0) splits[row.category] = v;
      }

      if (splits.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter at least one split.")),
        );
        return;
      }

      amount ??= splits.values.fold<double>(0, (a, b) => a + b);
    } else {
      if (amount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter a valid amount")),
        );
        return;
      }
    }

    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: category,
      date: _selectedDate,
      currency: currency,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      hasReceipt: _hasReceipt,
      isRecurring: _isRecurring,
      splits: splits,
      recurrenceIntervalMonths: _recurrenceMonths,
    );

    // save the expense
    ref.read(expensesNotifierProvider.notifier).addExpense(expense);

    // save recurring template + next-month auto creation
    if (_isRecurring) {
      ref
          .read(recurringNotifierProvider.notifier)
          .createFromExpense(expense, intervalMonths: _recurrenceMonths);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetNotifierProvider);
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

    _selectedCategory ??= categories.first;

    final selectedCurrency = ref.watch(selectedCurrencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
        backgroundColor: const Color(0xFF12291D),
      ),
      backgroundColor: const Color(0xFF0B1C14),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // CURRENCY SELECTOR
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final c in ["USD", "EUR", "GBP", "JPY", "PHP"])
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => ref
                              .read(selectedCurrencyProvider.notifier)
                              .state = c,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
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
                      )
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // AMOUNT
              if (!_useSplits)
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: _input("Amount"),
                  validator: (v) {
                    if (!_useSplits &&
                        (v == null || double.tryParse(v) == null)) {
                      return "Enter a valid number";
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 12),

              // SPLIT TOGGLE
              CheckboxListTile(
                value: _useSplits,
                onChanged: (v) => setState(() => _useSplits = v ?? false),
                title: const Text(
                  "Split between categories",
                  style: TextStyle(color: Colors.white),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.greenAccent,
              ),

              // SPLITS UI
              if (_useSplits)
                Column(
                  children: [
                    for (int i = 0; i < _splitRows.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: _splitRows[i].category,
                                dropdownColor: const Color(0xFF12291D),
                                items: categories
                                    .map((c) =>
                                        DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white))))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _splitRows[i].category = v!),
                                decoration: _input("Category"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _splitRows[i].controller,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                style: const TextStyle(color: Colors.white),
                                decoration: _input("Amount"),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeSplitRow(i),
                              icon: const Icon(Icons.delete,
                                  color: Colors.white54),
                            )
                          ],
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _addSplitRow,
                        icon: const Icon(Icons.add, color: Colors.greenAccent),
                        label: const Text(
                          "Add split",
                          style: TextStyle(color: Colors.greenAccent),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // CATEGORY + DATE
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: categories
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      dropdownColor: const Color(0xFF12291D),
                      onChanged: (v) => setState(() => _selectedCategory = v),
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

              const SizedBox(height: 12),

              // NOTE
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: _input("Note (optional)"),
              ),

              const SizedBox(height: 12),

              // RECEIPT TOGGLE
              SwitchListTile(
                value: _hasReceipt,
                onChanged: (v) => setState(() => _hasReceipt = v),
                title: const Text("Has Receipt?",
                    style: TextStyle(color: Colors.white)),
                activeThumbColor: Colors.greenAccent,
                activeTrackColor:
                    Colors.greenAccent.withValues(alpha: 0.4),
              ),

              // RECURRING
              SwitchListTile(
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v),
                title: const Text("Recurring Expense",
                    style: TextStyle(color: Colors.white)),
                activeThumbColor: Colors.greenAccent,
                activeTrackColor:
                    Colors.greenAccent.withValues(alpha: 0.4),
              ),

              if (_isRecurring)
                Row(
                  children: [
                    const Text("Every:",
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _recurrenceMonths,
                      items: [1, 2, 3, 6, 12]
                          .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(
                                "$m month${m > 1 ? 's' : ''}",
                                style: const TextStyle(color: Colors.white),
                              )))
                          .toList(),
                      dropdownColor: const Color(0xFF12291D),
                      onChanged: (v) =>
                          setState(() => _recurrenceMonths = v ?? 1),
                    )
                  ],
                ),

              const SizedBox(height: 20),

              // SAVE BUTTON
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Save Expense",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // INPUT DECORATION ===================================================
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

// SPLIT ROW CLASS ======================================================
class _SplitRow {
  String category;
  final TextEditingController controller = TextEditingController();

  _SplitRow({required this.category});
}
