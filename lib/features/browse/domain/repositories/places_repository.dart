import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/area.dart';
import '../entities/category.dart';
import '../entities/menu_item.dart';
import '../entities/place.dart';
import '../entities/place_event.dart';
import '../entities/promotion.dart';
import '../entities/sports_pricing.dart';

abstract class PlacesRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, List<Area>>> getAreas();
  Future<Either<Failure, List<Place>>> getMostVisitedPreview({int limit});
  Future<Either<Failure, List<Place>>> getAllPlacesPreview({int limit});

  // العروض الترويجية الحيّة بس — الفلترة بتاعت التاريخ والحالة
  // بتتعمل في سياسات الـ RLS على مستوى الداتابيز.
  Future<Either<Failure, List<Promotion>>> getLivePromotions();
  Future<Either<Failure, List<Place>>> getCategoryPlaces({
    int? categoryId,
    String? subCategory,
    required int limit,
    required int offset,
  });
  Future<Either<Failure, List<String>>> getSubCategories(int categoryId);
  Future<Either<Failure, int>> getCategoryPlacesCount({
    int? categoryId,
    String? subCategory,
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

  // بحث عن الأماكن بالاسم أو العنوان أو المنطقة، مع pagination.
  // areaIds بتتحسب في الـ Cubit من الكاش الموجود عنده أصلاً (مفيش query إضافية هنا).
  Future<Either<Failure, List<Place>>> searchPlaces({
    required String query,
    List<int> areaIds,
    required int limit,
    required int offset,
  });

  Future<Either<Failure, int>> getSearchResultsCount({
    required String query,
    List<int> areaIds,
  });

  /// تسجيل حدث على المكان (مشاهدة/اتصال/واتساب) عن طريق RPC في الداتابيز.
  /// الاستدعاء بيتبعت fire-and-forget — أي فشل بيتسجّل في اللوج بس ومش
  /// بيظهر للمستخدم، فالـ UI بيتجاهل الـ result.
  Future<Either<Failure, void>> trackPlaceEvent({
    required int placeId,
    required PlaceEvent event,
  });
}
