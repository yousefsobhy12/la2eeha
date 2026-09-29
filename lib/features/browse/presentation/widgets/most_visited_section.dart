// lib/features/browse/presentation/widgets/most_visited_section.dart
//
// 🔧 القسم بقى sliver (SliverMainAxisGroup) بدل Column يتلف في
// SliverToBoxAdapter — عشان HomeView يحطّه مباشرة في قايمة الـ slivers من غير
// كلفة SliverToBoxAdapter. كل عنصر = PlaceCard (نفس الكارت المستخدم في
// "كل الأماكن") مع بادج الترتيب للأول 3.
//
// 🔧 أول 5 أماكن بس بتظهر في البداية، وزرار "عرض الكل" بيوسّع الباقي
// على طول. الـ stagger بيحسب على الـ index الحقيقي (مش المعروض)، عشان
// الترتيب يفضل متدرّج.
//
// 👌 الترجمة (PlaceCard + زر المفضّلة + animation) زي ما هي في
// AllPlacesSection — هنا بقى vertical/list مش horizontal carousel.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:la2eeha/core/theme/app_fonts.dart';
import 'package:la2eeha/features/favorites/presentation/cubit/favorites_cubit.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/widgets/place_card.dart';
import '../../domain/entities/place.dart';

class MostVisitedSection extends StatefulWidget {
  final List<Place> places;
  final String Function(int? categoryId) categoryNameOf;
  final String Function(int? categoryId) categoryIconOf;
  final String? Function(int? areaId) areaNameOf;

  const MostVisitedSection({
    super.key,
    required this.places,
    required this.categoryNameOf,
    required this.categoryIconOf,
    required this.areaNameOf,
  });

  @override
  State<MostVisitedSection> createState() => _MostVisitedSectionState();
}

class _MostVisitedSectionState extends State<MostVisitedSection> {
  static const int _initialCount = 5;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.places.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final visibleCount = _expanded
        ? widget.places.length
        : widget.places.length.clamp(0, _initialCount);

    return SliverMainAxisGroup(
      slivers: [
        // 1) عنوان القسم
        SliverToBoxAdapter(
          child: 'الأكثر زيارة'.toTitle(
            context,
            color: context.textPrimary,
            fontFamily: AppFonts.reemKufi,
          ),
        ),

        // 2) الكروت — كل واحد PlaceCard مع بادج للأول 3
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final place = widget.places[index];
            return Padding(
              padding: EdgeInsets.only(
                top: context.mediumSpacing,
                bottom: context.smallSpacing,
              ),
              child:
                  PlaceCard(
                    place: place,
                    categoryName: widget.categoryNameOf(place.categoryId),
                    categoryIcon: widget.categoryIconOf(place.categoryId),
                    areaName: widget.areaNameOf(place.areaId),
                    isFavorite: context.watch<FavoritesCubit>().state.contains(
                      place.id,
                    ),
                    onFavoriteToggle: () =>
                        context.read<FavoritesCubit>().toggleFavorite(place.id),
                    onTap: () => context.push('/place/${place.id}'),
                    // البادج للأول 3 بس — الباقي null.
                    rank: index + 1,
                  ).fadeSlideIn(
                    delay: AppAnimations.stagger(
                      index,
                      base: const Duration(milliseconds: 120),
                    ),
                  ),
            );
          }, childCount: visibleCount),
        ),

        // 3) زرار "عرض الكل" — بيظهر بس لو فيه أماكن مخفية
        if (!_expanded && widget.places.length > _initialCount)
          SliverToBoxAdapter(
            child: Center(
              child: TextButton(
                onPressed: () => setState(() => _expanded = true),
                child: 'عرض الكل'.toBody(
                  context,
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        // 4) مسافة قبل القسم اللي بعده
        SliverToBoxAdapter(child: context.largeSpacing.vSpace),
      ],
    );
  }
}
