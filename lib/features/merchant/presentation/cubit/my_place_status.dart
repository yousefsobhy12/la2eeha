import '../../domain/entities/my_place_item.dart';

enum MyPlaceStatus { approved, pending, rejected }

extension MyPlaceItemStatus on MyPlaceItem {
  MyPlaceStatus get status {
    if (isApproved) return MyPlaceStatus.approved;
    final reason = rejectionReason?.trim();
    if (reason != null && reason.isNotEmpty) return MyPlaceStatus.rejected;
    return MyPlaceStatus.pending;
  }
}
