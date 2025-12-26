import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dateRangeProvider = StateProvider<DateTimeRange?>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0); 
  return DateTimeRange(start: start, end: end);
});
