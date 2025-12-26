import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/computed/date_range_provider.dart';
import '../../providers/computed/compare_previous_month_provider.dart';

class ComparePreviousMonthSwitch extends ConsumerWidget {
  const ComparePreviousMonthSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparePrev = ref.watch(comparePreviousMonthProvider);
    final dateRange = ref.watch(dateRangeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF10231A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3325),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.compare_arrows_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Compare to previous month',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: comparePrev,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.greenAccent,
            onChanged: (val) {
              // 1) toggle on/off
              ref.read(comparePreviousMonthProvider.notifier).state = val;

              // 2) optional: shift the date range one month back/forward
              final current = ref.read(dateRangeProvider);
              if (current == null) return;

              final start = current.start;

              final prevStart = DateTime(start.year, start.month - 1, 1);
              final prevEnd = DateTime(start.year, start.month, 0);

              final nextStart = DateTime(start.year, start.month + 1, 1);
              final nextEnd = DateTime(start.year, start.month + 2, 0);

              ref.read(dateRangeProvider.notifier).state =
                  val
                      ? DateTimeRange(start: prevStart, end: prevEnd)
                      : DateTimeRange(start: nextStart, end: nextEnd);
            },
          ),
        ],
      ),
    );
  }
}
