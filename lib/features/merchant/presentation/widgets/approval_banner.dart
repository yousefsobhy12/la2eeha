import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_dark.dart';

class ApprovalBanner extends StatelessWidget {
  const ApprovalBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? AppColorsDark.infoBannerBackground
            : AppColors.infoBannerBackground,
        borderRadius: context.mediumRadius.circularRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            size: context.mediumIconSize,
            color: context.colorScheme.primary,
          ),
          8.hSpace,
          Expanded(
            child: 'بياناتك قيد المراجعة قبل الموافقة عليها'.toBody(
              context,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
