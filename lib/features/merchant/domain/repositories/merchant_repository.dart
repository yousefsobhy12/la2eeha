// lib/features/merchant/domain/repositories/merchant_repository.dart

import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/menu_item_draft.dart';
import '../entities/my_place_summary.dart';
import '../entities/place_draft.dart';
import '../entities/sports_pricing_draft.dart';

abstract class MerchantRepository {
  Future<Either<Failure, int>> addPlace(PlaceDraft draft);

  Future<Either<Failure, String>> uploadPlaceImage({
    required int placeId,
    required File imageFile,
  });

  Future<Either<Failure, void>> updatePlaceImageUrl({
    required int placeId,
    required String imageUrl,
  });

  /// أحدث place (بالأسئلة الأحدث) للتاجر الحالي — null لو مفيش أي place.
  Future<Either<Failure, MyPlaceSummary?>> getMyLatestPlace();

  /// حالة الموافقة الحالية لمكان مملوك للتاجر الحالي — بيستخدم في بانر
  /// "قيد المراجعة" وشاشة الحالة.
  Future<Either<Failure, bool>> isPlaceApproved({required int placeId});

  Future<Either<Failure, void>> replaceMenuItems({
    required int placeId,
    required List<MenuItemDraft> items,
  });

  Future<Either<Failure, void>> replaceSportsPricing({
    required int placeId,
    required List<SportsPricingDraft> items,
  });
}
