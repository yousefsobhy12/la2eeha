import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/area.dart';
import '../entities/category.dart';
import '../entities/menu_item.dart';
import '../entities/place.dart';
import '../entities/sports_pricing.dart';

abstract class PlacesRepository {
  // كل الكاتيجوريز (7 بس، مفيش داعي لـ pagination هنا)
  Future<Either<Failure, List<Category>>> getCategories();

  // كل المناطق
  Future<Either<Failure, List<Area>>> getAreas();

  // قسم "الأكثر زيارة" في الهوم - LIMIT محدود، مرتب حسب view_count
  Future<Either<Failure, List<Place>>> getMostVisitedPreview({int limit});

  // قسم "كل الأماكن" preview في الهوم - LIMIT محدود، مرتب بالأحدث
  Future<Either<Failure, List<Place>>> getAllPlacesPreview({int limit});

  // أماكن كاتيجوري معينة (أو كل الأماكن لو categoryId = null) مع pagination
  Future<Either<Failure, List<Place>>> getCategoryPlaces({
    int? categoryId,
    String? subCategory,
    required int limit,
    required int offset,
  });

  // الـ sub_category values الفعلية الموجودة لكاتيجوري معينة
  Future<Either<Failure, List<String>>> getSubCategories(int categoryId);

  // عدد الأماكن الكلي (لنفس الفلاتر بتاعت getCategoryPlaces)
  Future<Either<Failure, int>> getCategoryPlacesCount({
    int? categoryId,
    String? subCategory,
  });

  // تفاصيل مكان معين بالـ id
  Future<Either<Failure, Place>> getPlaceDetails(int placeId);

  // قائمة المنيو والأسعار
  Future<Either<Failure, List<MenuItem>>> getMenuItems(int placeId);

  // أسعار الملاعب والرياضة
  Future<Either<Failure, List<SportsPricing>>> getSportsPricing(int placeId);

  // أماكن مشابهة في نفس الكاتيجوري والمنطقة
  Future<Either<Failure, List<Place>>> getSimilarPlaces({
    required int categoryId,
    required int areaId,
    required int excludePlaceId,
    int limit = 6,
  });
}
