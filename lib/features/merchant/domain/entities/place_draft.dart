class PlaceDraft {
  final String name;
  final int categoryId;
  final String? subCategory;
  final int? areaId;
  final String? pendingAreaName;
  final String address;
  final String phone;
  final String? whatsapp;
  final String? googleMapsUrl;
  final String? description;
  final String? openTime;
  final String? closeTime;
  final List<int> closedDays;

  final bool is24Hours;

  final bool isDelivery;

  const PlaceDraft({
    required this.name,
    required this.categoryId,
    this.subCategory,
    this.areaId,
    this.pendingAreaName,
    required this.address,
    required this.phone,
    this.whatsapp,
    this.googleMapsUrl,
    this.description,
    this.openTime,
    this.closeTime,
    this.closedDays = const [],
    this.is24Hours = false,
    this.isDelivery = false,
  });
}
