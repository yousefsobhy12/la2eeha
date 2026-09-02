import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/category_visuals.dart';
import '../../../../core/constants/sub_category_visuals.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_fonts.dart';
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
              Container(
                height: context.mostVisitedHeaderHeight,
                decoration: BoxDecoration(
                  gradient: place.imageUrl != null && place.imageUrl!.isNotEmpty
                      ? null
                      : LinearGradient(
                          colors: [
                            visual.color.withValues(alpha: 0.22),
                            visual.color.withValues(alpha: 0.10),
                          ],
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                        ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(context.mediumRadius),
                    topRight: Radius.circular(context.mediumRadius),
                  ),
                  image: place.imageUrl != null && place.imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(place.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: place.imageUrl == null || place.imageUrl!.isEmpty
                    ? Center(
                        child: Icon(
                          visual.icon,
                          color: visual.color,
                          size: context.largeIconSize,
                        ),
                      )
                    : null,
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
