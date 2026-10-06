class MenuItemDraft {
  final String localKey;
  final int? id;
  final String name;
  final double price;

  final String? description;

  final int sortOrder;

  const MenuItemDraft({
    required this.localKey,
    this.id,
    required this.name,
    required this.price,
    this.description,
    required this.sortOrder,
  });
}
