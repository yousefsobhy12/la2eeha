import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/sports_pricing.dart';

class PricingCard extends StatelessWidget {
  final List<SportsPricing>? sportsPricing;
  final List<MenuItem>? menuItems;

  const PricingCard({super.key, this.sportsPricing, this.menuItems});

  @override
  Widget build(BuildContext context) {
    final hasSportsPricing = sportsPricing != null && sportsPricing!.isNotEmpty;
    final hasMenuItems = menuItems != null && menuItems!.isNotEmpty;

    if (!hasSportsPricing && !hasMenuItems) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardColor,
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
      padding: context.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasSportsPricing) ...[
            _buildSportsHeader(context),
            context.smallSpacing.vSpace,
            ...sportsPricing!.map(
              (pricing) => _buildSportsRow(context, pricing),
            ),
          ] else if (hasMenuItems) ...[
            _buildMenuHeader(context, menuItems!.length),
            context.smallSpacing.vSpace,
            ...menuItems!.map((item) => _buildMenuItemRow(context, item)),
          ],
          context.smallSpacing.vSpace,
          Divider(color: context.borderColor, height: 1),
          8.vSpace,
          'الأسعار من صاحب المكان وقابلة للتغيير.'.toCaption(
            context,
            color: context.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSportsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.sports_soccer_rounded,
              size: context.smallIconSize,
              color: context.colorScheme.primary,
            ),
            6.hSpace,
            'سعر الساعة'.toTitle(context, fontWeight: FontWeight.bold),
          ],
        ),
        'الحجز بالتليفون'.toCaption(context, color: context.textSecondary),
      ],
    );
  }

  Widget _buildSportsRow(BuildContext context, SportsPricing pricing) {
    final timeRange =
        '${pricing.startTime.toArabicTime()} – ${pricing.endTime.toArabicTime()}';
    final priceLabel = '${pricing.price.toPriceString()} ج.م / ساعة';
    final description = pricing.description;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: context.tinyIconSize,
                      color: context.textSecondary,
                    ),
                    6.hSpace,
                    timeRange.toBody(context, color: context.textPrimary),
                  ],
                ),
                if (description != null && description.isNotEmpty) ...[
                  2.vSpace,
                  description.toCaption(
                    context,
                    color: context.textSecondary,
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
          context.smallSpacing.hSpace,
          priceLabel.toBody(
            context,
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuHeader(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: context.smallIconSize,
              color: context.colorScheme.primary,
            ),
            6.hSpace,
            'الأسعار'.toTitle(context, fontWeight: FontWeight.bold),
          ],
        ),
        '$count صنف'.toCaption(context, color: context.textSecondary),
      ],
    );
  }

  Widget _buildMenuItemRow(BuildContext context, MenuItem item) {
    final priceLabel = '${item.price.toPriceString()} ج.م';
    final description = item.description;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                item.name.toBody(
                  context,
                  color: context.textPrimary,
                  textAlign: item.name.isMostlyArabic
                      ? TextAlign.right
                      : TextAlign.left,
                ),
                if (description != null && description.isNotEmpty) ...[
                  2.vSpace,
                  description.toCaption(
                    context,
                    color: context.textSecondary,
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
          context.smallSpacing.hSpace,
          priceLabel.toBody(
            context,
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
