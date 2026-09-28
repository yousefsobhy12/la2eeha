// lib/features/merchant/data/datasource/merchant_remote_datasource.dart
//
// دي الطبقة الوحيدة اللي فعليًا بتكلم Supabase مباشرة (جداول places + بكت
// place-images). الـ exceptions (PostgrestException, AuthException...) بتطلع
// naturally من هنا — الـ safeSupabaseCall في الـ Repository هو اللي بيمسكها.

import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../domain/entities/menu_item_draft.dart';
import '../../domain/entities/my_place_summary.dart';
import '../../domain/entities/place_draft.dart';
import '../../domain/entities/sports_pricing_draft.dart';

class MerchantRemoteDataSource {
  Future<int> addPlace(PlaceDraft draft) async {
    // لو المكان ٢٤ ساعة، الأوقات بتتضرب null مهما كان الـ state القديم في
    // الفورم — ساعات العمل بتبقى محسوبة من is_24_hours بس.
    final openTime = draft.is24Hours ? null : draft.openTime;
    final closeTime = draft.is24Hours ? null : draft.closeTime;

    final response = await supabase
        .from('places')
        .insert({
          'owner_id': supabase.auth.currentUser!.id,
          'is_approved': false,
          'category_id': draft.categoryId,
          'sub_category': draft.subCategory,
          'area_id': draft.areaId,
          'pending_area_name': draft.pendingAreaName,
          'name': draft.name,
          'address': draft.address,
          'phone': draft.phone,
          'whatsapp': draft.whatsapp,
          'google_maps_url': draft.googleMapsUrl,
          'description': draft.description,
          'is_24_hours': draft.is24Hours,
          'open_time': openTime,
          'close_time': closeTime,
          'closed_days': draft.closedDays,
        })
        .select('id')
        .single();

    return response['id'] as int;
  }

  /// بترفع الصورة في بكت place-images. الـ path لازم يبدأ بـ auth.uid()
  /// كأول folder segment عشان RLS storage policy تشيله — أي شكل تاني
  /// هيترفض. بنرجع الـ public URL النهائي.
  Future<String> uploadPlaceImage({
    required int placeId,
    required File imageFile,
  }) async {
    final path =
        '${supabase.auth.currentUser!.id}/${placeId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage.from('place-images').upload(path, imageFile);

    return supabase.storage.from('place-images').getPublicUrl(path);
  }

  Future<void> updatePlaceImageUrl({
    required int placeId,
    required String imageUrl,
  }) async {
    await supabase
        .from('places')
        .update({'image_url': imageUrl})
        .eq('id', placeId);
  }

  /// أحدث place للتاجر الحالي (بالترتيب الزمني) — null لو مفيش أي place.
  Future<MyPlaceSummary?> getMyLatestPlace() async {
    final response = await supabase
        .from('places')
        .select('id,name,category_id,sub_category,is_approved')
        .eq('owner_id', supabase.auth.currentUser!.id)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;

    return MyPlaceSummary(
      id: response['id'] as int,
      name: response['name'] as String,
      categoryId: response['category_id'] as int,
      subCategory: response['sub_category'] as String?,
      isApproved: response['is_approved'] as bool,
    );
  }

  /// حالة الموافقة الحالية لمكان مملوك للتاجر الحالي.
  Future<bool> isPlaceApproved(int placeId) async {
    final response = await supabase
        .from('places')
        .select('is_approved')
        .eq('id', placeId)
        .eq('owner_id', supabase.auth.currentUser!.id)
        .single();
    return response['is_approved'] as bool;
  }

  /// بيمسح كل عناصر المنيو الموجودة للمكان وبيعمل insert جديد للقائمة الحالية.
  /// لو القائمة فاضية، بيمسح بس من غير insert. السطر اللي بيحفظ فيه
  /// sort_order (ترتيب العنصر الحالي في القائمة) عشان ترتيب العرض يتثبّت.
  Future<void> replaceMenuItems(int placeId, List<MenuItemDraft> items) async {
    await supabase.from('menu_items').delete().eq('place_id', placeId);
    if (items.isEmpty) return;
    await supabase.from('menu_items').insert([
      for (final item in items)
        {
          'place_id': placeId,
          'name': item.name,
          'price': item.price,
          'description': item.description,
          'sort_order': item.sortOrder,
        },
    ]);
  }

  /// بيمسح كل فترات التسعير الموجودة للمكان وبيعمل insert جديد.
  /// TimeOfDay بيتحول لـ "HH:mm:00" (نفس format الـ open_time/close_time).
  Future<void> replaceSportsPricing(
    int placeId,
    List<SportsPricingDraft> items,
  ) async {
    await supabase.from('sports_pricing').delete().eq('place_id', placeId);
    if (items.isEmpty) return;
    await supabase.from('sports_pricing').insert([
      for (final item in items)
        {
          'place_id': placeId,
          'start_time': _timeToHhMmSs(item.startTime),
          'end_time': _timeToHhMmSs(item.endTime),
          'price': item.price,
          'description': item.description,
          'sort_order': item.sortOrder,
        },
    ]);
  }

  String _timeToHhMmSs(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }
}
