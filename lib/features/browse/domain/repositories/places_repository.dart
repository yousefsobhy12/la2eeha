import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/area.dart';
import '../entities/category.dart';
import '../entities/place.dart';

abstract class PlacesRepository {
  // كل الكاتيجوريز (7 بس، مفيش داعي لـ pagination هنا)
  Future<Either<Failure, List<Category>>> getCategories();

  // كل المناطق
  Future<Either<Failure, List<Area>>> getAreas();

  // قسم "الأكثر زيارة" في الهوم - LIMIT محدود، مرتب حسب view_count
  Future<Either<Failure, List<Place>>> getMostVisitedPreview({int limit});

  // قسم "كل الأماكن" preview في الهوم - LIMIT محدود، مرتب بالأحدث
  Future<Either<Failure, List<Place>>> getAllPlacesPreview({int limit});
}