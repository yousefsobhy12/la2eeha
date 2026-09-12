// lib/features/merchant/data/datasource/merchant_remote_datasource.dart
//
// دي الطبقة الوحيدة اللي فعليًا بتكلم Supabase مباشرة (جداول places + بكت
// place-images). الـ exceptions (PostgrestException, AuthException...) بتطلع
// naturally من هنا — الـ safeSupabaseCall في الـ Repository هو اللي بيمسكها.

import 'dart:io';

import '../../../../core/network/supabase_client_provider.dart';
import '../../domain/entities/place_draft.dart';

class MerchantRemoteDataSource {
  Future<int> addPlace(PlaceDraft draft) async {
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
          'open_time': draft.openTime,
          'close_time': draft.closeTime,
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
        .update({'image_url': imageUrl}).eq('id', placeId);
  }
}