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

class PricingLabels {
  final String screenTitle;
  final String itemNoun;
  final String addTitle;
  final String editTitle;
  final String nameLabel;
  final String nameHint;
  final String nameRequiredError;
  final String addButton;
  final String updateButton;
  final String emptyText;
  final String saveButton;
  final String saveSuccess;
  final String dialogButton;

  const PricingLabels({
    required this.screenTitle,
    required this.itemNoun,
    required this.addTitle,
    required this.editTitle,
    required this.nameLabel,
    required this.nameHint,
    required this.nameRequiredError,
    required this.addButton,
    required this.updateButton,
    required this.emptyText,
    required this.saveButton,
    required this.saveSuccess,
    required this.dialogButton,
  });
}

const PricingLabels _menuLabels = PricingLabels(
  screenTitle: 'المنيو',
  itemNoun: 'صنف',
  addTitle: 'إضافة صنف',
  editTitle: 'تعديل صنف',
  nameLabel: 'اسم الصنف',
  nameHint: 'مثال: برجر، كشري',
  nameRequiredError: 'اكتب اسم الصنف',
  addButton: 'إضافة للمنيو',
  updateButton: 'تحديث الصنف',
  emptyText: 'مفيش أصناف لسه',
  saveButton: 'حفظ المنيو',
  saveSuccess: 'تم حفظ المنيو',
  dialogButton: 'أضف المنيو دلوقتي',
);

const PricingLabels _servicesLabels = PricingLabels(
  screenTitle: 'الخدمات والأسعار',
  itemNoun: 'خدمة',
  addTitle: 'إضافة خدمة',
  editTitle: 'تعديل خدمة',
  nameLabel: 'اسم الخدمة',
  nameHint: 'مثال: كشف، متابعة، أشعة',
  nameRequiredError: 'اكتب اسم الخدمة',
  addButton: 'إضافة للخدمات',
  updateButton: 'تحديث الخدمة',
  emptyText: 'مفيش خدمات لسه',
  saveButton: 'حفظ الخدمات',
  saveSuccess: 'تم حفظ الخدمات',
  dialogButton: 'أضف الخدمات دلوقتي',
);

const PricingLabels _productsLabels = PricingLabels(
  screenTitle: 'الأسعار',
  itemNoun: 'منتج',
  addTitle: 'إضافة منتج',
  editTitle: 'تعديل منتج',
  nameLabel: 'اسم المنتج',
  nameHint: 'مثال: لبن، فراخ، لحمة',
  nameRequiredError: 'اكتب اسم المنتج',
  addButton: 'إضافة للأسعار',
  updateButton: 'تحديث المنتج',
  emptyText: 'مفيش منتجات لسه',
  saveButton: 'حفظ الأسعار',
  saveSuccess: 'تم حفظ الأسعار',
  dialogButton: 'أضف الأسعار دلوقتي',
);

const PricingLabels _packagesLabels = PricingLabels(
  screenTitle: 'الأسعار والاشتراكات',
  itemNoun: 'باقة',
  addTitle: 'إضافة باقة',
  editTitle: 'تعديل باقة',
  nameLabel: 'اسم الباقة',
  nameHint: 'مثال: اشتراك شهري، حصة، ساعة',
  nameRequiredError: 'اكتب اسم الباقة',
  addButton: 'إضافة للأسعار',
  updateButton: 'تحديث الباقة',
  emptyText: 'مفيش باقات لسه',
  saveButton: 'حفظ الأسعار',
  saveSuccess: 'تم حفظ الأسعار',
  dialogButton: 'أضف الأسعار دلوقتي',
);

const PricingLabels _deliveryLabels = PricingLabels(
  screenTitle: 'أسعار التوصيل',
  itemNoun: 'منطقة',
  addTitle: 'إضافة منطقة',
  editTitle: 'تعديل منطقة',
  nameLabel: 'اسم المنطقة',
  nameHint: 'مثال: شبين القناطر',
  nameRequiredError: 'اكتب اسم المنطقة',
  addButton: 'إضافة للأسعار',
  updateButton: 'تحديث المنطقة',
  emptyText: 'مفيش مناطق لسه',
  saveButton: 'حفظ الأسعار',
  saveSuccess: 'تم حفظ الأسعار',
  dialogButton: 'أضف أسعار التوصيل دلوقتي',
);

const PricingLabels _genericLabels = PricingLabels(
  screenTitle: 'الأسعار',
  itemNoun: 'بند',
  addTitle: 'إضافة بند',
  editTitle: 'تعديل بند',
  nameLabel: 'اسم البند',
  nameHint: 'مثال: اسم الخدمة أو المنتج',
  nameRequiredError: 'اكتب اسم البند',
  addButton: 'إضافة للأسعار',
  updateButton: 'تحديث البند',
  emptyText: 'مفيش بنود لسه',
  saveButton: 'حفظ الأسعار',
  saveSuccess: 'تم حفظ الأسعار',
  dialogButton: 'أضف الأسعار دلوقتي',
);

PricingLabels pricingLabelsFor({required int categoryId, String? subCategory}) {
  switch (categoryId) {
    case 22:
      return _menuLabels;
    case 23:
    case 24:
      return _servicesLabels;
    case 26:
      return _productsLabels;
    case 27:
      return _packagesLabels;
    case 28:
      return _deliveryLabels;
    default:
      return _genericLabels;
  }
}
