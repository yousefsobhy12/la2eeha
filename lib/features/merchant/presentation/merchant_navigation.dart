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
