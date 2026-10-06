import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/area.dart';
import '../entities/category.dart';
import '../entities/menu_item.dart';
import '../entities/place.dart';
import '../entities/place_event.dart';
import '../entities/place_filters.dart';
import '../entities/promotion.dart';
import '../entities/sports_pricing.dart';

abstract class PlacesRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, List<Area>>> getAreas();
  Future<Either<Failure, List<Place>>> getMostVisitedPreview({int limit});
  Future<Either<Failure, List<Place>>> getAllPlacesPreview({int limit});

  Future<Either<Failure, List<Promotion>>> getLivePromotions();
  Future<Either<Failure, List<Place>>> getCategoryPlaces({
    int? categoryId,
    String? subCategory,
    PlaceFilters filters = const PlaceFilters(),
    required int limit,
    required int offset,
  });
  Future<Either<Failure, List<String>>> getSubCategories(int categoryId);
  Future<Either<Failure, int>> getCategoryPlacesCount({
    int? categoryId,
    String? subCategory,
    PlaceFilters filters = const PlaceFilters(),
  });
  Future<Either<Failure, Place>> getPlaceDetails(int placeId);
  Future<Either<Failure, List<MenuItem>>> getMenuItems(int placeId);
  Future<Either<Failure, List<SportsPricing>>> getSportsPricing(int placeId);
  Future<Either<Failure, List<Place>>> getSimilarPlaces({
    required int categoryId,
    required int areaId,
    required int excludePlaceId,
    int limit = 6,
  });
  Future<Either<Failure, List<Place>>> getPlacesByIds(List<int> ids);

  Future<Either<Failure, List<Place>>> searchPlaces({
    required String query,
    List<int> areaIds,
    PlaceFilters filters = const PlaceFilters(),
    required int limit,
    required int offset,
  });

  Future<Either<Failure, int>> getSearchResultsCount({
    required String query,
    List<int> areaIds,
    PlaceFilters filters = const PlaceFilters(),
  });

  Future<Either<Failure, void>> trackPlaceEvent({
    required int placeId,
    required PlaceEvent event,
  });
}
