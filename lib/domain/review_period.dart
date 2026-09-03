enum ReviewPeriod { days7, days30, days90 }

extension ReviewPeriodX on ReviewPeriod {
  int get days => switch (this) {
    ReviewPeriod.days7 => 7,
    ReviewPeriod.days30 => 30,
    ReviewPeriod.days90 => 90,
  };

  String get shortLabel => switch (this) {
    ReviewPeriod.days7 => '7 days',
    ReviewPeriod.days30 => '30 days',
    ReviewPeriod.days90 => '90 days',
  };
}
