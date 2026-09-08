// lib/core/widgets/auth_header.dart
//
// هيدر مخصص لشاشات الـ Auth (Login / Register / Verify Email).
// مختلف عن ColoredSectionHeader — النص هنا centered والوردمارك أكبر.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../extensions/extensions.dart';
import '../theme/app_fonts.dart';

class AuthHeader extends StatelessWidget {
  /// true → shows "بوابة أصحاب الأماكن" subtitle (Login/Register).
  /// false → no subtitle (Verify Email).
  final bool showSubtitle;

  /// null → no back button (Login/Register).
  /// non-null → back chevron at the top-start corner (Verify Email).
  final VoidCallback? onBack;

  const AuthHeader({super.key, this.showSubtitle = true, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: context.topSafeArea + context.mediumSpacing,
        bottom: context.largeSpacing,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26.r),
          bottomRight: Radius.circular(26.r),
        ),
      ),
      child: Stack(
        children: [
          // ── Back chevron (optional) ──
          if (onBack != null)
            PositionedDirectional(
              top: 0,
              start: context.smallSpacing,
              child: IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.chevron_right_rounded, // RTL-aware — points "back"
                  color: context.colorScheme.onPrimary,
                  size: context.largeIconSize,
                ),
              ),
            ),

          // ── Centered content ──
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'لاقيها',
                  style: TextStyle(
                    fontFamily: AppFonts.reemKufi,
                    fontSize: 34.sp,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
                if (showSubtitle) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'بوابة أصحاب الأماكن',
                    style: TextStyle(
                      fontFamily: AppFonts.tajawal,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onPrimary
                          .withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
