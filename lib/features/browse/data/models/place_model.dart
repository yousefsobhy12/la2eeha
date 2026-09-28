import '../../domain/entities/place.dart';

class PlaceModel extends Place {
  const PlaceModel({
    required super.id,
    required super.categoryId,
    super.areaId,
    super.subCategory,
    required super.name,
    required super.phone,
    super.whatsapp,
    required super.address,
    super.googleMapsUrl,
    super.workingHours,
    required super.viewCount,
    required super.isFeatured,
    super.imageUrl,
    super.description,
    super.openTime,
    super.closeTime,
    super.closedDays,
    super.is24Hours,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      areaId: json['area_id'] as int?,
      subCategory: json['sub_category'] as String?,
      name: json['name'] as String,
      phone: json['phone'] as String,
      whatsapp: json['whatsapp'] as String?,
      address: json['address'] as String,
      googleMapsUrl: json['google_maps_url'] as String?,
      workingHours: json['working_hours'] as String?,
      viewCount: json['view_count'] as int,
      isFeatured: json['is_featured'] as bool,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      openTime: json['open_time'] as String?,
      closeTime: json['close_time'] as String?,
      closedDays:
          (json['closed_days'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      is24Hours: json['is_24_hours'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'area_id': areaId,
      'sub_category': subCategory,
      'name': name,
      'phone': phone,
      'whatsapp': whatsapp,
      'address': address,
      'google_maps_url': googleMapsUrl,
      'working_hours': workingHours,
      'view_count': viewCount,
      'is_featured': isFeatured,
      'image_url': imageUrl,
      'description': description,
      'open_time': openTime,
      'close_time': closeTime,
      'closed_days': closedDays,
      'is_24_hours': is24Hours,
    };
  }
}
