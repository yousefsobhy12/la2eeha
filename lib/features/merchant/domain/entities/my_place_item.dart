import 'place_change_result.dart';

class MyPlaceItem {
  final int id;
  final String name;
  final int categoryId;
  final String? subCategory;
  final bool isApproved;
  final String? rejectionReason;
  final bool hasPendingChanges;
  final List<PlaceChangeResult> reviewResults;

  const MyPlaceItem({
    required this.id,
    required this.name,
    required this.categoryId,
    this.subCategory,
    required this.isApproved,
    this.rejectionReason,
    required this.hasPendingChanges,
    this.reviewResults = const [],
  });
}
