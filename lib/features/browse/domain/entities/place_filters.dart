class PlaceFilters {
  final bool openNow;

  final bool delivery;

  const PlaceFilters({this.openNow = false, this.delivery = false});

  bool get isActive => openNow || delivery;

  int get activeCount => (openNow ? 1 : 0) + (delivery ? 1 : 0);

  PlaceFilters copyWith({bool? openNow, bool? delivery}) {
    return PlaceFilters(
      openNow: openNow ?? this.openNow,
      delivery: delivery ?? this.delivery,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaceFilters &&
        other.openNow == openNow &&
        other.delivery == delivery;
  }

  @override
  int get hashCode => Object.hash(openNow, delivery);
}
