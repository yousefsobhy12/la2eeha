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

  result.fold((failure) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('مقدرناش نتأكد من بيزنسك، جرّب تاني')),
      );
    return;
  }, (summary) {
    if (summary == null) {
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
      subCategory: summary.subCategory,
    );
    switch (type) {
      case PlacePricingScreenType.menuItems:
        context.go('/place/${summary.id}/menu', extra: args);
      case PlacePricingScreenType.sportsPricing:
        context.go('/place/${summary.id}/pricing', extra: args);
      case PlacePricingScreenType.none:
        context.go('/place/${summary.id}/status', extra: args);
    }
  });
}
