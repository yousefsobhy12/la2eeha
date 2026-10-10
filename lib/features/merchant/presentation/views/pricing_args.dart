class PricingArgs {
  final int placeId;
  final String placeName;
  final int categoryId;
  final String? subCategory;

  const PricingArgs({
    required this.placeId,
    required this.placeName,
    required this.categoryId,
    this.subCategory,
  });
}
