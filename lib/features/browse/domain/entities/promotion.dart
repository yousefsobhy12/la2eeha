// lib/features/browse/domain/entities/promotion.dart
//
// كيان العرض الترويجي — صف واحد في جدول promotions يعني مكان واحد بيتروى
// عنه في الـ carousel بتاع الصفحة الرئيسية.
//
// ⚠️ مفيش أي فلترة بالتاريخ أو الحالة هنا عن قصد: سياسات الـ RLS في
// Supabase بترجّع الصفوف الحيّة بس، فمفيش داعي نكرّر نفس الشرط في الداتا layer.

class Promotion {
  final int placeId;
  final int slot;
  final String imageUrl;

  const Promotion({
    required this.placeId,
    required this.slot,
    required this.imageUrl,
  });
}
