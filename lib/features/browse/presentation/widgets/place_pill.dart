// lib/features/browse/presentation/widgets/place_pill.dart
//
// الشيب/البادج الأساسي اللي بتتبني عليه كل بادجات المكان (حالة الفتح،
// التوصيل... إلخ). الشكل واحد والاختلاف في النص واللون بس، فبنتعامل معاه
// كـ widget واحد مش بنكرر الـ Container في كل بادج.
//
// اللون بيتمرّر من برّه والـ tint بينحسب جواه (12% من اللون) عشان كل بادج
// يطلع بنفس الطريقة من غير ما كل واحد يعمل التظليل بتاعه.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/extensions.dart';

class PlacePill extends StatelessWidget {
  final String label;
  final Color color;

  const PlacePill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: context.roundRadius.circularRadius,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: (11.sp * context.fontScale).clamp(9.sp, 13.sp),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
