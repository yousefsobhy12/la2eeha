import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:la2eeha/core/theme/app_colors.dart';
import 'package:la2eeha/core/theme/app_text_styles.dart';
import 'package:la2eeha/core/widgets/custom_button.dart';

import '../../../../core/extensions/extensions.dart';

class BusinessOwnerCard extends StatelessWidget {
  const BusinessOwnerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.cardPadding,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border.all(color: context.borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(context.extraLargeRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.cardIconContainerSize,
            height: context.cardIconContainerSize,
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(context.largeRadius),
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: context.colorScheme.primary,
              size: context.cardIconSize,
            ),
          ),
          SizedBox(height: context.mediumSpacing),
          'هل أنت صاحب بيزنس؟'.toResponsiveText(
            context,
            style: AppTextStyles.cardTitle(context.textPrimary),
          ),
          SizedBox(height: context.smallSpacing),
          'سجّل مكانك في لاقيها وخلي أهل شبين القناطر\nوالقرى المجاورة يلاقوك بسهولة.'
              .toResponsiveText(
                context,
                textAlign: TextAlign.start,
                style: AppTextStyles.bodyRegular13(context.textSecondary),
              ),
          SizedBox(height: context.mediumSpacing),
          CustomElevatedButton(
            text: 'دخول التجار',
            onPressed: () {
              context.push('/login');
            },
            // ثابتة عن قصد في الوضعين (هوية الزرار الأساسي للبراند)
            backgroundColor: AppColors.primary,
            textColor: AppColors.onPrimary,
            height: context.buttonHeight,
            fontSize: context.isSmallPhone
                ? ResponsiveValues.titleSmall(context)
                : ResponsiveValues.titleMedium(context),
            fontWeight: FontWeight.bold,
            borderRadius: context.largeRadius,
            boxShadow: const [
              BoxShadow(
                color: AppColors.primaryPressedShadow,
                offset: Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
