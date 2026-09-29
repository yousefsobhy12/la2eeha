// lib/core/widgets/place_card.dart
//
// categoryIcon — الـ icon key المخزن في عمود categories.icon (زي 'restaurant')
// بيستخدم لجلب الـ CategoryVisual المناسب (أيقونة + لون).
// categoryName — الاسم العربي للكاتيجوري بيتعرض في الـ subtitle.
// areaName — اسم المنطقة (اختياري) بيتعرض جنب الكاتيجوري في الـ subtitle.
// rank — الترتيب في قسم "الأكثر زيارة" (1-based). الأول 3 بس بياخدوا medal
// (ذهب/فضة/نحاس)، وأي rank أكبر من كده بيتجاهَل. null = بدون بادج.
//
// صورة المكان بتتحمّل بـ CachedNetworkImage (مفيش NetworkImage مباشرة عشان
// الكاش والـ placeholder)؛ لو مفيش صورة أو التحميل فشل بيرجع للأيقونة.
//
// "مميز" badge — متخفي تمامًا (لسه مش متفعّل).
// أيقونة القلب (Favorite) موجودة كـ UI جاهزة، بس مقفولة وظيفيًا.

import 'package:cached_network_image/cached_network_image.dart';
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
  final int? rank;

  const PlaceCard({
    super.key,
    required this.place,
    required this.categoryName,
    required this.categoryIcon,
    this.areaName,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
    this.rank,
  });

  Future<void> _call(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: place.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// البديل اللي بيتعرض لما المكان مفيش له صورة، أو الصورة مفشلتش في التحميل:
  /// تدرّج لون الكاتيجوري + أيقونته. بيتستخدم كـ placeholder و errorWidget كمان.
  Widget _iconAvatar(BuildContext context, CategoryVisual visual) {
    return Container(
      width: context.mediumAvatarSize,
      height: context.mediumAvatarSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            visual.color.withValues(alpha: 0.20),
            visual.color.withValues(alpha: 0.08),
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: context.mediumRadius.circularRadius,
        boxShadow: [
          BoxShadow(
            color: visual.color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        visual.icon,
        color: visual.color,
        size: context.largeIconSize,
      ),
    );
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
                        // الأفاتار + بادج الترتيب (اللي بيطلع برّه الكارت)
                        SizedBox(
                          width: context.mediumAvatarSize,
                          height: context.mediumAvatarSize,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child:
                                    place.imageUrl != null &&
                                        place.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            context.mediumRadius.circularRadius,
                                        child: CachedNetworkImage(
                                          imageUrl: place.imageUrl!,
                                          memCacheWidth: 200,
                                          fit: BoxFit.cover,
                                          placeholder: (_, _) =>
                                              _iconAvatar(context, visual),
                                          errorWidget: (_, _, _) =>
                                              _iconAvatar(context, visual),
                                        ),
                                      )
                                    : _iconAvatar(context, visual),
                              ),
                              if (rank != null && rank! <= 3)
                                PositionedDirectional(
                                  top: -4,
                                  start: -4,
                                  child: _RankBadge(rank: rank!),
                                ),
                            ],
                          ),
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
                                  FavoriteButton(
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
                              if (place.workingHoursText != null) ...[
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
                                      child: place.workingHoursText!.toCaption(
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

/// بادج الترتيب اللي بيظهر فوق الأفاتار في قسم "الأكثر زيارة".
/// الأول 3 مراكز بس: ذهب / فضة / نحاس. الحافّة بلون الكارت عشان
/// يبقى واضح إن البادج برّه الكارت لما الخلفية فاتحة.
class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  Color get _medalColor => switch (rank) {
    1 => const Color(0xFFF5B301), // ذهب
    2 => const Color(0xFFA8B0B8), // فضة
    _ => const Color(0xFFCD7F32), // نحاس
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ترتيب $rank من الأكثر زيارة',
      child: Container(
        width: context.rankBadgeSize,
        height: context.rankBadgeSize,
        decoration: BoxDecoration(
          color: _medalColor,
          shape: BoxShape.circle,
          border: Border.all(color: context.cardColor, width: 1.5),
        ),
        child: Icon(
          Icons.military_tech_rounded,
          size: context.rankBadgeSize * 0.6,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ScaleTransition(
          scale: _scale,
          child: Icon(
            widget.isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            size: context.mediumIconSize,
            color: widget.isFavorite ? Colors.redAccent : context.textSecondary,
          ),
        ),
      ),
    );
  }
}
