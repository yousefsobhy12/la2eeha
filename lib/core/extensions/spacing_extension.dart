// lib/core/extensions/spacing_extension.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension SpacingExtension on num {
  // ════════════════════════════════════════════════════════════
  // SIZED BOX SHORTCUTS
  // ════════════════════════════════════════════════════════════

  /// SizedBox عمودي (ارتفاع)
  Widget get vSpace => SizedBox(height: toDouble().h);

  /// SizedBox أفقي (عرض)
  Widget get hSpace => SizedBox(width: toDouble().w);

  /// SizedBox مربع (نفس العرض والارتفاع)
  Widget get squareSpace => SizedBox(width: toDouble().r, height: toDouble().r);

  // ════════════════════════════════════════════════════════════
  // PADDING SHORTCUTS
  // ════════════════════════════════════════════════════════════

  /// Padding من كل الجهات
  EdgeInsets get allPadding => EdgeInsets.all(toDouble().r);

  /// Padding أفقي (يمين + يسار)
  EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: toDouble().w);

  /// Padding عمودي (أعلى + أسفل)
  EdgeInsets get verticalPadding =>
      EdgeInsets.symmetric(vertical: toDouble().h);

  /// Padding من الأعلى فقط
  EdgeInsets get topPadding => EdgeInsets.only(top: toDouble().h);

  /// Padding من الأسفل فقط
  EdgeInsets get bottomPadding => EdgeInsets.only(bottom: toDouble().h);

  /// Padding من اليمين فقط
  EdgeInsets get rightPadding => EdgeInsets.only(right: toDouble().w);

  /// Padding من اليسار فقط
  EdgeInsets get leftPadding => EdgeInsets.only(left: toDouble().w);

  // ════════════════════════════════════════════════════════════
  // BORDER RADIUS
  // ════════════════════════════════════════════════════════════

  /// Border radius دائري من كل الجهات
  BorderRadius get circularRadius => BorderRadius.circular(toDouble().r);

  /// Border radius من الأعلى فقط
  BorderRadius get topRadius => BorderRadius.only(
    topLeft: Radius.circular(toDouble().r),
    topRight: Radius.circular(toDouble().r),
  );

  /// Border radius من الأسفل فقط
  BorderRadius get bottomRadius => BorderRadius.only(
    bottomLeft: Radius.circular(toDouble().r),
    bottomRight: Radius.circular(toDouble().r),
  );

  /// Border radius من اليمين فقط
  BorderRadius get rightRadius => BorderRadius.only(
    topRight: Radius.circular(toDouble().r),
    bottomRight: Radius.circular(toDouble().r),
  );

  /// Border radius من اليسار فقط
  BorderRadius get leftRadius => BorderRadius.only(
    topLeft: Radius.circular(toDouble().r),
    bottomLeft: Radius.circular(toDouble().r),
  );
}

extension WidgetSpacingExtension on Widget {
  // ════════════════════════════════════════════════════════════
  // PADDING ON WIDGETS
  // ════════════════════════════════════════════════════════════

  /// Padding من كل الجهات
  Widget paddingAll(double value) {
    return Padding(padding: EdgeInsets.all(value.r), child: this);
  }

  /// Padding أفقي
  Widget paddingHorizontal(double value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: value.w),
      child: this,
    );
  }

  /// Padding عمودي
  Widget paddingVertical(double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: value.h),
      child: this,
    );
  }

  /// Padding مخصص
  Widget paddingOnly({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: top?.h ?? 0,
        bottom: bottom?.h ?? 0,
        left: left?.w ?? 0,
        right: right?.w ?? 0,
      ),
      child: this,
    );
  }

  /// Padding من EdgeInsets
  Widget paddingWith(EdgeInsets padding) {
    return Padding(padding: padding, child: this);
  }
}
