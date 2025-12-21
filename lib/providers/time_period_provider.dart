// lib/providers/time_period_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/time_period.dart';

/// Holds the currently selected analytics period (weekly / monthly / yearly).
///
/// Default is [TimePeriod.monthly].
final timePeriodProvider = StateProvider<TimePeriod>((ref) {
  return TimePeriod.monthly;
});
