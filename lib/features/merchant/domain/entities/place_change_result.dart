enum PlaceChangeStatus { pending, approved, rejected }

class PlaceChangeResult {
  final String item;
  final PlaceChangeStatus status;
  final String? rejectionReason;

  const PlaceChangeResult({
    required this.item,
    required this.status,
    this.rejectionReason,
  });
}
