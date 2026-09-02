// lib/core/widgets/place_card.dart
//
// categoryIcon — الـ icon key المخزن في عمود categories.icon (زي 'restaurant')
// بيستخدم لجلب الـ CategoryVisual المناسب (أيقونة + لون).
// categoryName — الاسم العربي للكاتيجوري بيتعرض في الـ subtitle.
// areaName — اسم المنطقة (اختياري) بيتعرض جنب الكاتيجوري في الـ subtitle.
//
// "مميز" badge — متخفي تمامًا (لسه مش متفعّل).
// أيقونة القلب (Favorite) موجودة كـ UI جاهزة، بس مقفولة وظيفيًا.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/category_visuals.dart';
import '../constants/sub_category_visuals.dart';
import '../extensions/extensions.dart';
import '../../features/browse/domain/entities/place.dart';
import '../../features/browse/domain/entities/place_open_status.dart';
import '../../features/browse/presentation/widgets/place_open_status_pill.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final String categoryName;
  final String categoryIcon;
  final String? areaName;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const PlaceCard({
    super.key,
    required this.place,
    required this.categoryName,
    required this.categoryIcon,
    this.areaName,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
  });

  Future<void> _call(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: place.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visual = CategoryVisuals.of(categoryIcon);
    final subLabel = SubCategoryVisuals.labelOf(
      place.subCategory,
      fallback: categoryName,
    );
    final subtitle = areaName != null && areaName!.isNotEmpty
        ? '$subLabel · $areaName'
        : subLabel;

    return Material(
      color: context.cardColor,
      borderRadius: context.mediumRadius.circularRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.mediumRadius.circularRadius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: context.mediumRadius.circularRadius,
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
          child: ClipRRect(
            borderRadius: context.mediumRadius.circularRadius,
            child: Row(
              children: [
                // شريط لوني جانبي يعبّر عن الكاتيجوري (leading edge — RTL-aware)
                Container(
                  width: 20,
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(context.mediumRadius),
                      bottomStart: Radius.circular(context.mediumRadius),
                    ),
                  ),
                ),
                // محتوى الكارت
                Expanded(
                  child: Padding(
                    padding: context.cardPadding,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // أيقونة الكاتيجوري (أو الصورة لو موجودة)
                        Container(
                          width: context.mediumAvatarSize,
                          height: context.mediumAvatarSize,
                          decoration: BoxDecoration(
                            gradient:
                                place.imageUrl != null &&
                                    place.imageUrl!.isNotEmpty
                                ? null
                                : LinearGradient(
                                    colors: [
                                      visual.color.withValues(alpha: 0.20),
                                      visual.color.withValues(alpha: 0.08),
                                    ],
                                    begin: AlignmentDirectional.topStart,
                                    end: AlignmentDirectional.bottomEnd,
                                  ),
                            borderRadius: context.mediumRadius.circularRadius,
                            boxShadow:
                                place.imageUrl != null &&
                                    place.imageUrl!.isNotEmpty
                                ? null
                                : [
                                    BoxShadow(
                                      color: visual.color.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                            image:
                                place.imageUrl != null &&
                                    place.imageUrl!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(place.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child:
                              place.imageUrl == null || place.imageUrl!.isEmpty
                              ? Icon(
                                  visual.icon,
                                  color: visual.color,
                                  size: context.largeIconSize,
                                )
                              : null,
                        ),
                        context.hSpacing.hSpace,
                        // النص + الأزرار
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: place.name.toTitle(
                                      context,
                                      maxLines: 1,
                                      textAlign: place.name.isMostlyArabic
                                          ? TextAlign.right
                                          : TextAlign.left,
                                    ),
                                  ),
                                  _FavoriteButton(
                                    isFavorite: isFavorite,
                                    onTap: onFavoriteToggle,
                                  ),
                                ],
                              ),
                              4.vSpace,
                              Row(
                                children: [
                                  Expanded(
                                    child: subtitle.toCaption(
                                      context,
                                      color: context.textSecondary,
                                      maxLines: 1,
                                    ),
                                  ),
                                  if (place.openStatus != null) ...[
                                    6.hSpace,
                                    PlaceOpenStatusPill(
                                      status: place.openStatus,
                                    ),
                                  ],
                                ],
                              ),
                              if (place.workingHours != null &&
                                  place.workingHours!.isNotEmpty) ...[
                                6.vSpace,
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: context.smallIconSize,
                                      color: context.textSecondary,
                                    ),
                                    4.hSpace,
                                    Expanded(
                                      child: place.workingHours!.toCaption(
                                        context,
                                        color: context.textSecondary,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              context.smallSpacing.vSpace,
                              if (place.phone.isNotEmpty)
                                InkWell(
                                  onTap: () => _call(context),
                                  borderRadius:
                                      context.roundRadius.circularRadius,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.colorScheme.primary
                                          .withValues(alpha: 0.12),
                                      borderRadius:
                                          context.roundRadius.circularRadius,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.call_rounded,
                                          size: context.smallIconSize,
                                          color: context.colorScheme.primary,
                                        ),
                                        6.hSpace,
                                        'اتصال'.toCaption(
                                          context,
                                          color: context.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;

  const _FavoriteButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: context.mediumIconSize,
          color: isFavorite ? Colors.redAccent : context.textSecondary,
        ),
      ),
    );
  }
}
