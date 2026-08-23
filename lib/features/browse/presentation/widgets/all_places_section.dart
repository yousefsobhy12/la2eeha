// lib/features/browse/presentation/widgets/all_places_section.dart
//
// 🔧 زرار "عرض كل الأماكن" هنا من غير رقم العدد الكلي (زي "(20)" في التصميم) —
// عشان جيبه محتاج count() query منفصلة، حبيت نسيبها بسيطة دلوقتي (MVP discipline).
// لو عايزها بالرقم قولّي أضيف الـ query.

import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/utils/coming_soon.dart';
import '../../../../core/widgets/place_card.dart';
import '../../domain/entities/place.dart';

class AllPlacesSection extends StatelessWidget {
  final List<Place> places;
  final String Function(int? categoryId) categoryNameOf;
  final String Function(int? categoryId) categoryIconOf;
  final String? Function(int? areaId) areaNameOf;

  const AllPlacesSection({
    super.key,
    required this.places,
    required this.categoryNameOf,
    required this.categoryIconOf,
    required this.areaNameOf,
  });

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        'TEST_9999_TEST'.toTitle(context, color: context.textPrimary),
        // context.smallSpacing.vSpace,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: places.length,
          separatorBuilder: (_, __) => context.smallSpacing.vSpace,
          itemBuilder: (context, index) {
            final place = places[index];
            return PlaceCard(
              place: place,
              categoryName: categoryNameOf(place.categoryId),
              categoryIcon: categoryIconOf(place.categoryId),
              areaName: areaNameOf(place.areaId),
              // Favorites لسه مش متبنية — هتتوصل هنا لما الـ feature تتبني
              isFavorite: false,
              onFavoriteToggle: null,
              onTap: () =>
                  showComingSoon(context), // PlaceDetailView لسه مش متبنية
            );
          },
        ),
        context.mediumSpacing.vSpace,
        Center(
          child: TextButton(
            onPressed: () =>
                showComingSoon(context), // CategoryListView لسه مش متبنية
            child: 'عرض كل الأماكن'.toBody(
              context,
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
