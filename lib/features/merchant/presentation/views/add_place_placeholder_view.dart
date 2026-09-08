// TODO(Phase 6 session): replace with real AddEditPlaceView once built
//
// lib/features/merchant/presentation/views/add_place_placeholder_view.dart
//
// شاشة مؤقتة — بتظهر بعد تأكيد الإيميل بنجاح كإشارة للتاجر
// إن حسابه اتعمل، والخطوة الجاية (إضافة مكان) هتيجي في سيشن لاحق.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_text_styles.dart';

class AddPlacePlaceholderView extends StatelessWidget {
  const AddPlacePlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: Center(
        child: Padding(
          padding: context.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: context.colorScheme.primary,
                size: 80.r,
              ),
              SizedBox(height: context.mediumSpacing),
              'تم التأكيد ✅'.toResponsiveText(
                context,
                style: AppTextStyles.headerTitle(context.textPrimary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.smallSpacing),
              'صفحة إضافة الأعمال قريباً'.toResponsiveText(
                context,
                style: AppTextStyles.bodyRegular13(context.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
