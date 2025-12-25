import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/time_period.dart';

final timePeriodProvider = StateProvider<TimePeriod>((ref) {
  return TimePeriod.monthly;
});
