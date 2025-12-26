import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/currency/selected_currency.dart';

class CurrencySelector extends ConsumerWidget {
  const CurrencySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrency = ref.watch(selectedCurrencyProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const ["USD", "EUR", "GBP", "JPY", "PHP"].map((c) {
          return _CurrencyChip(code: c);
        }).toList(),
      ),
    );
  }
}

class _CurrencyChip extends ConsumerWidget {
  final String code;

  const _CurrencyChip({required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final isSelected = selectedCurrency == code;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => ref
            .read(selectedCurrencyProvider.notifier)
            .state = code,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.greenAccent
                : const Color(0xFF1A2E23),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            code,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
