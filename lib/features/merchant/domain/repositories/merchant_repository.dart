// lib/features/merchant/domain/repositories/merchant_repository.dart

import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/place_draft.dart';

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
}