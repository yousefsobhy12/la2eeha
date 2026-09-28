// lib/features/merchant/presentation/cubit/sports_pricing_cubit.dart
//
// Cubit شاشة أسعار الساعة للملاعب (Sports) — نفس مبدئي MenuPricingCubit:
// جلب من PlacesRepository.getSportsPricing و حفظ بـ replaceSportsPricing.
// الـ presets بيملّوا الأوقات بس — والـ label المعروض على الصفوف بيتحسب
// من startTime الفعلي للصف (periodLabel) مش من اختيار الـ dropdown.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../browse/domain/repositories/places_repository.dart';
import '../../domain/entities/sports_pricing_draft.dart';
import '../../domain/repositories/merchant_repository.dart';
import 'sports_pricing_state.dart';

class SportsPricingCubit extends Cubit<SportsPricingState> {
  SportsPricingCubit(
    this._merchantRepository,
    this._placesRepository, {
    required int placeId,
    required String placeName,
  }) : super(SportsPricingState(placeId: placeId, placeName: placeName));

  final MerchantRepository _merchantRepository;
  final PlacesRepository _placesRepository;

  static const List<String> presets = ['صباحي', 'ليلي', 'ليلي متأخر', 'مخصص'];

  Future<void> loadSportsPricing() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _placesRepository.getSportsPricing(state.placeId);
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (items) {
        emit(
          state.copyWith(
            isLoading: false,
            periods: [
              for (final item in items)
                SportsPricingDraft(
                  localKey: item.id.toString(),
                  id: item.id,
                  startTime: _parseHhMmSs(item.startTime),
                  endTime: _parseHhMmSs(item.endTime),
                  price: item.price,
                  description: item.description,
                  sortOrder: item.sortOrder,
                ),
            ],
          ),
        );
      },
    );

    // حالة الموافقة بتتسحب منفصلة — لو فشلت، بانر "قيد المراجعة" وهيختفي
    // بدل ما نكسر الشاشة كلها.
    final approvalResult = await _merchantRepository.isPlaceApproved(
      placeId: state.placeId,
    );
    approvalResult.fold(
      (_) => emit(state.copyWith(isApproved: null)),
      (approved) => emit(state.copyWith(isApproved: approved)),
    );
  }

  // ── preset dropdown ──

  void selectPreset(String preset) {
    switch (preset) {
      case 'صباحي':
        emit(
          state.copyWith(
            selectedPreset: preset,
            newStartTime: const TimeOfDay(hour: 9, minute: 0),
            newEndTime: const TimeOfDay(hour: 16, minute: 0),
          ),
        );
      case 'ليلي':
        emit(
          state.copyWith(
            selectedPreset: preset,
            newStartTime: const TimeOfDay(hour: 16, minute: 0),
            newEndTime: const TimeOfDay(hour: 21, minute: 0),
          ),
        );
      case 'ليلي متأخر':
        emit(
          state.copyWith(
            selectedPreset: preset,
            newStartTime: const TimeOfDay(hour: 21, minute: 0),
            newEndTime: const TimeOfDay(hour: 2, minute: 0),
          ),
        );
      default: // 'مخصص' — التاجر بيختار الأوقات يدويًا.
        emit(
          state.copyWith(
            selectedPreset: preset,
            newStartTime: null,
            newEndTime: null,
          ),
        );
    }
  }

  // ── form fields ──

  void updateStartTime(TimeOfDay value) {
    emit(state.copyWith(newStartTime: value));
  }

  void updateEndTime(TimeOfDay value) {
    emit(state.copyWith(newEndTime: value));
  }

  void updatePrice(String value) {
    emit(state.copyWith(newPrice: value));
  }

  void updateNewDescription(String value) {
    emit(state.copyWith(newDescription: value));
  }

  void startEditing(String localKey) {
    final period = state.periods
        .where((p) => p.localKey == localKey)
        .firstOrNull;
    if (period == null) return;
    emit(
      state.copyWith(
        editingLocalKey: localKey,
        newStartTime: period.startTime,
        newEndTime: period.endTime,
        newPrice: period.price.toString(),
        newDescription: period.description ?? '',
        // الـ preset راجع من وقت بداية الفترة الفعلية — من غير ما نعتمد
        // على اختيار سابق لأنه مش محفوظ في الصف.
        selectedPreset: period.startTime.periodLabel.label,
      ),
    );
  }

  void cancelEditing() {
    emit(
      state.copyWith(
        editingLocalKey: null,
        newStartTime: null,
        newEndTime: null,
        newPrice: '',
        newDescription: '',
        selectedPreset: null,
      ),
    );
  }

  /// بيضيف فترة جديدة (id: null) أو بيحدّث اللي عليه الـ editingLocalKey.
  /// Validation (الأوقات + السعر) بيتم في الـ Form في الـ view؛ هنا guard دفاعي.
  void confirmPeriod() {
    final start = state.newStartTime;
    final end = state.newEndTime;
    final price = double.tryParse(state.newPrice.trim());
    if (start == null || end == null || price == null || price <= 0) return;

    final description = _normalizeDescription(state.newDescription);

    final editingKey = state.editingLocalKey;
    final periods = [...state.periods];
    if (editingKey != null) {
      final index = periods.indexWhere((p) => p.localKey == editingKey);
      if (index != -1) {
        periods[index] = SportsPricingDraft(
          localKey: editingKey,
          id: periods[index].id,
          startTime: start,
          endTime: end,
          price: price,
          description: description,
          sortOrder: periods[index].sortOrder,
        );
      }
    } else {
      periods.add(
        SportsPricingDraft(
          localKey: DateTime.now().microsecondsSinceEpoch.toString(),
          id: null,
          startTime: start,
          endTime: end,
          price: price,
          description: description,
          sortOrder: periods.length,
        ),
      );
    }

    emit(
      state.copyWith(
        periods: periods,
        editingLocalKey: null,
        newStartTime: null,
        newEndTime: null,
        newPrice: '',
        newDescription: '',
        selectedPreset: null,
      ),
    );
  }

  /// النقل داخل القائمة. الـ `newIndex` متصحّح بالفعل من onReorderItem.
  void reorderPeriod(int oldIndex, int newIndex) {
    final periods = [...state.periods];
    final period = periods.removeAt(oldIndex);
    periods.insert(newIndex, period);
    emit(state.copyWith(periods: periods));
  }

  void removePeriod(String localKey) {
    final removesEditedPeriod = state.editingLocalKey == localKey;
    emit(
      state.copyWith(
        periods: state.periods.where((p) => p.localKey != localKey).toList(),
        editingLocalKey: removesEditedPeriod ? null : state.editingLocalKey,
        newStartTime: removesEditedPeriod ? null : state.newStartTime,
        newEndTime: removesEditedPeriod ? null : state.newEndTime,
        newPrice: removesEditedPeriod ? '' : state.newPrice,
        newDescription: removesEditedPeriod ? '' : state.newDescription,
        selectedPreset: removesEditedPeriod ? null : state.selectedPreset,
      ),
    );
  }

  // ── save ──

  Future<void> save() async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true, errorMessage: null));

    // sortOrder يتاخد من موضع كل فترة في القائمة الحالية (0, 1, 2...).
    final orderedPeriods = [
      for (var i = 0; i < state.periods.length; i++)
        SportsPricingDraft(
          localKey: state.periods[i].localKey,
          id: state.periods[i].id,
          startTime: state.periods[i].startTime,
          endTime: state.periods[i].endTime,
          price: state.periods[i].price,
          description: state.periods[i].description,
          sortOrder: i,
        ),
    ];

    final result = await _merchantRepository.replaceSportsPricing(
      placeId: state.placeId,
      items: orderedPeriods,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
      },
      (_) {
        emit(state.copyWith(isSaving: false, successMessage: 'تم حفظ الأسعار'));
      },
    );
  }

  void dismissMessages() {
    if (state.errorMessage == null && state.successMessage == null) return;
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }

  TimeOfDay _parseHhMmSs(String raw) {
    final parts = raw.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String? _normalizeDescription(String raw) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
