import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/place_open_status.dart';

class PlaceOpenStatusPill extends StatelessWidget {
  final PlaceOpenStatus? status;

  const PlaceOpenStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();

    final (String label, Color color) = switch (status!) {
      PlaceOpenStatus.openNow => ('مفتوح الآن', const Color(0xFF2F6B3A)),
      PlaceOpenStatus.closedNow => ('مغلق الآن', const Color(0xFF8C2F39)),
      PlaceOpenStatus.closedToday => ('مغلق اليوم', const Color(0xFF8C2F39)),
    };

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
