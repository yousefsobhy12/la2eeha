import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/extensions/digits_extension.dart';
import '../../../../core/network/app_logger.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../domain/entities/branch_draft.dart';
import '../../domain/entities/editable_place.dart';
import '../../domain/entities/menu_item_draft.dart';
import '../../domain/entities/merchant_branch.dart';
import '../../domain/entities/my_place_item.dart';
import '../../domain/entities/my_place_summary.dart';
import '../../domain/entities/place_change_item.dart';
import '../../domain/entities/place_change_result.dart';
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

  Future<List<MyPlaceItem>> getMyPlaces() async {
    final rows = await supabase
        .from('places')
        .select('id,name,category_id,sub_category,is_approved,rejection_reason')
        .eq('owner_id', supabase.auth.currentUser!.id)
        .order('created_at', ascending: false);
    if (rows.isEmpty) return [];
    final ids = [for (final r in rows) r['id'] as int];

    List<Map<String, dynamic>> changeRows;
    try {
      changeRows = await supabase
          .from('place_change_requests')
          .select(
            'place_id,batch_id,item,status,rejection_reason,created_at',
          )
          .inFilter('place_id', ids);
    } catch (e) {
      appLogger.w('Failed to load place review results: $e');
      return [
        for (final r in rows)
          MyPlaceItem(
            id: r['id'] as int,
            name: r['name'] as String,
            categoryId: r['category_id'] as int,
            subCategory: r['sub_category'] as String?,
            isApproved: r['is_approved'] == true,
            rejectionReason: r['rejection_reason'] as String?,
            hasPendingChanges: false,
          ),
      ];
    }

    final pendingPlaceIds = <int>{};
    final latestBatchIdByPlace = <int, String>{};
    final latestCreatedAtByPlace = <int, DateTime>{};

    for (final r in changeRows) {
      final placeId = r['place_id'] as int;
      if (r['status'] == 'pending') pendingPlaceIds.add(placeId);

      final batchId = r['batch_id'] as String?;
      final createdAt = DateTime.tryParse('${r['created_at']}');
      if (batchId == null || createdAt == null) continue;

      final latest = latestCreatedAtByPlace[placeId];
      if (latest == null || createdAt.isAfter(latest)) {
        latestCreatedAtByPlace[placeId] = createdAt;
        latestBatchIdByPlace[placeId] = batchId;
      }
    }

    final reviewResultsByPlace = <int, List<PlaceChangeResult>>{};
    for (final r in changeRows) {
      final placeId = r['place_id'] as int;
      if (latestBatchIdByPlace[placeId] != r['batch_id']) continue;

      final status = _placeChangeStatus(r['status'] as String?);
      final item = r['item'] as String?;
      if (status == null || item == null || !_knownPlaceChangeItems.contains(item)) {
        continue;
      }

      reviewResultsByPlace.putIfAbsent(placeId, () => []).add(
        PlaceChangeResult(
          item: item,
          status: status,
          rejectionReason: status == PlaceChangeStatus.rejected
              ? r['rejection_reason'] as String?
              : null,
        ),
      );
    }

    return [
      for (final r in rows)
        MyPlaceItem(
          id: r['id'] as int,
          name: r['name'] as String,
          categoryId: r['category_id'] as int,
          subCategory: r['sub_category'] as String?,
          isApproved: r['is_approved'] == true,
          rejectionReason: r['rejection_reason'] as String?,
          hasPendingChanges: pendingPlaceIds.contains(r['id'] as int),
          reviewResults: reviewResultsByPlace[r['id'] as int] ?? const [],
        ),
    ];
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

  Future<List<MerchantBranch>> getMyBranches(int placeId) async {
    final rows = await supabase
        .from('branches')
        .select(
          'id,address,google_maps_link,phone,title,description,is_approved',
        )
        .eq('place_id', placeId)
        .order('created_at', ascending: true);
    return [
      for (final r in rows)
        MerchantBranch(
          id: r['id'] as int,
          address: r['address'] as String,
          googleMapsLink: _normalizeBranchText(r['google_maps_link'] as String?),
          phone: _normalizeBranchText(r['phone'] as String?),
          title: _normalizeBranchText(r['title'] as String?),
          description: _normalizeBranchText(r['description'] as String?),
          isApproved: r['is_approved'] == true,
        ),
    ];
  }

  Future<void> addBranch({
    required int placeId,
    required BranchDraft draft,
  }) async {
    await supabase.from('branches').insert({
      'place_id': placeId,
      'address': draft.address.trim(),
      'google_maps_link': _normalizeBranchText(draft.googleMapsLink),
      'phone': _normalizeBranchText(draft.phone?.toWesternDigits()),
      'title': _normalizeBranchText(draft.title),
      'description': _normalizeBranchText(draft.description),
    });
  }

  Future<void> updateBranch({
    required int branchId,
    required BranchDraft draft,
  }) async {
    await supabase
        .from('branches')
        .update({
          'address': draft.address.trim(),
          'google_maps_link': _normalizeBranchText(draft.googleMapsLink),
          'phone': _normalizeBranchText(draft.phone?.toWesternDigits()),
          'title': _normalizeBranchText(draft.title),
          'description': _normalizeBranchText(draft.description),
        })
        .eq('id', branchId);
  }

  Future<void> deleteBranch({required int branchId}) async {
    await supabase.from('branches').delete().eq('id', branchId);
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
    await _replacePendingRequest(
      placeId: placeId,
      item: 'menu',
      payload: [
        for (final item in items)
          {
            'name': item.name,
            'price': item.price,
            'description': item.description,
            'sort_order': item.sortOrder,
          },
      ],
    );
  }

  Future<void> submitPendingSportsPricing(
    int placeId,
    List<SportsPricingDraft> items,
  ) async {
    await _replacePendingRequest(
      placeId: placeId,
      item: 'sports',
      payload: [
        for (final item in items)
          {
            'start_time': _timeToHhMmSs(item.startTime),
            'end_time': _timeToHhMmSs(item.endTime),
            'price': item.price,
            'description': item.description,
            'sort_order': item.sortOrder,
          },
      ],
    );
  }

  Future<List<MenuItemDraft>?> getPendingMenuItems(int placeId) async {
    final payload = await _getPendingPayload(placeId, 'menu');
    if (payload == null) return null;
    return [
      for (var index = 0; index < payload.length; index++)
        _menuItemFromPayload(payload[index] as Map<String, dynamic>, index),
    ];
  }

  Future<List<SportsPricingDraft>?> getPendingSportsPricing(
    int placeId,
  ) async {
    final payload = await _getPendingPayload(placeId, 'sports');
    if (payload == null) return null;
    return [
      for (var index = 0; index < payload.length; index++)
        _sportsDraftFromPayload(payload[index] as Map<String, dynamic>, index),
    ];
  }

  Future<void> _replacePendingRequest({
    required int placeId,
    required String item,
    required List<Map<String, dynamic>> payload,
  }) async {
    await supabase
        .from('place_change_requests')
        .delete()
        .eq('place_id', placeId)
        .eq('item', item)
        .eq('status', 'pending');
    await supabase.from('place_change_requests').insert({
      'place_id': placeId,
      'item': item,
      'payload': payload,
    });
  }

  Future<List<dynamic>?> _getPendingPayload(int placeId, String item) async {
    final response = await supabase
        .from('place_change_requests')
        .select('payload')
        .eq('place_id', placeId)
        .eq('item', item)
        .eq('status', 'pending')
        .maybeSingle();
    if (response == null) return null;
    return response['payload'] as List<dynamic>? ?? const [];
  }

  Future<EditablePlace> getEditablePlace(int placeId) async {
    final response = await supabase
        .from('places')
        .select(
          'id,name,category_id,sub_category,area_id,pending_area_name,address,phone,whatsapp,google_maps_url,description,open_time,close_time,closed_days,is_24_hours,is_delivery,image_url,is_approved,rejection_reason',
        )
        .eq('id', placeId)
        .eq('owner_id', supabase.auth.currentUser!.id)
        .single();
    return EditablePlace(
      id: response['id'] as int,
      name: response['name'] as String,
      categoryId: response['category_id'] as int,
      subCategory: response['sub_category'] as String?,
      areaId: response['area_id'] as int?,
      pendingAreaName: response['pending_area_name'] as String?,
      address: response['address'] as String,
      phone: response['phone'] as String,
      whatsapp: response['whatsapp'] as String?,
      googleMapsUrl: response['google_maps_url'] as String?,
      description: response['description'] as String?,
      openTime: response['open_time'] as String?,
      closeTime: response['close_time'] as String?,
      closedDays: [
        for (final day
            in (response['closed_days'] as List<dynamic>? ?? const []))
          day as int,
      ],
      is24Hours: response['is_24_hours'] == true,
      isDelivery: response['is_delivery'] == true,
      imageUrl: response['image_url'] as String?,
      isApproved: response['is_approved'] == true,
      rejectionReason: response['rejection_reason'] as String?,
    );
  }

  Future<Map<String, Map<String, dynamic>>> getPendingPlaceChanges(
    int placeId,
  ) async {
    final rows = await supabase
        .from('place_change_requests')
        .select('item,payload')
        .eq('place_id', placeId)
        .eq('status', 'pending')
        .inFilter('item', ['info', 'description', 'photo', 'hours']);
    return {
      for (final r in rows)
        r['item'] as String: r['payload'] as Map<String, dynamic>,
    };
  }

  Future<void> submitPlaceChangeBatch(
    int placeId,
    List<PlaceChangeItem> items,
    List<String> itemsToCancel,
  ) async {
    if (items.isEmpty && itemsToCancel.isEmpty) return;
    final allItems = [
      for (final i in items) i.item,
      ...itemsToCancel,
    ];
    await supabase
        .from('place_change_requests')
        .delete()
        .eq('place_id', placeId)
        .eq('status', 'pending')
        .inFilter('item', allItems);
    if (items.isEmpty) return;
    final batchId = const Uuid().v4();
    await supabase.from('place_change_requests').insert([
      for (final i in items)
        {
          'place_id': placeId,
          'batch_id': batchId,
          'item': i.item,
          'payload': i.payload,
        },
    ]);
  }

  Future<void> updateUnapprovedPlace(int placeId, PlaceDraft draft) async {
    final openTime = draft.is24Hours ? null : draft.openTime;
    final closeTime = draft.is24Hours ? null : draft.closeTime;
    await supabase
        .from('places')
        .update({
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
          'rejection_reason': null,
        })
        .eq('id', placeId);
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

  String? _normalizeBranchText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  TimeOfDay _parseHhMmSs(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }
}

const _knownPlaceChangeItems = {
  'info',
  'description',
  'photo',
  'hours',
  'menu',
  'sports',
};

PlaceChangeStatus? _placeChangeStatus(String? value) {
  switch (value) {
    case 'pending':
      return PlaceChangeStatus.pending;
    case 'approved':
      return PlaceChangeStatus.approved;
    case 'rejected':
      return PlaceChangeStatus.rejected;
    default:
      return null;
  }
}
