enum PlacePricingScreenType { menuItems, sportsPricing, none }

PlacePricingScreenType pricingScreenTypeFor({
  required int categoryId,
  String? subCategory,
}) {
  if (categoryId == 25) return PlacePricingScreenType.none;
  if (categoryId == 27 &&
      (subCategory == 'football' || subCategory == 'padel')) {
    return PlacePricingScreenType.sportsPricing;
  }
  return PlacePricingScreenType.menuItems;
}

bool isDeliveryPricing(int categoryId) => categoryId == 28;
