// lib/features/browse/data/datasources/places_remote_datasource.dart
//
// دي الطبقة الوحيدة اللي فعليًا بتكلم Supabase مباشرة.
// بترجع Models (مش entities) لأنها لسه في الـ data layer.

import '../../../../core/network/supabase_client_provider.dart';
import '../models/category_model.dart';
import '../models/place_model.dart';

class PlacesRemoteDataSource {
  // كل الكاتيجوريز - مفيش limit، عددهم صغير (7 بس)
  Future<List<CategoryModel>> getCategories() async {
    final response = await supabase.from('categories').select();

    return (response as List)
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }

  // قسم "الأكثر زيارة" - مرتب حسب view_count تنازليًا
  Future<List<PlaceModel>> getMostVisitedPreview() async {
    final response = await supabase
        .from('places')
        .select()
        .order('view_count', ascending: false)
        .limit(10);

    return (response as List)
        .map((json) => PlaceModel.fromJson(json))
        .toList();
  }

  // قسم "كل الأماكن" preview - مرتب بالأحدث
  Future<List<PlaceModel>> getAllPlacesPreview() async {
    final response = await supabase
        .from('places')
        .select()
        .order('created_at', ascending: false)
        .limit(10);

    return (response as List)
        .map((json) => PlaceModel.fromJson(json))
        .toList();
  }
}