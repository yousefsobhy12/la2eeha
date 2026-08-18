import '../entities/category.dart';
import '../entities/place.dart';

abstract class PlacesRepository {
  // كل الكاتيجوريز (7 بس، مفيش داعي لـ pagination هنا)
  Future<List<Category>> getCategories();

  // قسم "الأكثر زيارة" في الهوم - LIMIT محدود، مرتب حسب view_count
  Future<List<Place>> getMostVisitedPreview();

  // قسم "كل الأماكن" preview في الهوم - LIMIT محدود، مرتب بالأحدث
  Future<List<Place>> getAllPlacesPreview();
}