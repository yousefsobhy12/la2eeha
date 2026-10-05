// lib/features/merchant/presentation/cubit/add_place_state.dart
//
// حالة واحدة فيها كل حاجة — copyWith بنفس شكل AddPlaceCubit المقاصة.
// الـ _unset sentinel ضروري عشان نقدر نمسح الـ nullable fields (مثلاً
// removeImage بيمسح imageFile خالص) — لو استخدمنا `??` ببساطة ماكنش
// ينفع نرجّع أي حاجة لـ null.

import 'dart:io';

import '../../../browse/domain/entities/area.dart';
import '../../../browse/domain/entities/category.dart';

class _Unset {
  const _Unset();
}

const Object _unset = _Unset();

enum AddPlaceStatus {
  initial,
  loadingFormData,
  ready,
  submitting,
  success,
  error,
}

class AddPlaceState {
  final AddPlaceStatus status;

  /// رسالة الخطأ — متبقاش null وقت الفشل (تحميل الفورم أو الـ submit)
  final String? errorMessage;

  final List<Category> categories;
  final List<Area> areas;

  // ── form fields ──
  final String name;
  final int? categoryId;
  final String? subCategory;
  final int? areaId;
  final bool isOtherAreaSelected;
  final String otherAreaName;
  final String address;
  final String phone;
  final String? whatsapp;
  final String? googleMapsUrl;
  final String? description;
  final String? openTime;
  final String? closeTime;
  final List<int> closedDays;

  /// لو التاجر فعّل "يعمل ٢٤ ساعة" — الأوقات بتبقى ماسحة (لو كان فيها حاجة)
  /// والعرض بيخفي حقول الساعات.
  final bool is24Hours;

  /// لو التاجر فعّل "متاح توصيل" — بيظهر بس للأقسام اللي بتسمح بيه
  /// (AddPlaceCubit.deliveryCategories).
  final bool isDelivery;

  final File? imageFile;
  final bool imageUploadFailed;

  /// الـ id اللي رجعه addPlace بعد submit ناجح — بيستخدم في شاشة النجاح
  /// عشان التاجر يتنقل لشاشة المنيو/الأسعار بتاعة البيزنس الجديد.
  final int? submittedPlaceId;

  const AddPlaceState({
    this.status = AddPlaceStatus.initial,
    this.errorMessage,
    this.categories = const [],
    this.areas = const [],
    this.name = '',
    this.categoryId,
    this.subCategory,
    this.areaId,
    this.isOtherAreaSelected = false,
    this.otherAreaName = '',
    this.address = '',
    this.phone = '',
    this.whatsapp,
    this.googleMapsUrl,
    this.description,
    this.openTime,
    this.closeTime,
    this.closedDays = const [],
    this.is24Hours = false,
    this.isDelivery = false,
    this.imageFile,
    this.imageUploadFailed = false,
    this.submittedPlaceId,
  });

  bool get isFormReady =>
      status == AddPlaceStatus.ready && categories.isNotEmpty;

  AddPlaceState copyWith({
    AddPlaceStatus? status,
    Object? errorMessage = _unset,
    List<Category>? categories,
    List<Area>? areas,
    String? name,
    Object? categoryId = _unset,
    Object? subCategory = _unset,
    Object? areaId = _unset,
    bool? isOtherAreaSelected,
    String? otherAreaName,
    String? address,
    String? phone,
    Object? whatsapp = _unset,
    Object? googleMapsUrl = _unset,
    Object? description = _unset,
    Object? openTime = _unset,
    Object? closeTime = _unset,
    List<int>? closedDays,
    bool? is24Hours,
    bool? isDelivery,
    Object? imageFile = _unset,
    bool? imageUploadFailed,
    Object? submittedPlaceId = _unset,
  }) {
    return AddPlaceState(
      status: status ?? this.status,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      categories: categories ?? this.categories,
      areas: areas ?? this.areas,
      name: name ?? this.name,
      categoryId: categoryId == _unset ? this.categoryId : categoryId as int?,
      subCategory: subCategory == _unset
          ? this.subCategory
          : subCategory as String?,
      areaId: areaId == _unset ? this.areaId : areaId as int?,
      isOtherAreaSelected: isOtherAreaSelected ?? this.isOtherAreaSelected,
      otherAreaName: otherAreaName ?? this.otherAreaName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      whatsapp: whatsapp == _unset ? this.whatsapp : whatsapp as String?,
      googleMapsUrl: googleMapsUrl == _unset
          ? this.googleMapsUrl
          : googleMapsUrl as String?,
      description: description == _unset
          ? this.description
          : description as String?,
      openTime: openTime == _unset ? this.openTime : openTime as String?,
      closeTime: closeTime == _unset ? this.closeTime : closeTime as String?,
      closedDays: closedDays ?? this.closedDays,
      is24Hours: is24Hours ?? this.is24Hours,
      isDelivery: isDelivery ?? this.isDelivery,
      imageFile: imageFile == _unset ? this.imageFile : imageFile as File?,
      imageUploadFailed: imageUploadFailed ?? this.imageUploadFailed,
      submittedPlaceId: submittedPlaceId == _unset
          ? this.submittedPlaceId
          : submittedPlaceId as int?,
    );
  }
}
