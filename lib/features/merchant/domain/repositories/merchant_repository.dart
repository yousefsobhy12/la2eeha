import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/branch_draft.dart';
import '../entities/editable_place.dart';
import '../entities/menu_item_draft.dart';
import '../entities/merchant_branch.dart';
import '../entities/my_place_item.dart';
import '../entities/my_place_summary.dart';
import '../entities/place_change_item.dart';
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

  Future<Either<Failure, MyPlaceSummary?>> getMyLatestPlace();

  Future<Either<Failure, List<MyPlaceItem>>> getMyPlaces();

  Future<Either<Failure, bool>> isPlaceApproved({required int placeId});

  Future<Either<Failure, List<MerchantBranch>>> getMyBranches({
    required int placeId,
  });

  Future<Either<Failure, void>> addBranch({
    required int placeId,
    required BranchDraft draft,
  });

  Future<Either<Failure, void>> updateBranch({
    required int branchId,
    required BranchDraft draft,
  });

  Future<Either<Failure, void>> deleteBranch({required int branchId});

  Future<Either<Failure, void>> replaceMenuItems({
    required int placeId,
    required List<MenuItemDraft> items,
  });

  Future<Either<Failure, void>> replaceSportsPricing({
    required int placeId,
    required List<SportsPricingDraft> items,
  });

  Future<Either<Failure, void>> submitPendingMenuItems({
    required int placeId,
    required List<MenuItemDraft> items,
  });

  Future<Either<Failure, void>> submitPendingSportsPricing({
    required int placeId,
    required List<SportsPricingDraft> items,
  });

  Future<Either<Failure, List<MenuItemDraft>?>> getPendingMenuItems({
    required int placeId,
  });

  Future<Either<Failure, List<SportsPricingDraft>?>> getPendingSportsPricing({
    required int placeId,
  });

  Future<Either<Failure, EditablePlace>> getEditablePlace({
    required int placeId,
  });

  Future<Either<Failure, Map<String, Map<String, dynamic>>>>
  getPendingPlaceChanges({required int placeId});

  Future<Either<Failure, void>> submitPlaceChangeBatch({
    required int placeId,
    required List<PlaceChangeItem> items,
    List<String> itemsToCancel = const [],
  });

  Future<Either<Failure, void>> updateUnapprovedPlace({
    required int placeId,
    required PlaceDraft draft,
  });
}
