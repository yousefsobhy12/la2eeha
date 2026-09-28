// lib/features/merchant/presentation/views/pricing_args.dart
//
// Extra الواحد المشترك لشاشات المنيو/أسعار الساعة. نوع الشاشة (منيو vs
// أسعار ساعة) بيتحسب من categoryId عن طريق pricingScreenTypeFor على مستوى
// الكولر — الملفات هنا بتقرا الحقول نفسها.

class PricingArgs {
  final int placeId;
  final String placeName;
  final int categoryId;

  const PricingArgs({
    required this.placeId,
    required this.placeName,
    required this.categoryId,
  });
}
