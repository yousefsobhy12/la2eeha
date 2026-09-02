// lib/features/browse/presentation/widgets/most_visited_section.dart
//
// 🔧 الكاروسيل الأفقي بقى ListView.separated بدل SingleChildScrollView > Row —
// بيبني الكروت lazily (on-demand) وبيستخدم SizedBox بارتفاع صريح من
// context.mostVisitedCarouselHeight. العنوان + الكاروسيل ملفوفين في Column
// عادية عشان يتحطوا جوه SliverToBoxAdapter في HomeView.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:la2eeha/core/theme/app_fonts.dart';
import '../../../../core/extensions/extensions.dart';
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
        'الأكثر زيارة'.toTitle(
          context,
          color: context.textPrimary,
          fontFamily: AppFonts.reemKufi,
        ),
        context.mediumSpacing.vSpace,
        SizedBox(
          height: context.mostVisitedCarouselHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: places.length,
            separatorBuilder: (_, _) => context.smallSpacing.hSpace,
            itemBuilder: (context, index) {
              return MostVisitedCard(
                place: places[index],
                categoryName: categoryNameOf(places[index].categoryId),
                categoryIcon: categoryIconOf(places[index].categoryId),
                rank: index + 1,
                onTap: () => context.push('/place/${places[index].id}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
