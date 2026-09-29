// lib/features/browse/data/models/promotion_model.dart
//
// Model بيمثّل صف في جدول promotions. place_id و slot بيتقروا كـ int
// (Supabase بيرجّعهم كـ num)، و image_url بيتعامل معاه كـ string فاضي
// لو مفيش صورة عشان الـ UI يقدر يعرض بديل من غير null checks.

import '../../domain/entities/promotion.dart';

class PromotionModel extends Promotion {
  const PromotionModel({
    required super.placeId,
    required super.slot,
    required super.imageUrl,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      placeId: (json['place_id'] as num).toInt(),
      slot: (json['slot'] as num).toInt(),
      imageUrl: json['image_url'] as String? ?? '',
    );
  }
}
