import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/time_period.dart';
import '../../providers/time_period_provider.dart';

class TimePeriodSelector extends ConsumerWidget {
  const TimePeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(timePeriodProvider);
    final periodNotifier = ref.read(timePeriodProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF10231A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PeriodChip(
            label: 'Weekly',
            selected: period == TimePeriod.weekly,
            onTap: () => periodNotifier.state = TimePeriod.weekly,
          ),
          _PeriodChip(
            label: 'Monthly',
            selected: period == TimePeriod.monthly,
            onTap: () => periodNotifier.state = TimePeriod.monthly,
          ),
          _PeriodChip(
            label: 'Yearly',
            selected: period == TimePeriod.yearly,
            onTap: () => periodNotifier.state = TimePeriod.yearly,
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1ED760) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
