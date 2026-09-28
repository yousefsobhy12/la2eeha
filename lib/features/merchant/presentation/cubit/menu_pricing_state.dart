// lib/features/merchant/presentation/cubit/menu_pricing_state.dart
//
// حالة شاشة إدارة المنيو — نفس شكل AddPlaceState: state واحدة + copyWith مع
// _unset sentinel عشان نقدر نمسح الـ nullable fields. successMessage زائلة:
// بيتم عرضها مرة واحدة في snackbar وبعدين بتتضرب.

import '../../domain/entities/menu_item_draft.dart';

class _Unset {
  const _Unset();
}

const Object _unset = _Unset();

class MenuPricingState {
  final int placeId;
  final String placeName;

  /// true لو المكان مصادر توصيل (categoryId == 28) — بيغيّر عناوين الشاشة
  /// ("أسعار التوصيل" + عدد "المناطق" بدل "الصنف").
  final bool isDelivery;

  final List<MenuItemDraft> items;
  final bool isLoading;
  final bool isSaving;

  /// حالة الموافقة على المكان (null = لسه متجابتش/null-مجهولة). بيبان بانر
  /// "قيد المراجعة" مستمر في حالة false بس.
  final bool? isApproved;

  /// رسالة خطأ (تحميل/حفظ) — بتتعرض snackbar أو شاشة retry حسب الحالة.
  final String? errorMessage;

  // ── form fields (إضافة/تعديل صنف) ──
  final String newItemName;
  final String newItemPrice;

  /// وصف الصنف (اختياري — أقصى 150 حرف عن طريق maxLength على الحقل نفسه).
  final String newItemDescription;

  /// null = وضع "إضافة"، قيمة = بيعدّل الصنف اللي عليه الـ localKey ده.
  final String? editingLocalKey;

  /// رسالة نجاح زائلة ("تم حفظ المنيو") — بتتفرغ في snackbar مرة واحدة.
  final String? successMessage;

  const MenuPricingState({
    required this.placeId,
    required this.placeName,
    this.isDelivery = false,
    this.items = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.isApproved,
    this.errorMessage,
    this.newItemName = '',
    this.newItemPrice = '',
    this.newItemDescription = '',
    this.editingLocalKey,
    this.successMessage,
  });

  MenuPricingState copyWith({
    int? placeId,
    String? placeName,
    bool? isDelivery,
    List<MenuItemDraft>? items,
    bool? isLoading,
    bool? isSaving,
    Object? isApproved = _unset,
    Object? errorMessage = _unset,
    String? newItemName,
    String? newItemPrice,
    String? newItemDescription,
    Object? editingLocalKey = _unset,
    Object? successMessage = _unset,
  }) {
    return MenuPricingState(
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      isDelivery: isDelivery ?? this.isDelivery,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isApproved: isApproved == _unset ? this.isApproved : isApproved as bool?,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      newItemName: newItemName ?? this.newItemName,
      newItemPrice: newItemPrice ?? this.newItemPrice,
      newItemDescription: newItemDescription ?? this.newItemDescription,
      editingLocalKey: editingLocalKey == _unset
          ? this.editingLocalKey
          : editingLocalKey as String?,
      successMessage: successMessage == _unset
          ? this.successMessage
          : successMessage as String?,
    );
  }
}
