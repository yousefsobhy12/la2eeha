import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/safe_supabase_call.dart';
import '../../domain/entities/menu_item_draft.dart';
import '../../domain/entities/my_place_item.dart';
import '../../domain/entities/my_place_summary.dart';
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
}
