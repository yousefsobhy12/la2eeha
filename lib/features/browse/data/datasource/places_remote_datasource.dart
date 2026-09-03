// lib/features/browse/data/datasource/places_remote_datasource.dart
//
// دي الطبقة الوحيدة اللي فعليًا بتكلم Supabase مباشرة.
// بترجع Models (مش entities) لأنها لسه في الـ data layer.
// الـ exceptions (PostgrestException, AuthException...) بتطلع naturally
// من هنا — الـ safeSupabaseCall في الـ Repository هو اللي بيمسكها.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../models/area_model.dart';
import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import '../models/place_model.dart';
import '../models/sports_pricing_model.dart';

class PlacesRemoteDataSource {
  // كل الكاتيجوريز - مفيش limit، عددهم صغير (7 بس)
  Future<List<CategoryModel>> getCategories() async {
    final response = await supabase.from('categories').select();

    return (response as List)
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }

  // كل المناطق - مفيش limit، عددهم صغير (11 بس)
  Future<List<AreaModel>> getAreas() async {
    final response = await supabase
        .from('areas')
        .select('id, name_ar, name_en');

    return (response as List).map((json) => AreaModel.fromJson(json)).toList();
  }

  // قسم "الأكثر زيارة" - مرتب حسب view_count تنازليًا
  Future<List<PlaceModel>> getMostVisitedPreview({int limit = 10}) async {
    final response = await supabase
        .from('places')
        .select()
        .order('view_count', ascending: false)
        .limit(limit);

    return (response as List).map((json) => PlaceModel.fromJson(json)).toList();
  }

  // قسم "كل الأماكن" preview - مرتب بالأحدث
  Future<List<PlaceModel>> getAllPlacesPreview({int limit = 10}) async {
    final response = await supabase
        .from('places')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => PlaceModel.fromJson(json)).toList();
  }

  // أماكن كاتيجوري معينة (أو كل الأماكن) مع pagination وفلترة sub_category
  Future<List<PlaceModel>> getCategoryPlaces({
    int? categoryId,
    String? subCategory,
    required int limit,
    required int offset,
  }) async {
    var query = supabase.from('places').select();
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    if (subCategory != null) {
      query = query.eq('sub_category', subCategory);
    }
    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => PlaceModel.fromJson(json)).toList();
  }

  // الـ sub_category values الفعلية لكاتيجوري معينة
  Future<List<String>> getSubCategories(int categoryId) async {
    final response = await supabase
        .from('places')
        .select('sub_category')
        .eq('category_id', categoryId)
        .not('sub_category', 'is', null);

    final unique = (response as List)
        .map((json) => json['sub_category'] as String)
        .toSet()
        .toList();
    unique.sort();
    return unique;
  }

  // العدد الكلي للأماكن بنفس الفلاتر
  Future<int> getCategoryPlacesCount({
    int? categoryId,
    String? subCategory,
  }) async {
    var query = supabase.from('places').select();
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    if (subCategory != null) {
      query = query.eq('sub_category', subCategory);
    }
    final response = await query.count(CountOption.exact);
    return response.count;
  }

  Future<PlaceModel> getPlaceDetails(int placeId) async {
    final response = await supabase
        .from('places')
        .select()
        .eq('id', placeId)
        .single();
    return PlaceModel.fromJson(response);
  }

  Future<List<MenuItemModel>> getMenuItems(int placeId) async {
    final response = await supabase
        .from('menu_items')
        .select()
        .eq('place_id', placeId);
    return (response as List)
        .map((json) => MenuItemModel.fromJson(json))
        .toList();
  }

  Future<List<SportsPricingModel>> getSportsPricing(int placeId) async {
    final response = await supabase
        .from('sports_pricing')
        .select()
        .eq('place_id', placeId)
        .order('start_time');
    return (response as List)
        .map((json) => SportsPricingModel.fromJson(json))
        .toList();
  }

  Future<List<PlaceModel>> getSimilarPlaces({
    required int categoryId,
    required int areaId,
    required int excludePlaceId,
    int limit = 6,
  }) async {
    final response = await supabase
        .from('places')
        .select()
        .eq('category_id', categoryId)
        .eq('area_id', areaId)
        .neq('id', excludePlaceId)
        .limit(limit);
    return (response as List).map((json) => PlaceModel.fromJson(json)).toList();
  }

  Future<List<PlaceModel>> getPlacesByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final response = await supabase.from('places').select().inFilter('id', ids);

    return (response as List).map((json) => PlaceModel.fromJson(json)).toList();
  }
}
