class SubCategoryVisuals {
  SubCategoryVisuals._();

  static const Map<String, String> _labels = {
    'restaurant': 'مطعم',
    'cafe': 'كافيه',
    'sweets_shop': 'محل حلويات',
    'grocery': 'بقالة',
    'chicken_shop': 'محل فراخ',
    'butcher': 'جزارة',
    'football': 'ملعب كورة',
    'padel': 'ملعب بادل',
    'boxing': 'ملاكمة',
    'kungfu': 'كونغ فو',
    'playstation': 'بلايستيشن',
  };

  static String labelOf(String? subCategory, {required String fallback}) {
    if (subCategory == null) return fallback;
    return _labels[subCategory] ?? fallback;
  }
}
