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
  final bool loadFailed;
  final bool hasPending;
  final bool hasUnsavedChanges;
  final bool isSaving;

  final bool? isApproved;

  final String? errorMessage;

  final TimeOfDay? newStartTime;
  final TimeOfDay? newEndTime;
  final String newPrice;

  final String newDescription;

  final String? selectedPreset;

  final String? editingLocalKey;

  final String? successMessage;

  const SportsPricingState({
    required this.placeId,
    required this.placeName,
    this.periods = const [],
    this.isLoading = false,
    this.loadFailed = false,
    this.hasPending = false,
    this.hasUnsavedChanges = false,
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
    bool? loadFailed,
    bool? hasPending,
    bool? hasUnsavedChanges,
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
      loadFailed: loadFailed ?? this.loadFailed,
      hasPending: hasPending ?? this.hasPending,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
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
