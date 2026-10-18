class Branch {
  final int id;
  final int placeId;
  final String address;
  final String? googleMapsLink;
  final String? phone;
  final String? title;
  final String? description;

  const Branch({
    required this.id,
    required this.placeId,
    required this.address,
    this.googleMapsLink,
    this.phone,
    this.title,
    this.description,
  });
}
