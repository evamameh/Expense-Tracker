enum TimePeriod {
  weekly,
  monthly,
  yearly,
}

extension TimePeriodX on TimePeriod {
  String get label {
    switch (this) {
      case TimePeriod.weekly:
        return 'Weekly';
      case TimePeriod.monthly:
        return 'Monthly';
      case TimePeriod.yearly:
        return 'Yearly';
    }
  }
  String get code {
    switch (this) {
      case TimePeriod.weekly:
        return 'week';
      case TimePeriod.monthly:
        return 'month';
      case TimePeriod.yearly:
        return 'year';
    }
  }
}
