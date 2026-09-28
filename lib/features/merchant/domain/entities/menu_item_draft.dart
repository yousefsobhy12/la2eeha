// lib/features/merchant/domain/entities/menu_item_draft.dart
//
// كيان write-only لعنصر منيو — شبه PlaceDraft، منفصل عن MenuItem بتاع الـ
// browse عشان الـ read entity يفضل نضيف. localKey بيُستخدم لعمليات القائمة
// المحلية (تعديل/حذف قبل الحفظ)، و id بيبقى null لو العنصر لسه ماتحفظش.

class MenuItemDraft {
  final String localKey;
  final int? id;
  final String name;
  final double price;

  /// وصف اختياري (أقصى 150 حرف — الـ check موجود على الـ DB).
  final String? description;

  /// بيتحسب وقت الحفظ من موضع العنصر في القائمة المحلية (index) —
  /// عمره ما بيتعدل يدويًا.
  final int sortOrder;

  const MenuItemDraft({
    required this.localKey,
    this.id,
    required this.name,
    required this.price,
    this.description,
    required this.sortOrder,
  });
}
