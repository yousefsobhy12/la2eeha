import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/safe_supabase_call.dart';
import '../../domain/entities/area.dart';
import '../../domain/entities/branch.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_event.dart';
import '../../domain/entities/place_filters.dart';
import '../../domain/entities/promotion.dart';
import '../../domain/entities/sports_pricing.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasource/places_remote_datasource.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesRemoteDataSource remoteDataSource;

  PlacesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Category>>> getCategories() {
    return safeSupabaseCall(
      () => remoteDataSource.getCategories(),
      callName: 'getCategories',
    );
  }

  @override
  Future<Either<Failure, List<Area>>> getAreas() {
    return safeSupabaseCall(
      () => remoteDataSource.getAreas(),
      callName: 'getAreas',
    );
  }

  @override
  Future<Either<Failure, List<Place>>> getMostVisitedPreview({int limit = 10}) {
    return safeSupabaseCall(
      () => remoteDataSource.getMostVisitedPreview(limit: limit),
      callName: 'getMostVisitedPreview',
    );
  }

  @override
  Future<Either<Failure, List<Place>>> getAllPlacesPreview({int limit = 10}) {
    return safeSupabaseCall(
      () => remoteDataSource.getAllPlacesPreview(limit: limit),
      callName: 'getAllPlacesPreview',
    );
  }

  @override
  Future<Either<Failure, List<Promotion>>> getLivePromotions() {
    return safeSupabaseCall(
      () => remoteDataSource.getLivePromotions(),
      callName: 'getLivePromotions',
    );
  }

  @override
  Future<Either<Failure, List<Place>>> getCategoryPlaces({
    int? categoryId,
    String? subCategory,
    PlaceFilters filters = const PlaceFilters(),
    required int limit,
    required int offset,
  }) {
    return safeSupabaseCall(
      () => remoteDataSource.getCategoryPlaces(
        categoryId: categoryId,
        subCategory: subCategory,
        filters: filters,
        limit: limit,
        offset: offset,
      ),
      callName: 'getCategoryPlaces',
    );
  }

  @override
  Future<Either<Failure, List<String>>> getSubCategories(int categoryId) {
    return safeSupabaseCall(
      () => remoteDataSource.getSubCategories(categoryId),
      callName: 'getSubCategories',
    );
  }

  @override
  Future<Either<Failure, int>> getCategoryPlacesCount({
    int? categoryId,
    String? subCategory,
    PlaceFilters filters = const PlaceFilters(),
  }) {
    return safeSupabaseCall(
      () => remoteDataSource.getCategoryPlacesCount(
        categoryId: categoryId,
        subCategory: subCategory,
        filters: filters,
      ),
      callName: 'getCategoryPlacesCount',
    );
  }

  @override
  Future<Either<Failure, Place>> getPlaceDetails(int placeId) {
    return safeSupabaseCall(
      () => remoteDataSource.getPlaceDetails(placeId),
      callName: 'getPlaceDetails',
    );
  }

  @override
  Future<Either<Failure, List<MenuItem>>> getMenuItems(int placeId) {
    return safeSupabaseCall(
      () => remoteDataSource.getMenuItems(placeId),
      callName: 'getMenuItems',
    );
  }

  @override
  Future<Either<Failure, List<Branch>>> getBranches(int placeId) {
    return safeSupabaseCall(
      () => remoteDataSource.getBranches(placeId),
      callName: 'getBranches',
    );
  }

  @override
  Future<Either<Failure, List<SportsPricing>>> getSportsPricing(int placeId) {
    return safeSupabaseCall(
      () => remoteDataSource.getSportsPricing(placeId),
      callName: 'getSportsPricing',
    );
  }

  @override
  Future<Either<Failure, List<Place>>> getSimilarPlaces({
    required int categoryId,
    required int areaId,
    required int excludePlaceId,
    int limit = 6,
  }) {
    return safeSupabaseCall(
      () => remoteDataSource.getSimilarPlaces(
        categoryId: categoryId,
        areaId: areaId,
        excludePlaceId: excludePlaceId,
        limit: limit,
      ),
      callName: 'getSimilarPlaces',
    );
  }

  @override
  Future<Either<Failure, List<Place>>> getPlacesByIds(List<int> ids) {
    if (ids.isEmpty) {
      return Future.value(const Right([]));
    }
    return safeSupabaseCall(
      () => remoteDataSource.getPlacesByIds(ids),
      callName: 'getPlacesByIds',
    );
  }

  @override
  Future<Either<Failure, List<Place>>> searchPlaces({
    required String query,
    List<int> areaIds = const [],
    PlaceFilters filters = const PlaceFilters(),
    required int limit,
    required int offset,
  }) {
    return safeSupabaseCall(
      () => remoteDataSource.searchPlaces(
        query: query,
        areaIds: areaIds,
        filters: filters,
        limit: limit,
        offset: offset,
      ),
      callName: 'searchPlaces',
    );
  }

  @override
  Future<Either<Failure, int>> getSearchResultsCount({
    required String query,
    List<int> areaIds = const [],
    PlaceFilters filters = const PlaceFilters(),
  }) {
    return safeSupabaseCall(
      () => remoteDataSource.getSearchResultsCount(
        query: query,
        areaIds: areaIds,
        filters: filters,
      ),
      callName: 'getSearchResultsCount',
    );
  }

  @override
  Future<Either<Failure, void>> trackPlaceEvent({
    required int placeId,
    required PlaceEvent event,
  }) {
    return safeSupabaseCall<void>(
      () =>
          remoteDataSource.trackPlaceEvent(placeId: placeId, event: event.name),
      callName: 'trackPlaceEvent',
    );
  }
}
