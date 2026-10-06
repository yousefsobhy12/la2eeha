import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension SpacingExtension on num {
  Widget get vSpace => SizedBox(height: toDouble().h);

  Widget get hSpace => SizedBox(width: toDouble().w);

  Widget get squareSpace => SizedBox(width: toDouble().r, height: toDouble().r);

  EdgeInsets get allPadding => EdgeInsets.all(toDouble().r);

  EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: toDouble().w);

  EdgeInsets get verticalPadding =>
      EdgeInsets.symmetric(vertical: toDouble().h);

  EdgeInsets get topPadding => EdgeInsets.only(top: toDouble().h);

  EdgeInsets get bottomPadding => EdgeInsets.only(bottom: toDouble().h);

  EdgeInsets get rightPadding => EdgeInsets.only(right: toDouble().w);

  EdgeInsets get leftPadding => EdgeInsets.only(left: toDouble().w);

  BorderRadius get circularRadius => BorderRadius.circular(toDouble().r);

  BorderRadius get topRadius => BorderRadius.only(
    topLeft: Radius.circular(toDouble().r),
    topRight: Radius.circular(toDouble().r),
  );

  BorderRadius get bottomRadius => BorderRadius.only(
    bottomLeft: Radius.circular(toDouble().r),
    bottomRight: Radius.circular(toDouble().r),
  );

  BorderRadius get rightRadius => BorderRadius.only(
    topRight: Radius.circular(toDouble().r),
    bottomRight: Radius.circular(toDouble().r),
  );

  BorderRadius get leftRadius => BorderRadius.only(
    topLeft: Radius.circular(toDouble().r),
    bottomLeft: Radius.circular(toDouble().r),
  );
}

extension WidgetSpacingExtension on Widget {
  Widget paddingAll(double value) {
    return Padding(padding: EdgeInsets.all(value.r), child: this);
  }

  Widget paddingHorizontal(double value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: value.w),
      child: this,
    );
  }

  Widget paddingVertical(double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: value.h),
      child: this,
    );
  }

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

  Widget paddingWith(EdgeInsets padding) {
    return Padding(padding: padding, child: this);
  }
}
