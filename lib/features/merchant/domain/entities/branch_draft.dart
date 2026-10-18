class BranchDraft {
  final String address;
  final String? googleMapsLink;
  final String? phone;
  final String? title;
  final String? description;

  const BranchDraft({
    required this.address,
    this.googleMapsLink,
    this.phone,
    this.title,
    this.description,
  });
}
