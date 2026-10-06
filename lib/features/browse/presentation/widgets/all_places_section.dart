import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:la2eeha/core/theme/app_fonts.dart';
import 'package:la2eeha/features/favorites/presentation/cubit/favorites_cubit.dart';
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

  List<Widget> buildSlivers(BuildContext context) {
    if (places.isEmpty) return const [];

    return [
      SliverToBoxAdapter(
        child: 'كل الأماكن'.toTitle(
          context,
          color: context.textPrimary,
          fontFamily: AppFonts.reemKufi,
        ),
      ),

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
                  isFavorite: context.watch<FavoritesCubit>().state.contains(
                    place.id,
                  ),
                  onFavoriteToggle: () =>
                      context.read<FavoritesCubit>().toggleFavorite(place.id),
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
