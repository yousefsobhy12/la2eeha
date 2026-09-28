// lib/features/merchant/domain/entities/my_place_summary.dart
//
// ملخص خفيف لأحدث place للتاجر — بيستخدم في التوجيه (من "دخول التجار")
// عشان نعرف نودّيه على أنهي شاشة حسب الكاتيجوري وحالة الموافقة.

class MyPlaceSummary {
  final int id;
  final String name;
  final int categoryId;
  final String? subCategory;
  final bool isApproved;

  const MyPlaceSummary({
    required this.id,
    required this.name,
    required this.categoryId,
    this.subCategory,
    required this.isApproved,
  });
}
