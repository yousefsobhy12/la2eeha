// lib/features/browse/data/datasource/places_remote_datasource.dart
//
// دي الطبقة الوحيدة اللي فعليًا بتكلم Supabase مباشرة.
// بترجع Models (مش entities) لأنها لسه في الـ data layer.
// لو حصل خطأ من Supabase، بنرمي ServerException — الـ Repository هو اللي بيمسكها
// ويحولها لـ Failure المناسب.

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../models/area_model.dart';
import '../models/category_model.dart';
import '../models/place_model.dart';

class PlacesRemoteDataSource {
  // كل الكاتيجوريز - مفيش limit، عددهم صغير (7 بس)
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await supabase.from('categories').select();

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // كل المناطق - مفيش limit، عددهم صغير (11 بس)
  Future<List<AreaModel>> getAreas() async {
    try {
      final response =
          await supabase.from('areas').select('id, name_ar, name_en');

      return (response as List)
          .map((json) => AreaModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // قسم "الأكثر زيارة" - مرتب حسب view_count تنازليًا
  Future<List<PlaceModel>> getMostVisitedPreview({int limit = 10}) async {
    try {
      final response = await supabase
          .from('places')
          .select()
          .order('view_count', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => PlaceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // قسم "كل الأماكن" preview - مرتب بالأحدث
  Future<List<PlaceModel>> getAllPlacesPreview({int limit = 10}) async {
    try {
      final response = await supabase
          .from('places')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => PlaceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}