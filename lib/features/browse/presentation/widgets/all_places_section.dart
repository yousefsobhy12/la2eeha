// lib/features/browse/presentation/widgets/all_places_section.dart
//
// 🔧 بقى plain Dart class بدل StatelessWidget — بيرجع List<Widget> من slivers
// عشان HomeView تنشرهم (spread) في قايمة slivers بتاعت الـ CustomScrollView.
// لو places فاضية بيرجع قايمة فاضية (مفيش slivers).
//
// 🔧 زرار "عرض كل الأماكن" هنا من غير رقم العدد الكلي (زي "(20)" في التصميم) —
// عشان جيبه محتاج count() query منفصلة، حبيت نسيبها بسيطة دلوقتي (MVP discipline).
// لو عايزها بالرقم قولّي أضيف الـ query.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:la2eeha/core/theme/app_fonts.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/widgets/place_card.dart';
import '../../domain/entities/place.dart';

class AllPlacesSection {
  final List<Place> places;
  final String Function(int? categoryId) categoryNameOf;
  final String Function(int? categoryId) categoryIconOf;
  final String? Function(int? areaId) areaNameOf;

  const AllPlacesSection({
    required this.places,
    required this.categoryNameOf,
    required this.categoryIconOf,
    required this.areaNameOf,
  });

  /// بيرجع قايمة slivers — فاضية لو مفيش أماكن.
  List<Widget> buildSlivers(BuildContext context) {
    if (places.isEmpty) return const [];

    return [
      // 1) عنوان القسم
      SliverToBoxAdapter(
        child: 'كل الأماكن'.toTitle(
          context,
          color: context.textPrimary,
          fontFamily: AppFonts.reemKufi,
        ),
      ),

      // 2) قايمة الأماكن
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final place = places[index];
          return Padding(
            padding: EdgeInsets.only(
              top: context.mediumSpacing,
              bottom: context.smallSpacing,
            ),
            child:
                PlaceCard(
                  place: place,
                  categoryName: categoryNameOf(place.categoryId),
                  categoryIcon: categoryIconOf(place.categoryId),
                  areaName: areaNameOf(place.areaId),
                  // Favorites لسه مش متبنية — هتتوصل هنا لما الـ feature تتبني
                  isFavorite: false,
                  onFavoriteToggle: null,
                  onTap: () => context.push('/place/${place.id}'),
                ).fadeSlideIn(
                  delay: AppAnimations.stagger(
                    index,
                    base: const Duration(milliseconds: 180),
                  ),
                ),
          );
        }, childCount: places.length),
      ),

      // 3) زرار "عرض كل الأماكن" + النص التحتاني
      SliverToBoxAdapter(
        child: Column(
          children: [
            context.mediumSpacing.vSpace,
            Center(
              child: TextButton(
                onPressed: () => context.push('/places'),
                child: 'عرض كل الأماكن'.toBody(
                  context,
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            context.largeSpacing.vSpace,
            Center(
              child: 'كل البيانات من أصحاب الأماكن — لو لقيت خطأ بلّغنا'
                  .toCaption(context, color: context.textSecondary),
            ),
          ],
        ),
      ),
    ];
  }
}
