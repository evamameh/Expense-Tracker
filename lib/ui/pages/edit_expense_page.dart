// lib/ui/pages/edit_expense_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/expense.dart';
import '../../providers/expenses_notifier.dart';
import '../../providers/currency/selected_currency.dart';
import '../../providers/budget_notifier.dart';

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

  late bool _isRecurring;
  late bool _hasReceipt;

  @override
    void initState() {
      super.initState();

      _amountController =
          TextEditingController(text: widget.expense.amount.toString());
      _noteController = TextEditingController(text: widget.expense.note ?? "");

      _selectedDate = widget.expense.date;
      _selectedCategory = widget.expense.category;

      _isRecurring = widget.expense.isRecurring;
      _hasReceipt = widget.expense.hasReceipt;
      
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter valid amount")));
      return;
    }

    final selectedCurrency = ref.read(selectedCurrencyProvider);

    final updated = widget.expense.copyWith(
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      note: _noteController.text,
      currency: selectedCurrency,
      isRecurring: _isRecurring,
      hasReceipt: _hasReceipt,
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
    final categories = budgets.keys.toList().isNotEmpty
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

    final selectedCurrency = ref.watch(selectedCurrencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Expense"),
        backgroundColor: const Color(0xFF12291D),
      ),
      backgroundColor: const Color(0xFF0B1C14),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ---------- Currency Selector ----------
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
                      )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ---------- Amount ----------
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Amount",
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF12291D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Enter amount" : null,
              ),

              const SizedBox(height: 16),

              // ---------- Category + Date ----------
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: const Color(0xFF12291D),
                      items: categories
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF12291D),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                        "${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A2E23),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ---------- Note ----------
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Note (optional)",
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF12291D),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),

              const SizedBox(height: 16),

              // ---------- Toggles ----------
              SwitchListTile(
                value: _hasReceipt,
                onChanged: (v) => setState(() => _hasReceipt = v),
                title: const Text("Has Receipt?",
                    style: TextStyle(color: Colors.white)),
                activeColor: Colors.greenAccent,
              ),

              SwitchListTile(
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v),
                title: const Text("Recurring Expense",
                    style: TextStyle(color: Colors.white)),
                activeColor: Colors.greenAccent,
              ),

              const SizedBox(height: 30),

              // ---------- Save Button ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ---------- Delete Button ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _delete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Delete Expense",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
