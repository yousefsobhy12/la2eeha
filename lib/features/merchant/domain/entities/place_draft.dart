// lib/features/merchant/domain/entities/place_draft.dart
//
// الـ PlaceDraft ده كيان write-only للتاجر — بيحمل كل البيانات اللي بيبعتهم
// التاجر وهو بيضيف بيزنس جديد. متعمدين نخليه class منفصل عن الـ Place
// بتاع الـ browse عشان الـ read entity يفضل نضيف ومفيش عليه أي حاجة
// خاصة بالـ merchant.

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
  });
}