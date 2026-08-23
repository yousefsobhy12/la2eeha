// lib/features/browse/domain/entities/area.dart
//
// 🆕 ملف جديد — الـ Area entity ملهاش وجود قبل كده في الـ core data layer
// (كان بس فيه Category و Place). محتاجينها عشان نعرض اسم المنطقة على كروت الأماكن.

class Area {
  final int id;
  final String nameAr;
  final String nameEn;

  const Area({required this.id, required this.nameAr, required this.nameEn});
}