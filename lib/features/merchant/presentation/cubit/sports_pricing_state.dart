// lib/features/merchant/presentation/cubit/sports_pricing_state.dart
//
// حالة شاشة أسعار الساعة (Sports) — نفس شكل MenuPricingState + _unset لمّا
// نحتاج نمسح TimeOfDay nullable (تحديدات الفترة لما المستخدم يختار "مخصص").

import 'package:flutter/material.dart';

import '../../domain/entities/sports_pricing_draft.dart';

class _Unset {
  const _Unset();
}

const Object _unset = _Unset();

class SportsPricingState {
  final int placeId;
  final String placeName;

  final List<SportsPricingDraft> periods;
  final bool isLoading;
  final bool isSaving;

  /// حالة الموافقة على المكان (null = لسه متجابتش/null-مجهولة). بيبان بانر
  /// "قيد المراجعة" مستمر في حالة false بس.
  final bool? isApproved;

  /// رسالة خطأ (تحميل/حفظ) — بتتعرض snackbar أو شاشة retry حسب الحالة.
  final String? errorMessage;

  // ── form fields ──
  final TimeOfDay? newStartTime;
  final TimeOfDay? newEndTime;
  final String newPrice;

  /// وصف الفترة (اختياري — أقصى 150 حرف عن طريق maxLength على الحقل نفسه).
  final String newDescription;

  /// واحد من: صباحي / ليلي / ليلي متأخر / مخصص — بيحدد اللي التاجر اختاره
  /// من الـ dropdown، و null في وضع التعديل-مخصص أو قبل أي اختيار.
  final String? selectedPreset;

  /// null = وضع "إضافة"، قيمة = بيعدّل الفترة اللي عليها الـ localKey ده.
  final String? editingLocalKey;

  /// رسالة نجاح زائلة ("تم حفظ الأسعار").
  final String? successMessage;

  const SportsPricingState({
    required this.placeId,
    required this.placeName,
    this.periods = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.isApproved,
    this.errorMessage,
    this.newStartTime,
    this.newEndTime,
    this.newPrice = '',
    this.newDescription = '',
    this.selectedPreset,
    this.editingLocalKey,
    this.successMessage,
  });

  SportsPricingState copyWith({
    int? placeId,
    String? placeName,
    List<SportsPricingDraft>? periods,
    bool? isLoading,
    bool? isSaving,
    Object? isApproved = _unset,
    Object? errorMessage = _unset,
    Object? newStartTime = _unset,
    Object? newEndTime = _unset,
    String? newPrice,
    String? newDescription,
    Object? selectedPreset = _unset,
    Object? editingLocalKey = _unset,
    Object? successMessage = _unset,
  }) {
    return SportsPricingState(
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      periods: periods ?? this.periods,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isApproved: isApproved == _unset ? this.isApproved : isApproved as bool?,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      newStartTime: newStartTime == _unset
          ? this.newStartTime
          : newStartTime as TimeOfDay?,
      newEndTime: newEndTime == _unset
          ? this.newEndTime
          : newEndTime as TimeOfDay?,
      newPrice: newPrice ?? this.newPrice,
      newDescription: newDescription ?? this.newDescription,
      selectedPreset: selectedPreset == _unset
          ? this.selectedPreset
          : selectedPreset as String?,
      editingLocalKey: editingLocalKey == _unset
          ? this.editingLocalKey
          : editingLocalKey as String?,
      successMessage: successMessage == _unset
          ? this.successMessage
          : successMessage as String?,
    );
  }
}
