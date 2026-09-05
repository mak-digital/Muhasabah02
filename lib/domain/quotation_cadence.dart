enum QuotationCadence { weekly, daily, hidden }

extension QuotationCadenceX on QuotationCadence {
  String get id => name;

  String get label => switch (this) {
    QuotationCadence.weekly => 'Weekly',
    QuotationCadence.daily => 'Daily',
    QuotationCadence.hidden => 'Hidden',
  };

  static QuotationCadence fromId(String? id) {
    return QuotationCadence.values.firstWhere(
      (item) => item.name == id,
      orElse: () => QuotationCadence.weekly,
    );
  }
}
