import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String category;
  final double spent;
  final String currency;

  const CategoryCard({
    super.key,
    required this.category,
    required this.spent,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12291D),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            "${spent.toStringAsFixed(2)} $currency",
            style: const TextStyle(color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }
}
