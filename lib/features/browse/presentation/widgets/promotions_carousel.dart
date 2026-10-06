import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:la2eeha/features/more/presentation/widgets/contact_bottom_sheet.dart';

import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/promotion.dart';

class PromotionsCarousel extends StatelessWidget {
  final List<Promotion> promotions;

  const PromotionsCarousel({super.key, required this.promotions});

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) {
      return const AspectRatio(aspectRatio: 16 / 9, child: _CtaBanner());
    }

    final showCta = promotions.length < 6;
    final items = <Widget>[
      for (final promotion in promotions)
        _PromotionBanner(promotion: promotion),
      if (showCta) const _CtaBanner(),
    ];

    return CarouselSlider(
      items: items,
      options: CarouselOptions(
        enableInfiniteScroll: false,
        initialPage: 0,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
        autoPlay: items.length > 1,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 600),
        enlargeCenterPage: true,
      ),
    );
  }
}

class _PromotionBanner extends StatelessWidget {
  final Promotion promotion;

  const _PromotionBanner({required this.promotion});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'عرض ترويجي، اضغط للتفاصيل',
      button: true,
      child: ClipRRect(
        borderRadius: context.largeRadius.circularRadius,
        child: Material(
          color: context.colorScheme.primary.withValues(alpha: 0.08),
          child: InkWell(
            onTap: () => context.push('/place/${promotion.placeId}'),
            child: CachedNetworkImage(
              imageUrl: promotion.imageUrl,
              memCacheWidth: 900,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, _) => const SizedBox.shrink(),
              errorWidget: (_, _, _) => const _CtaBanner(),
            ),
          ),
        ),
      ),
    );
  }
}

class _CtaBanner extends StatelessWidget {
  const _CtaBanner();

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.extraLargeRadius),
        ),
      ),
      builder: (sheetContext) => const ContactSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'عايز إعلانك يظهر هنا؟ كلمنا',
      button: true,
      child: Material(
        color: context.colorScheme.primary,
        borderRadius: context.largeRadius.circularRadius,
        child: InkWell(
          onTap: () => _showContactSheet(context),
          borderRadius: context.largeRadius.circularRadius,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.mediumSpacing,
              vertical: context.largeSpacing,
            ),
            child: Row(
              children: [
                Container(
                  width: context.mediumAvatarSize,
                  height: context.mediumAvatarSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.campaign_rounded,
                    size: context.largeIconSize,
                    color: Colors.white,
                  ),
                ),
                context.mediumSpacing.hSpace,
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      'عايز إعلانك يظهر هنا؟'.toTitle(
                        context,
                        color: Colors.white,
                      ),
                      4.vSpace,
                      'كلمنا وهنتواصل معاك'.toCaption(
                        context,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: context.mediumIconSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
