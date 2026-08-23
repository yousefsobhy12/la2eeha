import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:la2eeha/core/theme/app_text_styles.dart';

import '../../../../core/extensions/extensions.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border.all(color: context.borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(context.extraLargeRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: context.cardPadding,
          child: Row(
            children: [
              Icon(
                Icons.share_rounded,
                color: context.textSecondary,
                size: 21.r,
              ),
              SizedBox(width: context.smallSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    'تواصل مع المطور'.toResponsiveText(
                      context,
                      style: AppTextStyles.bodyBold14(context.textPrimary),
                    ),
                    'اقتراح، مشكلة، أو مكان ناقص'.toResponsiveText(
                      context,
                      style: AppTextStyles.captionRegular12(
                        context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.smallSpacing),
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: context.textSecondary,
                size: 16.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}