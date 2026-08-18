// lib/core/extensions/responsive_values.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'responsive_extension.dart';

class ResponsiveValues {
  ResponsiveValues._();

  // ════════════════════════════════════════════════════════════
  // TYPOGRAPHY SCALE (responsive based on context)
  // ════════════════════════════════════════════════════════════

  static double displayLarge(BuildContext context) =>
      (32.sp * context.fontScale).clamp(28.sp, 36.sp);

  static double displayMedium(BuildContext context) =>
      (28.sp * context.fontScale).clamp(24.sp, 32.sp);

  static double headlineLarge(BuildContext context) =>
      (24.sp * context.fontScale).clamp(20.sp, 28.sp);

  static double headlineMedium(BuildContext context) =>
      (20.sp * context.fontScale).clamp(18.sp, 24.sp);

  static double titleLarge(BuildContext context) =>
      (18.sp * context.fontScale).clamp(16.sp, 20.sp);

  static double titleMedium(BuildContext context) =>
      (16.sp * context.fontScale).clamp(14.sp, 18.sp);

  static double bodyLarge(BuildContext context) =>
      (14.sp * context.fontScale).clamp(12.sp, 16.sp);

  static double bodyMedium(BuildContext context) =>
      (12.sp * context.fontScale).clamp(11.sp, 14.sp);

  static double labelLarge(BuildContext context) =>
      (11.sp * context.fontScale).clamp(10.sp, 13.sp);

  // ════════════════════════════════════════════════════════════
  // FIXED SPACING (8pt grid - no context needed)
  // ════════════════════════════════════════════════════════════

  static double get spacing2 => 2.r;
  static double get spacing4 => 4.r;
  static double get spacing8 => 8.r;
  static double get spacing12 => 12.r;
  static double get spacing16 => 16.r;
  static double get spacing20 => 20.r;
  static double get spacing24 => 24.r;
  static double get spacing32 => 32.r;
  static double get spacing40 => 40.r;
  static double get spacing48 => 48.r;
  static double get spacing64 => 64.r;

  // ════════════════════════════════════════════════════════════
  // BORDER RADIUS
  // ════════════════════════════════════════════════════════════

  static double get radiusNone => 0;
  static double get radiusSmall => 4.r;
  static double get radiusMedium => 8.r;
  static double get radiusLarge => 12.r;
  static double get radiusXLarge => 16.r;
  static double get radiusXXLarge => 24.r;
  static double get radiusRound => 999.r;

  // ════════════════════════════════════════════════════════════
  // ELEVATION
  // ════════════════════════════════════════════════════════════

  static double get elevationNone => 0;
  static double get elevationLow => 2;
  static double get elevationMedium => 4;
  static double get elevationHigh => 8;
  static double get elevationVeryHigh => 16;

  // ════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS
  // ════════════════════════════════════════════════════════════

  static Duration get durationFast => const Duration(milliseconds: 150);
  static Duration get durationNormal => const Duration(milliseconds: 300);
  static Duration get durationSlow => const Duration(milliseconds: 500);
}
