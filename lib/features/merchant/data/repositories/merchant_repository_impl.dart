import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/safe_supabase_call.dart';
import '../../domain/entities/branch_draft.dart';
import '../../domain/entities/editable_place.dart';
import '../../domain/entities/menu_item_draft.dart';
import '../../domain/entities/merchant_branch.dart';
import '../../domain/entities/my_place_item.dart';
import '../../domain/entities/my_place_summary.dart';
import '../../domain/entities/place_change_item.dart';
import '../../domain/entities/place_draft.dart';
import '../../domain/entities/sports_pricing_draft.dart';
import '../../domain/repositories/merchant_repository.dart';
import '../datasource/merchant_remote_datasource.dart';

class MerchantRepositoryImpl implements MerchantRepository {
  final MerchantRemoteDataSource remoteDataSource;

  MerchantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, int>> addPlace(PlaceDraft draft) {
    return safeSupabaseCall<int>(
      () => remoteDataSource.addPlace(draft),
      callName: 'MerchantRepository.addPlace',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }

  @override
  Future<Either<Failure, String>> uploadPlaceImage({
    required int placeId,
    required File imageFile,
  }) {
    return safeSupabaseCall<String>(
      () => remoteDataSource.uploadPlaceImage(
        placeId: placeId,
        imageFile: imageFile,
      ),
      callName: 'MerchantRepository.uploadPlaceImage',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }

  @override
  Future<Either<Failure, void>> updatePlaceImageUrl({
    required int placeId,
    required String imageUrl,
  }) {
    return safeSupabaseCall<void>(
      () => remoteDataSource.updatePlaceImageUrl(
        placeId: placeId,
        imageUrl: imageUrl,
      ),
      callName: 'MerchantRepository.updatePlaceImageUrl',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }

  @override
  Future<Either<Failure, MyPlaceSummary?>> getMyLatestPlace() {
    return safeSupabaseCall<MyPlaceSummary?>(
      () => remoteDataSource.getMyLatestPlace(),
      callName: 'MerchantRepository.getMyLatestPlace',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }

  @override
  Future<Either<Failure, List<MyPlaceItem>>> getMyPlaces() {
    return safeSupabaseCall<List<MyPlaceItem>>(
      () => remoteDataSource.getMyPlaces(),
      callName: 'MerchantRepository.getMyPlaces',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }

  @override
  Future<Either<Failure, bool>> isPlaceApproved({required int placeId}) {
    return safeSupabaseCall<bool>(
      () => remoteDataSource.isPlaceApproved(placeId),
      callName: 'MerchantRepository.isPlaceApproved',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }

  @override
  Future<Either<Failure, List<MerchantBranch>>> getMyBranches({
    required int placeId,
  }) {
    return safeSupabaseCall<List<MerchantBranch>>(
      () => remoteDataSource.getMyBranches(placeId),
      callName: 'MerchantRepository.getMyBranches',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }

  @override
  Future<Either<Failure, void>> addBranch({
    required int placeId,
    required BranchDraft draft,
  }) {
    return safeSupabaseCall<void>(
      () => remoteDataSource.addBranch(placeId: placeId, draft: draft),
      callName: 'MerchantRepository.addBranch',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
      onPostgrestException: _branchPostgrestFailure,
    );
  }

  @override
  Future<Either<Failure, void>> updateBranch({
    required int branchId,
    required BranchDraft draft,
  }) {
    return safeSupabaseCall<void>(
      () => remoteDataSource.updateBranch(branchId: branchId, draft: draft),
      callName: 'MerchantRepository.updateBranch',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
      onPostgrestException: _branchPostgrestFailure,
    );
  }

  @override
  Future<Either<Failure, void>> deleteBranch({required int branchId}) {
    return safeSupabaseCall<void>(
      () => remoteDataSource.deleteBranch(branchId: branchId),
      callName: 'MerchantRepository.deleteBranch',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }

  @override
  Future<Either<Failure, void>> replaceMenuItems({
    required int placeId,
    required List<MenuItemDraft> items,
  }) {
    return safeSupabaseCall<void>(
      () => remoteDataSource.replaceMenuItems(placeId, items),
      callName: 'MerchantRepository.replaceMenuItems',
    );
  }

  @override
  Future<Either<Failure, void>> replaceSportsPricing({
    required int placeId,
    required List<SportsPricingDraft> items,
  }) {
    return safeSupabaseCall<void>(
      () => remoteDataSource.replaceSportsPricing(placeId, items),
      callName: 'MerchantRepository.replaceSportsPricing',
    );
  }

  @override
  Future<Either<Failure, void>> submitPendingMenuItems({
    required int placeId,
    required List<MenuItemDraft> items,
  }) {
    return safeSupabaseCall<void>(
      () => remoteDataSource.submitPendingMenuItems(placeId, items),
      callName: 'MerchantRepository.submitPendingMenuItems',
    );
  }

  @override
  Future<Either<Failure, void>> submitPendingSportsPricing({
    required int placeId,
    required List<SportsPricingDraft> items,
  }) {
    return safeSupabaseCall<void>(
      () => remoteDataSource.submitPendingSportsPricing(placeId, items),
      callName: 'MerchantRepository.submitPendingSportsPricing',
    );
  }

  @override
  Future<Either<Failure, List<MenuItemDraft>?>> getPendingMenuItems({
    required int placeId,
  }) {
    return safeSupabaseCall<List<MenuItemDraft>?>(
      () => remoteDataSource.getPendingMenuItems(placeId),
      callName: 'MerchantRepository.getPendingMenuItems',
    );
  }

  @override
  Future<Either<Failure, List<SportsPricingDraft>?>>
  getPendingSportsPricing({required int placeId}) {
    return safeSupabaseCall<List<SportsPricingDraft>?>(
      () => remoteDataSource.getPendingSportsPricing(placeId),
      callName: 'MerchantRepository.getPendingSportsPricing',
    );
  }

  @override
  Future<Either<Failure, EditablePlace>> getEditablePlace({
    required int placeId,
  }) {
    return safeSupabaseCall<EditablePlace>(
      () => remoteDataSource.getEditablePlace(placeId),
      callName: 'MerchantRepository.getEditablePlace',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }

  @override
  Future<Either<Failure, Map<String, Map<String, dynamic>>>>
  getPendingPlaceChanges({required int placeId}) {
    return safeSupabaseCall<Map<String, Map<String, dynamic>>>(
      () => remoteDataSource.getPendingPlaceChanges(placeId),
      callName: 'MerchantRepository.getPendingPlaceChanges',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }

  @override
  Future<Either<Failure, void>> submitPlaceChangeBatch({
    required int placeId,
    required List<PlaceChangeItem> items,
    List<String> itemsToCancel = const [],
  }) {
    return safeSupabaseCall<void>(
      () => remoteDataSource.submitPlaceChangeBatch(
        placeId,
        items,
        itemsToCancel,
      ),
      callName: 'MerchantRepository.submitPlaceChangeBatch',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }

  @override
  Future<Either<Failure, void>> updateUnapprovedPlace({
    required int placeId,
    required PlaceDraft draft,
  }) {
    return safeSupabaseCall<void>(
      () => remoteDataSource.updateUnapprovedPlace(placeId, draft),
      callName: 'MerchantRepository.updateUnapprovedPlace',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }
}

Failure _branchPostgrestFailure(PostgrestException e) {
  if (e.code == '23514') {
    if (e.message.contains('violates check constraint')) {
      return const ServerFailure(
        'بيانات الفرع غير صحيحة، راجع العنوان والتليفون والرابط',
      );
    }
    return const ServerFailure('وصلت للحد الأقصى: ١٠ فروع للمكان');
  }
  return ServerFailure(e.message);
}
