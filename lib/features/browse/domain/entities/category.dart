// lib/features/browse/domain/entities/category.dart
//
// الـ entity النضيف - ده اللي باقي التطبيق (الشاشات، الـ Cubits) بيتعامل معاه.
// مفيهوش أي علاقة بـ Supabase أو JSON خالص.

class Category {
  final int id;
  final String nameAr; // زي "محلات" أو "رياضة"
  final String nameEn; // زي "Shops" أو "Sports"
  final String icon; // مفتاح نصي زي "restaurant" أو "medical"
  // ده بيتحول لـ Flutter Material Icon فعلي في core/constants/

  const Category({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.icon,
  });
}