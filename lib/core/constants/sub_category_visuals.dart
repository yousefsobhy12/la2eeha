// lib/core/constants/sub_category_visuals.dart
//
// ماب الـ sub_category keys الإنجليزية للأسماء العربية.
// نفس pattern الـ CategoryVisuals — static lookup مع fallback.
//
// لو sub_category جديدة اتضافت من الأدمن ومش موجودة هنا، الـ fallback
// بيرجع null وبيتم الاعتماد على categoryName بدلها.

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

  /// يرجع الاسم العربي للـ sub_category، أو [fallback] لو مش موجود في الماب أو null.
  static String labelOf(String? subCategory, {required String fallback}) {
    if (subCategory == null) return fallback;
    return _labels[subCategory] ?? fallback;
  }
}
