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

  static const String _pendingSuccessMessage =
      'اتبعتت تعديلاتك للمراجعة — الأسعار الحالية هتفضل ظاهرة لحد الموافقة';

  static const List<String> presets = ['صباحي', 'ليلي', 'ليلي متأخر', 'مخصص'];

  Future<void> loadSportsPricing() async {
    emit(
      state.copyWith(isLoading: true, loadFailed: false, errorMessage: null),
    );

    final approvalResult = await _merchantRepository.isPlaceApproved(
      placeId: state.placeId,
    );
    final bool? isApproved = approvalResult.fold((_) => null, (value) => value);

    final result = await _placesRepository.getSportsPricing(state.placeId);
    final String? failureMessage = result.fold(
      (failure) => failure.message,
      (_) => null,
    );
    if (failureMessage != null) {
      emit(
        state.copyWith(
          isLoading: false,
          loadFailed: true,
          errorMessage: failureMessage,
          isApproved: isApproved,
        ),
      );
      return;
    }

    var drafts = <SportsPricingDraft>[
      for (final item in result.getOrElse(() => const []))
        SportsPricingDraft(
          localKey: item.id.toString(),
          id: item.id,
          startTime: _parseHhMmSs(item.startTime),
          endTime: _parseHhMmSs(item.endTime),
          price: item.price,
          description: item.description,
          sortOrder: item.sortOrder,
        ),
    ];

    var hasPending = false;
    if (isApproved != false) {
      final pendingResult = await _merchantRepository.getPendingSportsPricing(
        placeId: state.placeId,
      );
      final List<SportsPricingDraft>? pending = pendingResult.fold(
        (_) => null,
        (value) => value,
      );
      if (pending != null) {
        drafts = pending;
        hasPending = true;
      }
    }

    emit(
      state.copyWith(
        isLoading: false,
        loadFailed: false,
        periods: drafts,
        isApproved: isApproved,
        hasPending: hasPending,
        hasUnsavedChanges: false,
      ),
    );
  }

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
      default:
        emit(
          state.copyWith(
            selectedPreset: preset,
            newStartTime: null,
            newEndTime: null,
          ),
        );
    }
  }

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
        newPrice: period.price.toPriceString(),
        newDescription: period.description ?? '',
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

  void confirmPeriod() {
    final start = state.newStartTime;
    final end = state.newEndTime;
    final price = double.tryParse(state.newPrice.trim().toWesternDigits());
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
        hasUnsavedChanges: true,
      ),
    );
  }

  void reorderPeriod(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final periods = [...state.periods];
    final period = periods.removeAt(oldIndex);
    periods.insert(newIndex, period);
    emit(state.copyWith(periods: periods, hasUnsavedChanges: true));
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
        hasUnsavedChanges: true,
      ),
    );
  }

  Future<void> save() async {
    if (state.isSaving) return;
    if (state.editingLocalKey != null) {
      emit(state.copyWith(
        errorMessage: 'لسه بتعدّل عنصر — دوس «تحديث» أو «إلغاء التعديل» الأول',
      ));
      return;
    }
    final formHasText = state.newStartTime != null ||
        state.newEndTime != null ||
        state.newPrice.trim().isNotEmpty ||
        state.newDescription.trim().isNotEmpty ||
        state.selectedPreset != null;
    if (formHasText) {
      emit(state.copyWith(
        errorMessage: 'لسه فيه بيانات مكتوبة في الفورم ومضافتش — دوس زرار الإضافة الأول',
      ));
      return;
    }
    emit(state.copyWith(isSaving: true, errorMessage: null));

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

    final direct = state.isApproved == false;
    final result = direct
        ? await _merchantRepository.replaceSportsPricing(
            placeId: state.placeId,
            items: orderedPeriods,
          )
        : await _merchantRepository.submitPendingSportsPricing(
            placeId: state.placeId,
            items: orderedPeriods,
          );
    result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            hasPending: !direct,
            hasUnsavedChanges: false,
            successMessage: direct
                ? 'تم حفظ الأسعار'
                : _pendingSuccessMessage,
          ),
        );
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
