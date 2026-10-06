import '../../domain/entities/area.dart';

class AreaModel extends Area {
  const AreaModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'] as int,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
    );
  }
}
