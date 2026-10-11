class MyPlaceItem {
  final int id;
  final String name;
  final int categoryId;
  final String? subCategory;
  final bool isApproved;
  final String? rejectionReason;
  final bool hasPendingChanges;

  const MyPlaceItem({
    required this.id,
    required this.name,
    required this.categoryId,
    this.subCategory,
    required this.isApproved,
    this.rejectionReason,
    required this.hasPendingChanges,
  });
}
