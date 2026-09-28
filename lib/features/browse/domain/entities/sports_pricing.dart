class SportsPricing {
  final int id;
  final int placeId;
  final String
  startTime; // raw "HH:mm:ss" from Supabase; formatted in widget layer
  final String endTime;
  final double price;
  final String? description;

  /// ترتيب العرض — بيفضل مُدار من جانب التاجر ومش بيتعدل يدويًا.
  final int sortOrder;

  const SportsPricing({
    required this.id,
    required this.placeId,
    required this.startTime,
    required this.endTime,
    required this.price,
    this.description,
    this.sortOrder = 0,
  });
}
