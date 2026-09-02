class SportsPricing {
  final int id;
  final int placeId;
  final String startTime; // raw "HH:mm:ss" from Supabase; formatted in widget layer
  final String endTime;
  final double price;

  const SportsPricing({
    required this.id,
    required this.placeId,
    required this.startTime,
    required this.endTime,
    required this.price,
  });
}
