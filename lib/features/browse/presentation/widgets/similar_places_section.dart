import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/category_visuals.dart';
import '../../../../core/constants/sub_category_visuals.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/widgets/place_card.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../domain/entities/place.dart';

class SimilarPlacesSection extends StatelessWidget {
  final List<Place> places;
  final String categoryName;
  final String categoryIcon;
  final String? areaName;

  const SimilarPlacesSection({
    super.key,
    required this.places,
    required this.categoryName,
    required this.categoryIcon,
    this.areaName,
  });

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        'أماكن مشابهة قريبة منك'.toTitle(
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
              final place = places[index];
              return _SimilarPlaceCard(
                place: place,
                categoryName: categoryName,
                categoryIcon: categoryIcon,
                areaName: areaName,
                onTap: () => context.push('/place/${place.id}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SimilarPlaceCard extends StatelessWidget {
  final Place place;
  final String categoryName;
  final String categoryIcon;
  final String? areaName;
  final VoidCallback onTap;

  const _SimilarPlaceCard({
    required this.place,
    required this.categoryName,
    required this.categoryIcon,
    this.areaName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visual = CategoryVisuals.of(categoryIcon);
    final subLabel = SubCategoryVisuals.labelOf(
      place.subCategory,
      fallback: categoryName,
    );
    final bool hasImage = place.imageUrl != null && place.imageUrl!.isNotEmpty;
    final BorderRadius headerRadius = BorderRadius.only(
      topLeft: Radius.circular(context.mediumRadius),
      topRight: Radius.circular(context.mediumRadius),
    );

    final Widget fallback = Container(
      height: context.mostVisitedHeaderHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            visual.color.withValues(alpha: 0.22),
            visual.color.withValues(alpha: 0.10),
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: headerRadius,
      ),
      child: Center(
        child: Icon(
          visual.icon,
          color: visual.color,
          size: context.largeIconSize,
        ),
      ),
    );

    return Material(
      color: context.cardColor,
      borderRadius: context.largeRadius.circularRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.largeRadius.circularRadius,
        child: Container(
          width: context.mostVisitedCardWidth,
          decoration: BoxDecoration(
            borderRadius: context.largeRadius.circularRadius,
            border: Border.all(color: context.borderColor),
            boxShadow: [
              BoxShadow(
                color: context.isDarkMode
                    ? Colors.black.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  hasImage
                      ? ClipRRect(
                          borderRadius: headerRadius,
                          child: CachedNetworkImage(
                            imageUrl: place.imageUrl!,
                            width: double.infinity,
                            height: context.mostVisitedHeaderHeight,
                            fit: BoxFit.cover,
                            memCacheWidth: 300,
                            placeholder: (_, _) => fallback,
                            errorWidget: (_, _, _) => fallback,
                          ),
                        )
                      : fallback,
                  PositionedDirectional(
                    top: ResponsiveValues.spacing4,
                    end: ResponsiveValues.spacing4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: FavoriteButton(
                        isFavorite: context
                            .watch<FavoritesCubit>()
                            .state
                            .contains(place.id),
                        onTap: () => context
                            .read<FavoritesCubit>()
                            .toggleFavorite(place.id),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: context.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    place.name.toBody(
                      context,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: place.name.isMostlyArabic
                          ? TextAlign.right
                          : TextAlign.left,
                    ),
                    2.vSpace,
                    subLabel.toCaption(
                      context,
                      color: context.textSecondary,
                      maxLines: 1,
                    ),
                    if (areaName != null && areaName!.isNotEmpty) ...[
                      4.vSpace,
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: context.tinyIconSize,
                            color: context.textSecondary,
                          ),
                          2.hSpace,
                          Expanded(
                            child: areaName!.toCaption(
                              context,
                              color: context.textSecondary,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
