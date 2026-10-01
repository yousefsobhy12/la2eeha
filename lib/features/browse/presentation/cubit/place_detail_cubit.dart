import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/app_logger.dart';
import '../../../../core/storage/daily_event_gate.dart';
import '../../domain/entities/area.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_event.dart';
import '../../domain/entities/sports_pricing.dart';
import '../../domain/repositories/places_repository.dart';
import 'place_detail_state.dart';

class PlaceDetailCubit extends Cubit<PlaceDetailState> {
  final PlacesRepository repository;
  final int placeId;

  /// بوابة الـ 24 ساعة — عشان المشاهدة متتحسبش مع كل فتح/refresh.
  final DailyEventGate viewGate;

  /// اتسجلت مشاهدة واحدة بس لكل فتح للشاشة — عشان الـ refresh مايعيدش
  /// Count++ على نفس الزيارة.
  bool _viewTracked = false;

  PlaceDetailCubit(
    this.repository, {
    required this.placeId,
    required this.viewGate,
  }) : super(const PlaceDetailLoading());

  Future<void> loadPlaceDetails() async {
    emit(const PlaceDetailLoading());

    // 1. جلب تفاصيل المكان أولاً للحصول على categoryId / subCategory / areaId
    final placeEither = await repository.getPlaceDetails(placeId);
    if (placeEither.isLeft()) {
      final failure = placeEither.fold((f) => f, (_) => null)!;
      emit(PlaceDetailError(failure));
      return;
    }

    final place = placeEither.getOrElse(() => throw StateError('Unreachable'));

    // تحديد نوع جدول الأسعار مباشرة بناءً على subCategory
    final usesSportsPricing = ['football', 'padel'].contains(place.subCategory);

    // 2. إطلاق باقي الطلبات بالتوازي عبر Future.wait
    final results = await Future.wait([
      repository.getCategories(),
      repository.getAreas(),
      place.areaId != null
          ? repository.getSimilarPlaces(
              categoryId: place.categoryId,
              areaId: place.areaId!,
              excludePlaceId: place.id,
            )
          : Future.value(const Right<Failure, List<Place>>([])),
      usesSportsPricing
          ? repository.getSportsPricing(placeId)
          : repository.getMenuItems(placeId),
    ]);

    final categoriesEither = results[0] as Either<Failure, List<Category>>;
    final areasEither = results[1] as Either<Failure, List<Area>>;
    final similarPlacesEither = results[2] as Either<Failure, List<Place>>;
    final pricingEither = results[3];

    // فشل الكاتيجوريز أو المناطق يوقف الشاشة (بيانات أساسية)
    if (categoriesEither.isLeft()) {
      final failure = categoriesEither.fold((f) => f, (_) => null)!;
      emit(PlaceDetailError(failure));
      return;
    }

    if (areasEither.isLeft()) {
      final failure = areasEither.fold((f) => f, (_) => null)!;
      emit(PlaceDetailError(failure));
      return;
    }

    final categories = categoriesEither.getOrElse(() => []);
    final areas = areasEither.getOrElse(() => []);

    final matchedCategory = categories
        .where((c) => c.id == place.categoryId)
        .firstOrNull;
    final categoryName = matchedCategory?.nameAr ?? '';
    final categoryIcon = matchedCategory?.icon ?? '';

    final matchedArea = areas.where((a) => a.id == place.areaId).firstOrNull;
    final areaName = matchedArea?.nameAr;

    // فشل الأماكن المشابهة أو الأسعار ثانوي ولا يوقف الشاشة
    final similarPlaces = similarPlacesEither.fold((failure) {
      appLogger.w('Failed to load similar places: ${failure.message}');
      return <Place>[];
    }, (places) => places);

    List<SportsPricing>? sportsPricing;
    List<MenuItem>? menuItems;

    if (usesSportsPricing) {
      final either = pricingEither as Either<Failure, List<SportsPricing>>;
      sportsPricing = either.fold((failure) {
        appLogger.w('Failed to load sports pricing: ${failure.message}');
        return <SportsPricing>[];
      }, (items) => items);
    } else {
      final either = pricingEither as Either<Failure, List<MenuItem>>;
      menuItems = either.fold((failure) {
        appLogger.w('Failed to load menu items: ${failure.message}');
        return <MenuItem>[];
      }, (items) => items);
    }

    emit(
      PlaceDetailLoaded(
        place: place,
        categoryName: categoryName,
        categoryIcon: categoryIcon,
        areaName: areaName,
        menuItems: menuItems,
        sportsPricing: sportsPricing,
        similarPlaces: similarPlaces,
      ),
    );

    unawaited(_trackViewOnce());
  }

  Future<void> refresh() => loadPlaceDetails();

  // ميثودز التتبع دي كلها fire-and-forget بالتصميم: النتيجة متتجاهلوش
  // والنجاح/الفشل ميوصلش للـ UI — الـ safeSupabaseCall بيعمل اللوج.

  /// مشاهدة واحدة بس لكل فتح للشاشة، وبعد كده واحدة كل 24 ساعة بالـ gate.
  Future<void> _trackViewOnce() async {
    if (_viewTracked) return;
    _viewTracked = true;
    final shouldCount = await viewGate.shouldCount('view:$placeId');
    if (!shouldCount) return;
    unawaited(
      repository.trackPlaceEvent(placeId: placeId, event: PlaceEvent.view),
    );
  }

  void trackCall() => unawaited(
    repository.trackPlaceEvent(placeId: placeId, event: PlaceEvent.call),
  );

  void trackWhatsapp() => unawaited(
    repository.trackPlaceEvent(placeId: placeId, event: PlaceEvent.whatsapp),
  );
}
