// lib/core/constants/place_pricing_helpers.dart
//
// قاعدة توجيه واضحة للـ sub-feature بتاع "إضافة المنيو/الأسعار" بعد ما
// التاجر يسجّل بيزنس جديد — أي شاشة تفتح بعد الإضافة، بيتم حسابها من
// الكاتيجوري والـ sub-category هنا.
//
// المقارنات دي شغّالة على مفاتيح إنجليزية عمدًا (زي ما الـ PlaceDetailCubit
// و SubCategoryVisuals بيتعاملوا مع Sports) — ممنوع نحط هنا قيم عربية.

enum PlacePricingScreenType { menuItems, sportsPricing, none }

/// بتحدد نوع شاشة التسعير اللي التاجر محتاج يفتح بعد تسجيل البيزنس.
/// - الصيدليات (25): ملهاش أسعار — none.
/// - الملاعب (27) اللي sub-category بتاعها football/padel: أسعار ساعة.
/// - أي حاجة تانية: منيو.
PlacePricingScreenType pricingScreenTypeFor({
  required int categoryId,
  String? subCategory,
}) {
  if (categoryId == 25) return PlacePricingScreenType.none; // Pharmacies
  if (categoryId == 27 &&
      (subCategory == 'football' || subCategory == 'padel')) {
    return PlacePricingScreenType.sportsPricing;
  }
  return PlacePricingScreenType.menuItems;
}

/// مصادر التوصيل (28) بتعرض أسعار التوصيل بدل المنيو العادي.
bool isDeliveryPricing(int categoryId) => categoryId == 28;
