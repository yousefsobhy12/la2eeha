import '../../domain/entities/sports_pricing.dart';

class SportsPricingModel extends SportsPricing {
  const SportsPricingModel({
    required super.id,
    required super.placeId,
    required super.startTime,
    required super.endTime,
    required super.price,
    super.description,
    super.sortOrder,
  });

  factory SportsPricingModel.fromJson(Map<String, dynamic> json) {
    return SportsPricingModel(
      id: json['id'] as int,
      placeId: json['place_id'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'place_id': placeId,
      'start_time': startTime,
      'end_time': endTime,
      'price': price,
      'description': description,
      'sort_order': sortOrder,
    };
  }
}
