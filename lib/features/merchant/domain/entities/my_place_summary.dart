class MyPlaceSummary {
  final int id;
  final String name;
  final int categoryId;
  final String? subCategory;
  final bool isApproved;

  const MyPlaceSummary({
    required this.id,
    required this.name,
    required this.categoryId,
    this.subCategory,
    required this.isApproved,
  });
}
