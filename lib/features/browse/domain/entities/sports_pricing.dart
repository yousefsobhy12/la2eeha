class SportsPricing {
  final int id;
  final int placeId;
  final String startTime;
  final String endTime;
  final double price;
  final String? description;

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
