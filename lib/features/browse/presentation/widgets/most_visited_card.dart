// lib/features/browse/presentation/widgets/most_visited_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/category_visuals.dart';
import '../../../../core/constants/sub_category_visuals.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/place.dart';

class MostVisitedCard extends StatelessWidget {
  final Place place;
  final String categoryName;
  final String categoryIcon;
  final int rank;
  final VoidCallback? onTap;

  const MostVisitedCard({
    super.key,
    required this.place,
    required this.categoryName,
    required this.categoryIcon,
    required this.rank,
    this.onTap,
  });

  String _formatCount(int count) {
    // بدل ما نضيف intl package لحاجة بسيطة زي دي
    final s = count.toString();
    if (s.length <= 3) return s;
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buffer.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }

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
              // هيدر ملون فيه أيقونة الكاتيجوري + رقم الترتيب
              Stack(
                children: [
                  Container(
                    height: context.mostVisitedHeaderHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
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
                    ),
                    child: Center(
                      child: Icon(
                        visual.icon,
                        color: visual.color,
                        size: context.largeIconSize,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: ResponsiveValues.spacing4,
                    start: ResponsiveValues.spacing4,
                    child: _buildRankBadge(context, visual),
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
                      // maxLines: 2,
                    ),
                    2.vSpace,
                    subLabel.toCaption(
                      context,
                      color: context.textSecondary,
                      maxLines: 1,
                    ),
                    6.vSpace,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: context.tinyIconSize,
                          color: context.textSecondary,
                        ),
                        4.hSpace,
                        _formatCount(
                          place.viewCount,
                        ).toCaption(context, color: context.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بادج الترتيب — ميدالية ذهب/فضة/برونز للتلاتة الأوائل، أو الدايرة العادية لباقي الترتيب.
  Widget _buildRankBadge(BuildContext context, CategoryVisual visual) {
    // ألوان الميداليات للتلاتة الأوائل
    const medalColors = {
      1: Color(0xFFFFD700), // ذهب
      2: Color(0xFFC0C0C0), // فضة
      3: Color(0xFFCD7F32), // برونز
    };

    final medalColor = medalColors[rank];

    return Container(
      width: context.rankBadgeSize,
      height: context.rankBadgeSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: medalColor ?? visual.color,
        shape: BoxShape.circle,
      ),
      child: medalColor != null
          ? Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: context.tinyIconSize,
            )
          : Text(
              '$rank',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveValues.labelLarge(context),
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
