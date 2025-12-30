import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/expense.dart';
import '../../providers/expenses_notifier.dart';
import '../../providers/budget_notifier.dart';

import '../../providers/currency/selected_currency.dart';
import '../../providers/currency/currency_rates.dart';
import '../../core/currency/currency_converter.dart';
import '../../core/expense/expense_totals.dart';

const Color bgMain = Color(0xFF0B1C14);
const Color bgCard = Color(0xFF12291D);
const Color bgAccent = Color(0xFF1A2E23);
const Color borderColor = Color(0xFF2E4A3A);
const Color primaryGreen = Color(0xFF6EF2B5);

class EditExpensePage extends ConsumerStatefulWidget {
  final Expense expense;

  const EditExpensePage({super.key, required this.expense});

  @override
  ConsumerState<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends ConsumerState<EditExpensePage> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCurrency = '';
  late DateTime _selectedDate;
  late String _selectedCategory;
  late bool _hasReceipt;
  late bool _isRecurring;

  Map<String, double> _editableSplits = {};
  bool get _hasSplits => _editableSplits.isNotEmpty;

  @override
  void initState() {
    super.initState();

    _selectedCurrency = widget.expense.currency;
    _selectedDate = widget.expense.date;
    _selectedCategory = widget.expense.category;
    _hasReceipt = widget.expense.hasReceipt;
    _isRecurring = widget.expense.isRecurring;
    _noteController.text = widget.expense.note ?? '';

    _editableSplits =
        Map<String, double>.from(widget.expense.splits ?? {});

    if (_hasSplits) {
      final total =
          _editableSplits.values.fold(0.0, (a, b) => a + b);
      _amountController.text = total.toStringAsFixed(2);
    } else {
      _amountController.text =
          widget.expense.amount.toStringAsFixed(2);
    }
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

  void _recalculateTotal() {
    final total =
        _editableSplits.values.fold(0.0, (a, b) => a + b);
    _amountController.text = total.toStringAsFixed(2);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.expense.copyWith(
      amount: double.parse(_amountController.text),
      currency: _selectedCurrency,
      category: _hasSplits
    ? (_editableSplits.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)))
        .first.key: _selectedCategory,
      date: _selectedDate,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      hasReceipt: _hasReceipt,
      isRecurring: _isRecurring,
      splits: _hasSplits ? _editableSplits : null,
    );

    ref.read(expensesNotifierProvider.notifier)
        .updateExpense(updated);

    Navigator.pop(context);
  }

  void _delete() {
    ref.read(expensesNotifierProvider.notifier)
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
            "Other",
          ];

    return Scaffold(
      backgroundColor: bgMain,
      appBar: AppBar(
        backgroundColor: bgMain,
        elevation: 0,
        title: const Text("Edit Expense"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      ["USD", "EUR", "GBP", "JPY", "PHP"].map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCurrency = c;

                            final baseAmount =
                                expenseTotalInBaseCurrency(
                                    widget.expense);

                            final converted =
                                CurrencyConverter.convert(
                              baseAmount,
                              widget.expense.currency,
                              c,
                              rates,
                            );

                            _amountController.text =
                                converted.toStringAsFixed(2);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedCurrency == c
                                ? primaryGreen
                                : bgAccent,
                            borderRadius:
                                BorderRadius.circular(30),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                enabled: !_hasSplits,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  color: _hasSplits ? Colors.white70 : Colors.white,
                ),
                decoration: _input(
                  label: _hasSplits
                      ? "Total Amount (Auto-calculated)"
                      : "Amount",
                  locked: _hasSplits,
                ),
                validator: (v) =>
                    v == null || double.tryParse(v) == null
                        ? "Enter valid amount"
                        : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDate,
                child: _pill(
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        "${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}",
                        style: const TextStyle(
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!_hasSplits)
                GestureDetector(
                  onTap: () async {
                    final selected =
                        await showModalBottomSheet<String>(
                      context: context,
                      backgroundColor: bgMain,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(
                                top: Radius.circular(20)),
                      ),
                      builder: (_) => ListView(
                        padding: const EdgeInsets.all(16),
                        children: categories
                            .map(
                              (c) => ListTile(
                                title: Text(c,
                                    style: const TextStyle(
                                        color: Colors.white)),
                                onTap: () =>
                                    Navigator.pop(context, c),
                              ),
                            )
                            .toList(),
                      ),
                    );

                    if (selected != null) {
                      setState(
                          () => _selectedCategory = selected);
                    }
                  },
                  child: _pill(
                    Row(
                      children: [
                        Expanded(
                          child: Text(_selectedCategory,
                              style: const TextStyle(
                                  color: Colors.white)),
                        ),
                        const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                      ],
                    ),
                  ),
                ),
              if (!_hasSplits) const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration:
                    _input(label: "Note (optional)"),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _hasReceipt,
                onChanged: (v) =>
                    setState(() => _hasReceipt = v),
                title: const Text("Has Receipt?",
                    style:
                        TextStyle(color: Colors.white)),
                activeThumbColor: primaryGreen,
              ),
              SwitchListTile(
                value: _isRecurring,
                onChanged: (v) =>
                    setState(() => _isRecurring = v),
                title: const Text("Recurring Expense",
                    style:
                        TextStyle(color: Colors.white)),
                activeThumbColor: primaryGreen,
              ),
              const SizedBox(height: 20),
              if (_hasSplits)
                _splitEditor(categories),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _save,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _delete,
                child: const Text(
                  "Delete Expense",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _splitEditor(List<String> categories) {
    final used = _editableSplits.keys.toSet();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Split Breakdown",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._editableSplits.entries.toList().map((entry) {
            final amountController =
                TextEditingController(
                    text: entry.value.toStringAsFixed(2));

            return Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: entry.key,
                    dropdownColor: bgCard,
                    items: categories.map((c) {
                      final disabled =
                          used.contains(c) &&
                              c != entry.key;
                      return DropdownMenuItem(
                        value: c,
                        enabled: !disabled,
                        child: Text(
                          c,
                          style: TextStyle(
                            color: disabled
                                ? Colors.white38
                                : Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newCat) {
                      if (newCat == null ||
                          newCat == entry.key) return;
                      setState(() {
                        final val =
                            _editableSplits.remove(entry.key)!;
                        _editableSplits[newCat] = val;
                      });
                    },
                    decoration: _splitInput(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                    style:
                        const TextStyle(color: Colors.white),
                    decoration: _splitInput(),
                    onChanged: (v) {
                      final n = double.tryParse(v);
                      if (n == null) return;
                      setState(() {
                        _editableSplits[entry.key] = n;
                        _recalculateTotal();
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete,
                      color: Colors.redAccent),
                  onPressed: () {
                    setState(() {
                      _editableSplits.remove(entry.key);
                      _recalculateTotal();
                    });
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  InputDecoration _input(
      {required String label, bool locked = false}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: bgCard,
      suffixIcon:
          locked
              ? const Icon(Icons.lock,
                  color: Colors.white38)
              : null,
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: primaryGreen),
      ),
    );
  }

  InputDecoration _splitInput() {
    return InputDecoration(
      filled: true,
      fillColor: bgAccent,
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: primaryGreen),
      ),
    );
  }

  Widget _pill(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius:
            BorderRadius.circular(16),
        border:
            Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}
