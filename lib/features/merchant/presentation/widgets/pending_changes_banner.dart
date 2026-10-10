import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_dark.dart';

class PendingChangesBanner extends StatelessWidget {
  const PendingChangesBanner({super.key});

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
            Icons.pending_actions_rounded,
            size: context.mediumIconSize,
            color: context.colorScheme.primary,
          ),
          8.hSpace,
          Expanded(
            child:
                'تعديلاتك قيد المراجعة — الأسعار القديمة هي اللي ظاهرة للناس لحد الموافقة'
                    .toBody(
                      context,
                      color: context.textPrimary,
                    ),
          ),
        ],
      ),
    );
  }
}
