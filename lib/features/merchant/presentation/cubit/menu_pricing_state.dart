import '../../domain/entities/menu_item_draft.dart';

class _Unset {
  const _Unset();
}

const Object _unset = _Unset();

class MenuPricingState {
  final int placeId;
  final String placeName;

  final bool isDelivery;

  final List<MenuItemDraft> items;
  final bool isLoading;
  final bool isSaving;

  final bool? isApproved;

  final String? errorMessage;

  final String newItemName;
  final String newItemPrice;

  final String newItemDescription;

  final String? editingLocalKey;

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
