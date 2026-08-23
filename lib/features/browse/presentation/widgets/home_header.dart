// lib/features/browse/presentation/widgets/home_header.dart
//
// location pill ثابتة "شبين القناطر" دلوقتي (مفيش منطق منطقة ديناميكي في
// الـ MVP scope الحالي).

import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/extensions/theme_extension.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  void _onMerchantLoginTap(BuildContext context) {
    // TODO(phase6): route '/merchant/login' not built yet
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: 'لاقيها'.toResponsiveText(
                context,
                style: TextStyle(
                  fontFamily: 'ReemKufi',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ),
            InkWell(
              onTap: () => _onMerchantLoginTap(context),
              borderRadius: context.roundRadius.circularRadius,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary,
                  borderRadius: context.roundRadius.circularRadius,
                ),
                child: 'دخول التجار'.toCaption(
                  context,
                  color: context.textOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        context.smallSpacing.vSpace,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_rounded,
                size: context.smallIconSize, color: context.textSecondary),
            4.hSpace,
            'شبين القناطر'.toCaption(context, color: context.textSecondary),
          ],
        ),
      ],
    );
  }
}