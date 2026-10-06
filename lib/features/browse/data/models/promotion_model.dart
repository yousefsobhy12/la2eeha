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
