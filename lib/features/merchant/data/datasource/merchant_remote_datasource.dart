import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../domain/entities/menu_item_draft.dart';
import '../../domain/entities/my_place_summary.dart';
import '../../domain/entities/place_draft.dart';
import '../../domain/entities/sports_pricing_draft.dart';

class MerchantRemoteDataSource {
  Future<int> addPlace(PlaceDraft draft) async {
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
          'is_delivery': draft.isDelivery,
          'open_time': openTime,
          'close_time': closeTime,
          'closed_days': draft.closedDays,
        })
        .select('id')
        .single();

    return response['id'] as int;
  }

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

  Future<bool> isPlaceApproved(int placeId) async {
    final response = await supabase
        .from('places')
        .select('is_approved')
        .eq('id', placeId)
        .eq('owner_id', supabase.auth.currentUser!.id)
        .single();
    return response['is_approved'] as bool;
  }

  Future<void> replaceMenuItems(int placeId, List<MenuItemDraft> items) async {
    final old = await supabase
        .from('menu_items')
        .select('id')
        .eq('place_id', placeId);
    if (items.isNotEmpty) {
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
    if (old.isNotEmpty) {
      await supabase
          .from('menu_items')
          .delete()
          .inFilter('id', old.map((r) => r['id']).toList());
    }
  }

  Future<void> replaceSportsPricing(
    int placeId,
    List<SportsPricingDraft> items,
  ) async {
    final old = await supabase
        .from('sports_pricing')
        .select('id')
        .eq('place_id', placeId);
    if (items.isNotEmpty) {
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
    if (old.isNotEmpty) {
      await supabase
          .from('sports_pricing')
          .delete()
          .inFilter('id', old.map((r) => r['id']).toList());
    }
  }

  Future<void> submitPendingMenuItems(
    int placeId,
    List<MenuItemDraft> items,
  ) async {
    await supabase.from('pending_pricing_changes').upsert(
      {
        'place_id': placeId,
        'kind': 'menu',
        'payload': [
          for (final item in items)
            {
              'name': item.name,
              'price': item.price,
              'description': item.description,
              'sort_order': item.sortOrder,
            },
        ],
        'created_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'place_id,kind',
    );
  }

  Future<void> submitPendingSportsPricing(
    int placeId,
    List<SportsPricingDraft> items,
  ) async {
    await supabase.from('pending_pricing_changes').upsert(
      {
        'place_id': placeId,
        'kind': 'sports',
        'payload': [
          for (final item in items)
            {
              'start_time': _timeToHhMmSs(item.startTime),
              'end_time': _timeToHhMmSs(item.endTime),
              'price': item.price,
              'description': item.description,
              'sort_order': item.sortOrder,
            },
        ],
        'created_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'place_id,kind',
    );
  }

  Future<List<MenuItemDraft>?> getPendingMenuItems(int placeId) async {
    final response = await supabase
        .from('pending_pricing_changes')
        .select('payload')
        .eq('place_id', placeId)
        .eq('kind', 'menu')
        .maybeSingle();

    if (response == null) return null;

    final payload = response['payload'] as List<dynamic>? ?? const [];
    return [
      for (var index = 0; index < payload.length; index++)
        _menuItemFromPayload(payload[index] as Map<String, dynamic>, index),
    ];
  }

  Future<List<SportsPricingDraft>?> getPendingSportsPricing(
    int placeId,
  ) async {
    final response = await supabase
        .from('pending_pricing_changes')
        .select('payload')
        .eq('place_id', placeId)
        .eq('kind', 'sports')
        .maybeSingle();

    if (response == null) return null;

    final payload = response['payload'] as List<dynamic>? ?? const [];
    return [
      for (var index = 0; index < payload.length; index++)
        _sportsDraftFromPayload(payload[index] as Map<String, dynamic>, index),
    ];
  }

  MenuItemDraft _menuItemFromPayload(Map<String, dynamic> raw, int index) {
    return MenuItemDraft(
      localKey: 'p$index',
      name: raw['name'] as String,
      price: (raw['price'] as num).toDouble(),
      description: raw['description'] as String?,
      sortOrder: (raw['sort_order'] as num?)?.toInt() ?? index,
    );
  }

  SportsPricingDraft _sportsDraftFromPayload(
    Map<String, dynamic> raw,
    int index,
  ) {
    return SportsPricingDraft(
      localKey: 'p$index',
      startTime: _parseHhMmSs(raw['start_time'] as String),
      endTime: _parseHhMmSs(raw['end_time'] as String),
      price: (raw['price'] as num).toDouble(),
      description: raw['description'] as String?,
      sortOrder: (raw['sort_order'] as num?)?.toInt() ?? index,
    );
  }

  String _timeToHhMmSs(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  TimeOfDay _parseHhMmSs(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
