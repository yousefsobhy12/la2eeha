import '../../domain/entities/branch.dart';

class BranchModel extends Branch {
  const BranchModel({
    required super.id,
    required super.placeId,
    required super.address,
    super.googleMapsLink,
    super.phone,
    super.title,
    super.description,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    final googleMapsLink = json['google_maps_link'] as String?;
    final phone = json['phone'] as String?;
    final title = json['title'] as String?;
    final description = json['description'] as String?;
    return BranchModel(
      id: json['id'] as int,
      placeId: json['place_id'] as int,
      address: json['address'] as String,
      googleMapsLink: (googleMapsLink == null || googleMapsLink.isEmpty)
          ? null
          : googleMapsLink,
      phone: (phone == null || phone.isEmpty) ? null : phone,
      title: (title == null || title.trim().isEmpty) ? null : title.trim(),
      description: (description == null || description.trim().isEmpty)
          ? null
          : description.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'place_id': placeId,
      'address': address,
      'google_maps_link': googleMapsLink,
      'phone': phone,
      'title': title,
      'description': description,
    };
  }
}
