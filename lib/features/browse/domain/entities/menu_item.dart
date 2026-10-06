class MenuItem {
  final int id;
  final int placeId;
  final String name;
  final double price;
  final String? description;

  final int sortOrder;

  const MenuItem({
    required this.id,
    required this.placeId,
    required this.name,
    required this.price,
    this.description,
    this.sortOrder = 0,
  });
}
