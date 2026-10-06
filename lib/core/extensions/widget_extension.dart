import 'package:flutter/material.dart';
import 'responsive_extension.dart';

extension WidgetExtension on Widget {
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(flex: flex, fit: fit, child: this);
  }

  Widget expanded({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }

  Widget centered() => Center(child: this);

  Widget aligned(Alignment alignment) =>
      Align(alignment: alignment, child: this);

  Widget alignedTopCenter() => aligned(Alignment.topCenter);

  Widget alignedBottomCenter() => aligned(Alignment.bottomCenter);

  Widget alignedCenterLeft() => aligned(Alignment.centerLeft);

  Widget alignedCenterRight() => aligned(Alignment.centerRight);

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

  Widget carded({EdgeInsets? margin, EdgeInsets? padding, double? elevation}) {
    return Card(
      margin: margin,
      elevation: elevation,
      child: padding != null ? Padding(padding: padding, child: this) : this,
    );
  }

  Widget withMaxWidth(double maxWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: this,
    );
  }

  Widget withMaxHeight(double maxHeight) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: this,
    );
  }

  Widget withMinWidth(double minWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: this,
    );
  }

  Widget withMinHeight(double minHeight) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: this,
    );
  }

  Widget fullWidth() => SizedBox(width: double.infinity, child: this);

  Widget fullHeight() => SizedBox(height: double.infinity, child: this);

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

  Widget scrollable({ScrollPhysics? physics}) {
    return SingleChildScrollView(
      physics: physics ?? const BouncingScrollPhysics(),
      child: this,
    );
  }

  Widget scrollableHorizontal({ScrollPhysics? physics}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: physics ?? const BouncingScrollPhysics(),
      child: this,
    );
  }

  Widget showIf(bool condition) {
    return condition ? this : const SizedBox.shrink();
  }

  Widget hideIf(bool condition) {
    return !condition ? this : const SizedBox.shrink();
  }

  Widget onTap(VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }

  Widget inkWell({required VoidCallback onTap, BorderRadius? borderRadius}) {
    return InkWell(onTap: onTap, borderRadius: borderRadius, child: this);
  }

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

  Widget withOpacity(double opacity) {
    return Opacity(opacity: opacity, child: this);
  }

  Widget disabled() => withOpacity(0.5);
}
