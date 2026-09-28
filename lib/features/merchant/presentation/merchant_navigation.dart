// lib/features/merchant/presentation/merchant_navigation.dart
//
// نقطة الدخول المشتركة للتاجر (من BusinessOwnerCard و LoginView). بتجيب
// أحدث place للتاجر وبتوجهه للشاشة المناسبة حسب الكاتيجوري:
//   - منيو/أسعار توصيل → /place/:id/menu
//   - أسعار ساعة (ملاعب) → /place/:id/pricing
//   - مفيش أسعار (صيدليات) → /place/:id/status
// Bentستخدم context.go (مش push) لأن ده entry point — بنستبدل شاشة الدخول
// بنستخدم context.go (مش push) لأن ده entry point — بنستبدل شاشة الدخول
// نفسها من غير ما نسيب أي حاجة في الـ back stack.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/place_pricing_helpers.dart';
import '../domain/repositories/merchant_repository.dart';
import 'views/pricing_args.dart';

Future<void> navigateToMerchantEntry(
  BuildContext context,
  MerchantRepository repo,
) async {
  final result = await repo.getMyLatestPlace();
  if (!context.mounted) return;

  result.fold((failure) => context.go('/add-place'), (summary) {
    if (summary == null) {
      context.push('/add-place');
      context.go('/add-place');
      return;
    }
    final type = pricingScreenTypeFor(
      categoryId: summary.categoryId,
      subCategory: summary.subCategory,
    );
    final args = PricingArgs(
      placeId: summary.id,
      placeName: summary.name,
      categoryId: summary.categoryId,
    );
    switch (type) {
      case PlacePricingScreenType.menuItems:
        context.push('/place/${summary.id}/menu', extra: args);
        context.go('/place/${summary.id}/menu', extra: args);
      case PlacePricingScreenType.sportsPricing:
        context.push('/place/${summary.id}/pricing', extra: args);
        context.go('/place/${summary.id}/pricing', extra: args);
      case PlacePricingScreenType.none:
        context.push('/place/${summary.id}/status', extra: args);
        context.go('/place/${summary.id}/status', extra: args);
    }
  });
}
