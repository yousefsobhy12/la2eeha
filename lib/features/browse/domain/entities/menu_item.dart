class MenuItem {
  final int id;
  final int placeId;
  final String name;
  final double price;
  final String? description;

  /// ترتيب العرض — بيفضل مُدار من جانب التاجر (الإضافة/الترتيب بالسحب)
  /// ومش بيتعدل يدويًا على مستوى الـ item.
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
