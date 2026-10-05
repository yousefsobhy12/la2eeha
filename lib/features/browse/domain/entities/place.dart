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

  /// آخر مرة بيانات المكان اتحدّثت — بيتحسب منها "من امبارح"/"من شهر" إلخ.
  final DateTime? updatedAt;

  /// المكان شغال ٢٤ ساعة — مفيش open_time/close_time وفي الـ status دايماً
  /// شغال في أوقات الأسبوع غير أيام الإجازة.
  final bool is24Hours;

  /// المكان بيقدّم خدمة توصيل (للأقسام اللي بتسمح بيها بس — Restaurants/
  /// Shops/Pharmacy مثلاً).
  final bool isDelivery;

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
    this.updatedAt,
    this.is24Hours = false,
    this.isDelivery = false,
  });
}
