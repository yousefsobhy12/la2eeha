// lib/core/extensions/widget_extension.dart

import 'package:flutter/material.dart';
import 'responsive_extension.dart';

extension WidgetExtension on Widget {
  // ════════════════════════════════════════════════════════════
  // FLEXIBLE & EXPANDED
  // ════════════════════════════════════════════════════════════

  /// Flexible widget
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(flex: flex, fit: fit, child: this);
  }

  /// Expanded widget
  Widget expanded({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }

  // ════════════════════════════════════════════════════════════
  // CENTER & ALIGNMENT
  // ════════════════════════════════════════════════════════════

  /// Center the widget
  Widget centered() => Center(child: this);

  /// Align the widget
  Widget aligned(Alignment alignment) =>
      Align(alignment: alignment, child: this);

  /// Align to top center
  Widget alignedTopCenter() => aligned(Alignment.topCenter);

  /// Align to bottom center
  Widget alignedBottomCenter() => aligned(Alignment.bottomCenter);

  /// Align to center left
  Widget alignedCenterLeft() => aligned(Alignment.centerLeft);

  /// Align to center right
  Widget alignedCenterRight() => aligned(Alignment.centerRight);

  // ════════════════════════════════════════════════════════════
  // CONTAINERS & DECORATION
  // ════════════════════════════════════════════════════════════

  /// Wrap in Container with responsive decoration
  Widget containerized(
    BuildContext context, {
    Color? color,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? radius,
    Border? border,
    List<BoxShadow>? shadows,
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius ?? context.mediumRadius),
        border: border,
        boxShadow: shadows,
      ),
      child: this,
    );
  }

  /// Wrap in Card
  Widget carded({EdgeInsets? margin, EdgeInsets? padding, double? elevation}) {
    return Card(
      margin: margin,
      elevation: elevation,
      child: padding != null ? Padding(padding: padding, child: this) : this,
    );
  }

  // ════════════════════════════════════════════════════════════
  // CONSTRAINED BOX (للتحكم في الحجم)
  // ════════════════════════════════════════════════════════════

  /// حدد حد أقصى للعرض (مهم للتابلت!)
  Widget withMaxWidth(double maxWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: this,
    );
  }

  /// حدد حد أقصى للارتفاع
  Widget withMaxHeight(double maxHeight) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: this,
    );
  }

  /// حدد حد أدنى للعرض
  Widget withMinWidth(double minWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: this,
    );
  }

  /// حدد حد أدنى للارتفاع
  Widget withMinHeight(double minHeight) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: this,
    );
  }

  /// عرض كامل الشاشة
  Widget fullWidth() => SizedBox(width: double.infinity, child: this);

  /// ارتفاع كامل الشاشة
  Widget fullHeight() => SizedBox(height: double.infinity, child: this);

  // ════════════════════════════════════════════════════════════
  // RESPONSIVE SIZE (مهم جداً للـ overflow!)
  // ════════════════════════════════════════════════════════════

  /// حجم responsive بناءً على نسبة من الشاشة
  Widget withScreenPercentage(
    BuildContext context, {
    double? widthPercent,
    double? heightPercent,
  }) {
    return SizedBox(
      width: widthPercent != null ? context.screenWidth * widthPercent : null,
      height: heightPercent != null
          ? context.screenHeight * heightPercent
          : null,
      child: this,
    );
  }

  // ════════════════════════════════════════════════════════════
  // SCROLLABLE
  // ════════════════════════════════════════════════════════════

  /// SingleChildScrollView عمودي
  Widget scrollable({ScrollPhysics? physics}) {
    return SingleChildScrollView(
      physics: physics ?? const BouncingScrollPhysics(),
      child: this,
    );
  }

  /// SingleChildScrollView أفقي
  Widget scrollableHorizontal({ScrollPhysics? physics}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: physics ?? const BouncingScrollPhysics(),
      child: this,
    );
  }

  // ════════════════════════════════════════════════════════════
  // VISIBILITY
  // ════════════════════════════════════════════════════════════

  /// عرض الـ widget بناءً على شرط
  Widget showIf(bool condition) {
    return condition ? this : const SizedBox.shrink();
  }

  /// إخفاء الـ widget بناءً على شرط
  Widget hideIf(bool condition) {
    return !condition ? this : const SizedBox.shrink();
  }

  // ════════════════════════════════════════════════════════════
  // GESTURES
  // ════════════════════════════════════════════════════════════

  /// Tap gesture
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }

  /// InkWell with ripple
  Widget inkWell({required VoidCallback onTap, BorderRadius? borderRadius}) {
    return InkWell(onTap: onTap, borderRadius: borderRadius, child: this);
  }

  // ════════════════════════════════════════════════════════════
  // SAFE AREA
  // ════════════════════════════════════════════════════════════

  /// Wrap in SafeArea
  Widget safeArea({
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: this,
    );
  }

  // ════════════════════════════════════════════════════════════
  // OPACITY & SHIMMER
  // ════════════════════════════════════════════════════════════

  /// Set opacity
  Widget withOpacity(double opacity) {
    return Opacity(opacity: opacity, child: this);
  }

  /// Disabled state (opacity 0.5)
  Widget disabled() => withOpacity(0.5);
}
