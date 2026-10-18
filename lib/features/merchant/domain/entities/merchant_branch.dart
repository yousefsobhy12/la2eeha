class MerchantBranch {
  final int id;
  final String address;
  final String? googleMapsLink;
  final String? phone;
  final String? title;
  final String? description;
  final bool isApproved;

  const MerchantBranch({
    required this.id,
    required this.address,
    required this.isApproved,
    this.googleMapsLink,
    this.phone,
    this.title,
    this.description,
  });
}
