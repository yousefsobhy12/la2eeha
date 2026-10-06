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
        SliverToBoxAdapter(
          child: 'الأكثر زيارة'.toTitle(
            context,
            color: context.textPrimary,
            fontFamily: AppFonts.reemKufi,
          ),
        ),

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

        SliverToBoxAdapter(child: context.largeSpacing.vSpace),
      ],
    );
  }
}
