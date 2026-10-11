import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/delivery_categories.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../browse/domain/entities/area.dart';
import '../../../browse/domain/entities/category.dart';
import '../../../browse/domain/repositories/places_repository.dart';
import '../../domain/entities/place_change_item.dart';
import '../../domain/entities/place_draft.dart';
import '../../domain/repositories/merchant_repository.dart';
import 'add_place_state.dart';

class AddPlaceCubit extends Cubit<AddPlaceState> {
  AddPlaceCubit(this._merchantRepository, this._placesRepository, this._storage)
    : super(const AddPlaceState());

  final MerchantRepository _merchantRepository;
  final PlacesRepository _placesRepository;
  final LocalStorageService _storage;

  static const String draftKey = 'add_place_draft';
  static const Duration saveDebounce = Duration(milliseconds: 800);
  static const _phonePattern = r'^01[0125][0-9]{8}$';

  static const subCategoryCategories = {22, 26, 27};

  static const deliveryCategories = kDeliveryCategoryIds;

  Timer? _saveTimer;

  Future<void> loadFormData() async {
    emit(state.copyWith(status: AddPlaceStatus.loadingFormData));

    final categoriesResult = await _placesRepository.getCategories();
    final areasResult = await _placesRepository.getAreas();

    final lookups = [categoriesResult, areasResult];
    for (final either in lookups) {
      if (either.isLeft()) {
        final message = either.fold((failure) => failure.message, (_) => null);
        emit(
          state.copyWith(status: AddPlaceStatus.error, errorMessage: message),
        );
        return;
      }
    }

    final categories = categoriesResult.getOrElse(() => const <Category>[]);
    final areas = areasResult.getOrElse(() => const <Area>[]);

    var restored = const AddPlaceState();

    final rawDraft = await _storage.getString(draftKey);
    if (rawDraft != null && rawDraft.isNotEmpty) {
      try {
        final json = jsonDecode(rawDraft) as Map<String, dynamic>;

        String? imageFilePath = json['imageFilePath'] as String?;
        File? imageFile;
        if (imageFilePath != null) {
          final file = File(imageFilePath);
          if (file.existsSync()) {
            imageFile = file;
          }
        }

        restored = restored.copyWith(
          name: (json['name'] as String?) ?? '',
          categoryId: (json['categoryId'] as num?)?.toInt(),
          subCategory: json['subCategory'] as String?,
          areaId: (json['areaId'] as num?)?.toInt(),
          isOtherAreaSelected: (json['isOtherAreaSelected'] as bool?) ?? false,
          otherAreaName: (json['otherAreaName'] as String?) ?? '',
          address: (json['address'] as String?) ?? '',
          phone: (json['phone'] as String?) ?? '',
          whatsapp: json['whatsapp'] as String?,
          googleMapsUrl: json['googleMapsUrl'] as String?,
          description: json['description'] as String?,
          is24Hours: (json['is24Hours'] as bool?) ?? false,
          isDelivery: (json['isDelivery'] as bool?) ?? false,
          openTime: (json['is24Hours'] as bool?) ?? false
              ? null
              : json['openTime'] as String?,
          closeTime: (json['is24Hours'] as bool?) ?? false
              ? null
              : json['closeTime'] as String?,
          closedDays: ((json['closedDays'] as List?) ?? const [])
              .map((e) => (e as num).toInt())
              .toList(),
          imageFile: imageFile,
        );
      } catch (_) {}
    }

    emit(
      restored.copyWith(
        status: AddPlaceStatus.ready,
        categories: categories,
        areas: areas,
      ),
    );
  }

  Future<void> loadForEdit(int placeId) async {
    emit(
      state.copyWith(
        status: AddPlaceStatus.loadingFormData,
        editingPlaceId: placeId,
      ),
    );

    final categoriesResult = await _placesRepository.getCategories();
    final areasResult = await _placesRepository.getAreas();
    final placeResult = await _merchantRepository.getEditablePlace(
      placeId: placeId,
    );

    for (final either in [categoriesResult, areasResult, placeResult]) {
      if (either.isLeft()) {
        final message = either.fold((failure) => failure.message, (_) => null);
        emit(
          state.copyWith(status: AddPlaceStatus.error, errorMessage: message),
        );
        return;
      }
    }

    final categories = categoriesResult.getOrElse(() => const <Category>[]);
    final areas = areasResult.getOrElse(() => const <Area>[]);
    final place = placeResult.getOrElse(
      () => throw StateError('unreachable'),
    );

    var pendingChanges = const <String, Map<String, dynamic>>{};
    if (place.isApproved) {
      final pendingResult = await _merchantRepository.getPendingPlaceChanges(
        placeId: placeId,
      );
      if (pendingResult.isLeft()) {
        final message = pendingResult.fold(
          (failure) => failure.message,
          (_) => null,
        );
        emit(
          state.copyWith(status: AddPlaceStatus.error, errorMessage: message),
        );
        return;
      }
      pendingChanges = pendingResult.getOrElse(
        () => const <String, Map<String, dynamic>>{},
      );
    }

    var name = place.name;
    var phone = place.phone;
    var whatsapp = place.whatsapp;
    var address = place.address;
    var googleMapsUrl = place.googleMapsUrl;
    var isDelivery = place.isDelivery;
    var description = place.description;
    var openTime = place.openTime;
    var closeTime = place.closeTime;
    var closedDays = place.closedDays;
    var is24Hours = place.is24Hours;
    var existingImageUrl = place.imageUrl;

    final descriptionPayload = pendingChanges['description'];
    if (descriptionPayload != null &&
        descriptionPayload.containsKey('description')) {
      description = descriptionPayload['description'] as String?;
    }

    final infoPayload = pendingChanges['info'];
    if (infoPayload != null) {
      if (infoPayload.containsKey('name')) {
        name = infoPayload['name'] as String;
      }
      if (infoPayload.containsKey('phone')) {
        phone = infoPayload['phone'] as String;
      }
      if (infoPayload.containsKey('whatsapp')) {
        whatsapp = infoPayload['whatsapp'] as String?;
      }
      if (infoPayload.containsKey('address')) {
        address = infoPayload['address'] as String;
      }
      if (infoPayload.containsKey('google_maps_url')) {
        googleMapsUrl = infoPayload['google_maps_url'] as String?;
      }
      if (infoPayload.containsKey('is_delivery')) {
        isDelivery = infoPayload['is_delivery'] == true;
      }
    }

    final hoursPayload = pendingChanges['hours'];
    if (hoursPayload != null) {
      if (hoursPayload.containsKey('open_time')) {
        openTime = hoursPayload['open_time'] as String?;
      }
      if (hoursPayload.containsKey('close_time')) {
        closeTime = hoursPayload['close_time'] as String?;
      }
      if (hoursPayload.containsKey('closed_days')) {
        closedDays = [
          for (final day
              in (hoursPayload['closed_days'] as List<dynamic>? ?? const []))
            day as int,
        ];
      }
      if (hoursPayload.containsKey('is_24_hours')) {
        is24Hours = hoursPayload['is_24_hours'] == true;
      }
    }

    final photoPayload = pendingChanges['photo'];
    if (photoPayload != null && photoPayload.containsKey('image_url')) {
      existingImageUrl = photoPayload['image_url'] as String?;
    }

    if (is24Hours) {
      openTime = null;
      closeTime = null;
    }

    final isOtherAreaSelected =
        place.areaId == null && place.pendingAreaName != null;
    final otherAreaName = place.pendingAreaName ?? '';

    emit(
      state.copyWith(
        status: AddPlaceStatus.ready,
        categories: categories,
        areas: areas,
        name: name,
        categoryId: place.categoryId,
        subCategory: place.subCategory,
        areaId: place.areaId,
        isOtherAreaSelected: isOtherAreaSelected,
        otherAreaName: otherAreaName,
        address: address,
        phone: phone,
        whatsapp: whatsapp,
        googleMapsUrl: googleMapsUrl,
        description: description,
        openTime: openTime,
        closeTime: closeTime,
        closedDays: closedDays,
        is24Hours: is24Hours,
        isDelivery: isDelivery,
        imageFile: null,
        existingImageUrl: existingImageUrl,
        isApprovedPlace: place.isApproved,
        originalPlace: place,
        pendingChanges: pendingChanges,
      ),
    );
  }

  void updateName(String value) {
    emit(state.copyWith(name: value));
    _saveDraft();
  }

  void updateCategory(int? categoryId) {
    final keepsDelivery = deliveryCategories.contains(categoryId);
    emit(
      state.copyWith(
        categoryId: categoryId,
        isDelivery: keepsDelivery ? state.isDelivery : false,
      ),
    );
    _saveDraft();
  }

  void updateSubCategory(String? value) {
    emit(state.copyWith(subCategory: value));
    _saveDraft();
  }

  void selectExistingArea(int areaId) {
    emit(state.copyWith(areaId: areaId, isOtherAreaSelected: false));
    _saveDraft();
  }

  void selectOtherArea() {
    emit(state.copyWith(areaId: null, isOtherAreaSelected: true));
    _saveDraft();
  }

  void updateOtherAreaName(String value) {
    emit(state.copyWith(otherAreaName: value));
    _saveDraft();
  }

  void updateAddress(String value) {
    emit(state.copyWith(address: value));
    _saveDraft();
  }

  void updatePhone(String value) {
    emit(state.copyWith(phone: value));
    _saveDraft();
  }

  void updateWhatsapp(String value) {
    emit(state.copyWith(whatsapp: value));
    _saveDraft();
  }

  void updateGoogleMapsUrl(String value) {
    emit(state.copyWith(googleMapsUrl: value));
    _saveDraft();
  }

  void updateDescription(String value) {
    emit(state.copyWith(description: value));
    _saveDraft();
  }

  void updateOpenTime(String? value) {
    emit(state.copyWith(openTime: value));
    _saveDraft();
  }

  void updateCloseTime(String? value) {
    emit(state.copyWith(closeTime: value));
    _saveDraft();
  }

  void toggleClosedDay(int day) {
    final current = state.closedDays;
    final updated = current.contains(day)
        ? current.where((d) => d != day).toList()
        : [...current, day];
    emit(state.copyWith(closedDays: updated));
    _saveDraft();
  }

  void setIs24Hours(bool value) {
    emit(
      state.copyWith(
        is24Hours: value,
        openTime: value ? null : state.openTime,
        closeTime: value ? null : state.closeTime,
      ),
    );
    _saveDraft();
  }

  void setIsDelivery(bool value) {
    emit(state.copyWith(isDelivery: value));
    _saveDraft();
  }

  Future<void> pickImage() async {
    try {
      final xfile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 720,
        imageQuality: 70,
      );
      if (xfile == null) return;
      emit(state.copyWith(imageFile: File(xfile.path)));
      _saveDraft();
    } catch (_) {}
  }

  void removeImage() {
    emit(state.copyWith(imageFile: null));
    _saveDraft();
  }

  Future<void> submit() async {
    final validationError = _validate();
    if (validationError != null) {
      emit(
        state.copyWith(
          status: AddPlaceStatus.error,
          errorMessage: validationError,
        ),
      );
      return;
    }

    emit(state.copyWith(status: AddPlaceStatus.submitting));

    if (!state.isEditing) {
      await _submitNewPlace();
    } else if (!state.isApprovedPlace) {
      await _submitUnapprovedEdit();
    } else {
      await _submitApprovedEdit();
    }
  }

  Future<void> _submitNewPlace() async {
    final draft = PlaceDraft(
      name: state.name.trim(),
      categoryId: state.categoryId!,
      subCategory: state.subCategory,
      areaId: state.isOtherAreaSelected ? null : state.areaId,
      pendingAreaName: state.isOtherAreaSelected
          ? state.otherAreaName.trim()
          : null,
      address: state.address.trim(),
      phone: state.phone.trim(),
      whatsapp: _nullIfEmpty(state.whatsapp),
      googleMapsUrl: _nullIfEmpty(state.googleMapsUrl),
      description: _nullIfEmpty(state.description),
      openTime: state.is24Hours ? null : state.openTime,
      closeTime: state.is24Hours ? null : state.closeTime,
      closedDays: state.closedDays,
      is24Hours: state.is24Hours,
      isDelivery:
          deliveryCategories.contains(state.categoryId) && state.isDelivery,
    );

    final result = await _merchantRepository.addPlace(draft);
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: AddPlaceStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (placeId) async {
        var imageUploadFailed = false;

        final image = state.imageFile;
        if (image != null) {
          final uploadResult = await _merchantRepository.uploadPlaceImage(
            placeId: placeId,
            imageFile: image,
          );
          await uploadResult.fold(
            (failure) async {
              imageUploadFailed = true;
            },
            (url) async {
              final urlResult = await _merchantRepository.updatePlaceImageUrl(
                placeId: placeId,
                imageUrl: url,
              );
              await urlResult.fold((failure) async {
                imageUploadFailed = true;
              }, (_) async {});
            },
          );
        }

        await _storage.remove(draftKey);

        emit(
          state.copyWith(
            status: AddPlaceStatus.success,
            submittedPlaceId: placeId,
            imageUploadFailed: imageUploadFailed,
          ),
        );
      },
    );
  }

  Future<void> _submitUnapprovedEdit() async {
    final editingId = state.editingPlaceId!;

    final draft = PlaceDraft(
      name: state.name.trim(),
      categoryId: state.categoryId!,
      subCategory: state.subCategory,
      areaId: state.isOtherAreaSelected ? null : state.areaId,
      pendingAreaName: state.isOtherAreaSelected
          ? state.otherAreaName.trim()
          : null,
      address: state.address.trim(),
      phone: state.phone.trim(),
      whatsapp: _nullIfEmpty(state.whatsapp),
      googleMapsUrl: _nullIfEmpty(state.googleMapsUrl),
      description: _nullIfEmpty(state.description),
      openTime: state.is24Hours ? null : state.openTime,
      closeTime: state.is24Hours ? null : state.closeTime,
      closedDays: state.closedDays,
      is24Hours: state.is24Hours,
      isDelivery:
          deliveryCategories.contains(state.categoryId) && state.isDelivery,
    );

    final result = await _merchantRepository.updateUnapprovedPlace(
      placeId: editingId,
      draft: draft,
    );
    final failureMessage = result.fold(
      (failure) => failure.message,
      (_) => null,
    );
    if (failureMessage != null) {
      emit(
        state.copyWith(
          status: AddPlaceStatus.error,
          errorMessage: failureMessage,
        ),
      );
      return;
    }

    var imageUploadFailed = false;
    final image = state.imageFile;
    if (image != null) {
      final uploadResult = await _merchantRepository.uploadPlaceImage(
        placeId: editingId,
        imageFile: image,
      );
      await uploadResult.fold(
        (failure) async {
          imageUploadFailed = true;
        },
        (url) async {
          final urlResult = await _merchantRepository.updatePlaceImageUrl(
            placeId: editingId,
            imageUrl: url,
          );
          await urlResult.fold((failure) async {
            imageUploadFailed = true;
          }, (_) async {});
        },
      );
    }

    emit(
      state.copyWith(
        status: AddPlaceStatus.success,
        submittedPlaceId: editingId,
        imageUploadFailed: imageUploadFailed,
      ),
    );
  }

  Future<void> _submitApprovedEdit() async {
    final original = state.originalPlace!;
    final editingId = state.editingPlaceId!;

    final items = <PlaceChangeItem>[];
    final itemsToCancel = <String>[];

    final newDescription = _nullIfEmpty(state.description);
    if (newDescription != _nullIfEmpty(original.description)) {
      items.add(
        PlaceChangeItem(
          item: 'description',
          payload: {'description': newDescription},
        ),
      );
    } else if (state.pendingChanges.containsKey('description')) {
      itemsToCancel.add('description');
    }

    final newName = state.name.trim();
    final newPhone = state.phone.trim();
    final newWhatsapp = _nullIfEmpty(state.whatsapp);
    final newAddress = state.address.trim();
    final newGoogleMapsUrl = _nullIfEmpty(state.googleMapsUrl);
    final newIsDelivery =
        deliveryCategories.contains(state.categoryId) && state.isDelivery;

    final infoPayload = <String, dynamic>{};
    if (newName != original.name) infoPayload['name'] = newName;
    if (newPhone != original.phone) infoPayload['phone'] = newPhone;
    if (newWhatsapp != _nullIfEmpty(original.whatsapp)) {
      infoPayload['whatsapp'] = newWhatsapp;
    }
    if (newAddress != original.address) infoPayload['address'] = newAddress;
    if (newGoogleMapsUrl != _nullIfEmpty(original.googleMapsUrl)) {
      infoPayload['google_maps_url'] = newGoogleMapsUrl;
    }
    if (deliveryCategories.contains(state.categoryId) &&
        newIsDelivery != original.isDelivery) {
      infoPayload['is_delivery'] = newIsDelivery;
    }
    if (infoPayload.isNotEmpty) {
      items.add(PlaceChangeItem(item: 'info', payload: infoPayload));
    } else if (state.pendingChanges.containsKey('info')) {
      itemsToCancel.add('info');
    }

    final newClosedDays = state.closedDays.toSet();
    final originalClosedDays = original.closedDays.toSet();
    final closedDaysChanged =
        newClosedDays.length != originalClosedDays.length ||
        !newClosedDays.containsAll(originalClosedDays);
    final newOpenTime = state.is24Hours ? null : state.openTime;
    final newCloseTime = state.is24Hours ? null : state.closeTime;
    final hoursChanged =
        state.is24Hours != original.is24Hours ||
        newOpenTime != original.openTime ||
        newCloseTime != original.closeTime ||
        closedDaysChanged;
    if (hoursChanged) {
      items.add(
        PlaceChangeItem(
          item: 'hours',
          payload: {
            'open_time': newOpenTime,
            'close_time': newCloseTime,
            'closed_days': state.closedDays,
            'is_24_hours': state.is24Hours,
          },
        ),
      );
    } else if (state.pendingChanges.containsKey('hours')) {
      itemsToCancel.add('hours');
    }

    final image = state.imageFile;
    if (image != null) {
      final uploadResult = await _merchantRepository.uploadPlaceImage(
        placeId: editingId,
        imageFile: image,
      );
      final failureMessage = uploadResult.fold(
        (failure) => failure.message,
        (_) => null,
      );
      if (failureMessage != null) {
        emit(
          state.copyWith(
            status: AddPlaceStatus.error,
            errorMessage: failureMessage,
          ),
        );
        return;
      }
      final url = uploadResult.getOrElse(() => '');
      items.add(
        PlaceChangeItem(item: 'photo', payload: {'image_url': url}),
      );
    }

    if (items.isEmpty && itemsToCancel.isEmpty) {
      emit(
        state.copyWith(
          status: AddPlaceStatus.error,
          errorMessage: 'مفيش تعديلات عشان تتبعت',
        ),
      );
      return;
    }

    final result = await _merchantRepository.submitPlaceChangeBatch(
      placeId: editingId,
      items: items,
      itemsToCancel: itemsToCancel,
    );
    final failureMessage = result.fold(
      (failure) => failure.message,
      (_) => null,
    );
    if (failureMessage != null) {
      emit(
        state.copyWith(
          status: AddPlaceStatus.error,
          errorMessage: failureMessage,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AddPlaceStatus.success,
        submittedPlaceId: editingId,
      ),
    );
  }

  String? _nullIfEmpty(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  String? _validate() {
    if (state.name.trim().isEmpty) return 'اسم المكان مطلوب';
    if (state.categoryId == null) return 'اختار الكاتيجوري';

    final categoryId = state.categoryId!;
    final isSubCategoryCategory = subCategoryCategories.contains(categoryId);
    if (isSubCategoryCategory &&
        (state.subCategory == null || state.subCategory!.trim().isEmpty)) {
      return 'اختار النوع الفرعي أو اكتبه';
    }

    if (!state.isOtherAreaSelected && state.areaId == null) {
      return 'اختار المنطقة أو اكتب اسم منطقتك';
    }
    if (state.isOtherAreaSelected && state.otherAreaName.trim().isEmpty) {
      return 'اكتب اسم منطقتك';
    }

    if (state.address.trim().isEmpty) return 'العنوان مطلوب';

    if (!RegExp(_phonePattern).hasMatch(state.phone.trim())) {
      return 'رقم الموبايل غير صحيح (مثال: 01012345678)';
    }

    final whatsapp = state.whatsapp?.trim() ?? '';
    if (whatsapp.isNotEmpty && !RegExp(_phonePattern).hasMatch(whatsapp)) {
      return 'رقم الواتساب غير صحيح';
    }

    if (!state.is24Hours &&
        (state.openTime == null || state.closeTime == null)) {
      return 'حدد ميعاد الفتح والقفل مع بعض';
    }

    return null;
  }

  void _saveDraft() {
    if (state.isEditing) return;
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDebounce, () async {
      final json = jsonEncode({
        'name': state.name,
        'categoryId': state.categoryId,
        'subCategory': state.subCategory,
        'areaId': state.areaId,
        'isOtherAreaSelected': state.isOtherAreaSelected,
        'otherAreaName': state.otherAreaName,
        'address': state.address,
        'phone': state.phone,
        'whatsapp': state.whatsapp,
        'googleMapsUrl': state.googleMapsUrl,
        'description': state.description,
        'openTime': state.is24Hours ? null : state.openTime,
        'closeTime': state.is24Hours ? null : state.closeTime,
        'closedDays': state.closedDays,
        'is24Hours': state.is24Hours,
        'isDelivery': state.isDelivery,
        'imageFilePath': state.imageFile?.path,
      });
      await _storage.setString(draftKey, json);
    });
  }

  @override
  Future<void> close() {
    _saveTimer?.cancel();
    return super.close();
  }
}
