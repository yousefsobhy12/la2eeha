// lib/features/browse/presentation/widgets/place_filters_button.dart
//
// زرار الفلترة — بيتحط في هيدر صفحة النتائج أو في صف Controls، وبيفتح
// PlaceFiltersSheet. لو في فلتر مفعّل، نقط صغير فوق الأيقونة بتقول للمستخدم
// إن فيه فلترة شغالة من غير ما يفتح الشيت (مفيش رقم جوه — العدد بيتبان في
// عنوان الشيت لو حبيت تضيفه بعدين).
//
// Widget stateless بالكامل — الحالة عايشة في الـ Cubit، والنقط بتتبني من
// filters.isActive بس.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/place_filters.dart';

class PlaceFiltersButton extends StatelessWidget {
  final PlaceFilters filters;
  final VoidCallback onPressed;

  /// لون الأيقونة — الزرار ممكن يتحط فوق هيدر ملوّن أو على صفحة عادية.
  /// null = لون الأيقونة الافتراضي في التطبيق.
  final Color? color;

  const PlaceFiltersButton({
    super.key,
    required this.filters,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? context.iconColor;

    return Semantics(
      button: true,
      label: filters.isActive
          ? 'تصفية النتائج, في فلاتر مفعّلة'
          : 'تصفية النتائج',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: iconColor),
            onPressed: onPressed,
          ),
          // PositionedDirectional مش Positioned عشان النطة تفضل فوق-
          // يمين في العربي، فوق-شمال في الإنجليزي — من غير شرط direction.
          // الـ insets 8.r عشان النطة تقعد على ركن الأيقونة نفسها (الأيقونة
          // متظبوطة في النص من جوه الـ 48x48 بتاع الـ IconButton).
          if (filters.isActive)
            PositionedDirectional(
              top: 8.r,
              end: 8.r,
              child: Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorScheme.primary,
                  // حد رفيع بنفس لون السطح اللي ورا الزرار عشان النطة
                  // تفصل عن الخلفية وتبان فوق أي لون هيدر.
                  border: Border.all(color: context.surfaceColor, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
