import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../browse/domain/repositories/places_repository.dart';
import '../../domain/entities/menu_item_draft.dart';
import '../../domain/repositories/merchant_repository.dart';
import 'menu_pricing_state.dart';

class MenuPricingCubit extends Cubit<MenuPricingState> {
  MenuPricingCubit(
    this._merchantRepository,
    this._placesRepository, {
    required int placeId,
    required String placeName,
    required bool isDelivery,
    required String saveSuccessMessage,
  }) : _saveSuccessMessage = saveSuccessMessage, // ignore: prefer_initializing_formals
       super(
         MenuPricingState(
           placeId: placeId,
           placeName: placeName,
           isDelivery: isDelivery,
         ),
       );

  final MerchantRepository _merchantRepository;
  final PlacesRepository _placesRepository;
  final String _saveSuccessMessage;

  static const String _pendingSuccessMessage =
      'اتبعتت تعديلاتك للمراجعة — الأسعار الحالية هتفضل ظاهرة لحد الموافقة';

  Future<void> loadMenuItems() async {
    emit(
      state.copyWith(isLoading: true, loadFailed: false, errorMessage: null),
    );

    final approvalResult = await _merchantRepository.isPlaceApproved(
      placeId: state.placeId,
    );
    final bool? isApproved = approvalResult.fold((_) => null, (value) => value);

    final result = await _placesRepository.getMenuItems(state.placeId);
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

    var drafts = <MenuItemDraft>[
      for (final item in result.getOrElse(() => const []))
        MenuItemDraft(
          localKey: item.id.toString(),
          id: item.id,
          name: item.name,
          price: item.price,
          description: item.description,
          sortOrder: item.sortOrder,
        ),
    ];

    var hasPending = false;
    if (isApproved != false) {
      final pendingResult = await _merchantRepository.getPendingMenuItems(
        placeId: state.placeId,
      );
      final List<MenuItemDraft>? pending = pendingResult.fold(
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
        items: drafts,
        isApproved: isApproved,
        hasPending: hasPending,
        hasUnsavedChanges: false,
      ),
    );
  }

  void updateNewItemName(String value) {
    emit(state.copyWith(newItemName: value));
  }

  void updateNewItemPrice(String value) {
    emit(state.copyWith(newItemPrice: value));
  }

  void updateNewItemDescription(String value) {
    emit(state.copyWith(newItemDescription: value));
  }

  void startEditing(String localKey) {
    final item = state.items.where((i) => i.localKey == localKey).firstOrNull;
    if (item == null) return;
    emit(
      state.copyWith(
        editingLocalKey: localKey,
        newItemName: item.name,
        newItemPrice: item.price.toPriceString(),
        newItemDescription: item.description ?? '',
      ),
    );
  }

  void cancelEditing() {
    emit(
      state.copyWith(
        editingLocalKey: null,
        newItemName: '',
        newItemPrice: '',
        newItemDescription: '',
      ),
    );
  }

  void confirmItem() {
    final name = state.newItemName.trim();
    final price = double.tryParse(state.newItemPrice.trim().toWesternDigits());
    if (name.isEmpty || price == null || price <= 0) return;

    final description = _normalizeDescription(state.newItemDescription);

    final editingKey = state.editingLocalKey;
    final items = [...state.items];
    if (editingKey != null) {
      final index = items.indexWhere((i) => i.localKey == editingKey);
      if (index != -1) {
        items[index] = MenuItemDraft(
          localKey: editingKey,
          id: items[index].id,
          name: name,
          price: price,
          description: description,
          sortOrder: items[index].sortOrder,
        );
      }
    } else {
      items.add(
        MenuItemDraft(
          localKey: DateTime.now().microsecondsSinceEpoch.toString(),
          id: null,
          name: name,
          price: price,
          description: description,
          sortOrder: items.length,
        ),
      );
    }

    emit(
      state.copyWith(
        items: items,
        editingLocalKey: null,
        newItemName: '',
        newItemPrice: '',
        newItemDescription: '',
        hasUnsavedChanges: true,
      ),
    );
  }

  void reorderItem(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final items = [...state.items];
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    emit(state.copyWith(items: items, hasUnsavedChanges: true));
  }

  void removeItem(String localKey) {
    final removesEditedItem = state.editingLocalKey == localKey;
    emit(
      state.copyWith(
        items: state.items.where((i) => i.localKey != localKey).toList(),
        editingLocalKey: removesEditedItem ? null : state.editingLocalKey,
        newItemName: removesEditedItem ? '' : state.newItemName,
        newItemPrice: removesEditedItem ? '' : state.newItemPrice,
        newItemDescription: removesEditedItem ? '' : state.newItemDescription,
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
    final formHasText = state.newItemName.trim().isNotEmpty ||
        state.newItemPrice.trim().isNotEmpty ||
        state.newItemDescription.trim().isNotEmpty;
    if (formHasText) {
      emit(state.copyWith(
        errorMessage: 'لسه فيه بيانات مكتوبة في الفورم ومضافتش — دوس زرار الإضافة الأول',
      ));
      return;
    }
    emit(state.copyWith(isSaving: true, errorMessage: null));

    final orderedItems = [
      for (var i = 0; i < state.items.length; i++)
        MenuItemDraft(
          localKey: state.items[i].localKey,
          id: state.items[i].id,
          name: state.items[i].name,
          price: state.items[i].price,
          description: state.items[i].description,
          sortOrder: i,
        ),
    ];

    final direct = state.isApproved == false;
    final result = direct
        ? await _merchantRepository.replaceMenuItems(
            placeId: state.placeId,
            items: orderedItems,
          )
        : await _merchantRepository.submitPendingMenuItems(
            placeId: state.placeId,
            items: orderedItems,
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
                ? _saveSuccessMessage
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

  String? _normalizeDescription(String raw) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
