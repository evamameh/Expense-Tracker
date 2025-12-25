import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/time_period.dart';

/// Default is [TimePeriod.monthly].
final timePeriodProvider = StateProvider<TimePeriod>((ref) {
  return TimePeriod.monthly;
});
