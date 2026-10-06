import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../extensions/extensions.dart';
import '../theme/app_fonts.dart';

class AuthHeader extends StatelessWidget {
  final bool showSubtitle;

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
          if (onBack != null)
            PositionedDirectional(
              top: 0,
              start: context.smallSpacing,
              child: IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: context.colorScheme.onPrimary,
                  size: context.largeIconSize,
                ),
              ),
            ),

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
                      color: context.colorScheme.onPrimary.withValues(
                        alpha: 0.65,
                      ),
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
