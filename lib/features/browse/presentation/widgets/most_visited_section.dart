// lib/features/browse/presentation/widgets/most_visited_section.dart

import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/utils/coming_soon.dart';
import '../../domain/entities/place.dart';
import 'most_visited_card.dart';

class MostVisitedSection extends StatelessWidget {
  final List<Place> places;
  final String Function(int? categoryId) categoryNameOf;
  final String Function(int? categoryId) categoryIconOf;

  const MostVisitedSection({
    super.key,
    required this.places,
    required this.categoryNameOf,
    required this.categoryIconOf,
  });

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        'الأكثر زيارة'.toTitle(context, color: context.textPrimary),
        context.smallSpacing.vSpace,
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: places.length,
            separatorBuilder: (_, __) => 10.hSpace,
            itemBuilder: (context, index) {
              final place = places[index];
              return MostVisitedCard(
                place: place,
                categoryName: categoryNameOf(place.categoryId),
                categoryIcon: categoryIconOf(place.categoryId),
                rank: index + 1,
                onTap: () => showComingSoon(context), // PlaceDetailView لسه مش متبنية
              );
            },
          ),
        ),
      ],
    );
  }
}
