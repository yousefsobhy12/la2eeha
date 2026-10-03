// lib/features/browse/data/datasource/places_remote_datasource.dart
//
// دي الطبقة الوحيدة اللي فعليًا بتكلم Supabase مباشرة.
// بترجع Models (مش entities) لأنها لسه في الـ data layer.
// الـ exceptions (PostgrestException, AuthException...) بتطلع naturally
// من هنا — الـ safeSupabaseCall في الـ Repository هو اللي بيمسكها.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/extensions/search_normalizer_extension.dart';
import '../models/area_model.dart';
import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import '../models/place_model.dart';
import '../models/promotion_model.dart';
import '../models/sports_pricing_model.dart';

class PlacesRemoteDataSource {
  Future<List<CategoryModel>> getCategories() async {
    final response = await supabase.from('categories').select();
    return (response as List)
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }

  Future<List<AreaModel>> getAreas() async {
    final response = await supabase
        .from('areas')
        .select('id, name_ar, name_en');
    return (response as List).map((json) => AreaModel.fromJson(json)).toList();
  }

  Future<List<PlaceModel>> getMostVisitedPreview({int limit = 10}) async {
    final response = await supabase
        .from('places')
        .select()
        .order('view_count', ascending: false)
        .limit(limit);
    return (response as List).map((json) => PlaceModel.fromJson(json)).toList();
  }

  Future<List<PlaceModel>> getAllPlacesPreview({int limit = 10}) async {
    final response = await supabase
        .from('places')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return (response as List).map((json) => PlaceModel.fromJson(json)).toList();
  }

  // العروض الترويجية: مفيش فلترة بالتاريخ ولا بـ is_active هنا — سياسات
  // الـ RLS في Supabase بترجّع الصفوف الحيّة بس، فالـ query بيبقى نضيف.
  Future<List<PromotionModel>> getLivePromotions() async {
    final response = await supabase
        .from('promotions')
        .select('place_id, slot, image_url')
        .order('slot')
        .limit(6);
    return (response as List)
        .map((json) => PromotionModel.fromJson(json))
        .toList();
  }

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
        .eq('place_id', placeId)
        .order('sort_order', ascending: true);
    return (response as List)
        .map((json) => MenuItemModel.fromJson(json))
        .toList();
  }

  Future<List<SportsPricingModel>> getSportsPricing(int placeId) async {
    final response = await supabase
        .from('sports_pricing')
        .select()
        .eq('place_id', placeId)
        .order('sort_order', ascending: true);
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

  // بيبني شرط الـ or() بتاع البحث على العمود المُطبَّع search_text (اسم + عنوان،
  // مطبَّع في الـ DB بـ normalize_arabic()). كل كلمة في الـ query لازم تكون
  // موجودة (AND)، + (لو موجودة) المناطق المطابقة.
  // areaIds بتتحسب في الـ Cubit من كاش محلي — مفيش أي query إضافية هنا.
  String _buildSearchFilter(List<String> words, List<int> areaIds) {
    final wordFilters = [for (final w in words) 'search_text.ilike.%$w%'];
    var filter = wordFilters.length == 1
        ? wordFilters.first
        : 'and(${wordFilters.join(",")})';
    if (areaIds.isNotEmpty) {
      filter += ',area_id.in.(${areaIds.join(",")})';
    }
    return filter;
  }

  Future<List<PlaceModel>> searchPlaces({
    required String query,
    List<int> areaIds = const [],
    required int limit,
    required int offset,
  }) async {
    final words = query.toSearchWords();
    if (words.isEmpty) return [];
    final filter = _buildSearchFilter(words, areaIds);

    final response = await supabase
        .from('places')
        .select()
        .or(filter)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) => PlaceModel.fromJson(json)).toList();
  }

  Future<int> getSearchResultsCount({
    required String query,
    List<int> areaIds = const [],
  }) async {
    final words = query.toSearchWords();
    if (words.isEmpty) return 0;
    final filter = _buildSearchFilter(words, areaIds);

    final response = await supabase
        .from('places')
        .select()
        .or(filter)
        .count(CountOption.exact);
    return response.count;
  }

  // تسجيل حدث على المكان — call خام بيرمي على أي error (زي باقي الميثودز)
  // والـ safeSupabaseCall في الـ Repository هو اللي بيمسكه ويسجّله.
  Future<void> trackPlaceEvent({
    required int placeId,
    required String event,
  }) async {
    await supabase.rpc(
      'track_place_event',
      params: {'p_place_id': placeId, 'p_event': event},
    );
  }
}
