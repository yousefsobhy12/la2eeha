// lib/core/widgets/colored_section_header.dart
//
// ✅ الشكل ده مسحوب حرفيًا من _Header بتاعت MoreView (نفس الألوان، الزوايا،
// والـ AppTextStyles) — مش نسخ لصق، widget واحد مشترك يُستخدم في الاتنين
// عشان يبقى فيه design system متسق فعليًا، مش مجرد صدفة بصرية.
//
// 🔧 لو AppTextStyles.headerTitle/headerSubtitle مختلفين شكلهم عندك، ظبط هنا بس.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../extensions/extensions.dart';
import '../theme/app_text_styles.dart';

class ColoredSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? backgroundColor;
  final Widget? leading;
  final Widget? trailing;

  const ColoredSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.backgroundColor,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.hSpacing,
        vertical: context.largeSpacing,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorScheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22.r),
          bottomRight: Radius.circular(22.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // = يمين في RTL
        children: [
          SizedBox(height: context.largeSpacing),
          Row(
            children: [
              if (leading != null) ...[
                leading!,
                context.smallSpacing.hSpace,
              ],
              Expanded(
                child: title.toResponsiveText(
                  context,
                  style: AppTextStyles.headerTitle(
                    context.colorScheme.onPrimary,
                  ),
                ),
              ),
              if (trailing != null) ...[
                context.smallSpacing.hSpace,
                trailing!,
              ],
            ],
          ),
          SizedBox(height: 4.h),
          subtitle.toResponsiveText(
            context,
            style: AppTextStyles.headerSubtitle(
              context.colorScheme.onPrimary.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}