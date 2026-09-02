class Place {
  final int id;
  final int categoryId;
  final int? areaId;
  final String? subCategory;
  final String name;
  final String phone;
  final String? whatsapp;
  final String address;
  final String? googleMapsUrl;
  final String? workingHours;
  final int viewCount;
  final bool isFeatured;
  final String? imageUrl;
  final String? description;
  final String? openTime;
  final String? closeTime;
  final List<int> closedDays;

  const Place({
    required this.id,
    required this.categoryId,
    this.areaId,
    this.subCategory,
    required this.name,
    required this.phone,
    this.whatsapp,
    required this.address,
    this.googleMapsUrl,
    this.workingHours,
    required this.viewCount,
    required this.isFeatured,
    this.imageUrl,
    this.description,
    this.openTime,
    this.closeTime,
    this.closedDays = const [],
  });
}
