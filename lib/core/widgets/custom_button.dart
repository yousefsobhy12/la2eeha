import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final Widget? icon;
  final Color? iconColor;
  final double? iconSize;
  final bool isOutlined;
  final Color? borderColor;
  final double? borderWidth;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = 12,
    this.padding,
    this.isLoading = false,
    this.icon,
    this.iconColor,
    this.iconSize = 20,
    this.isOutlined = false,
    this.borderColor,
    this.borderWidth = 2,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor =
        backgroundColor ?? Theme.of(context).primaryColor;
    final defaultTextColor = textColor ?? Colors.white;
    final defaultBorderColor = borderColor ?? defaultBackgroundColor;

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow:
        boxShadow ??
            (isOutlined
                ? null
                : [
              BoxShadow(
                color: defaultBackgroundColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined
              ? Colors.transparent
              : (gradient != null
              ? Colors.transparent
              : defaultBackgroundColor),
          foregroundColor: defaultTextColor,
          elevation: 0,
          padding:
          padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: isOutlined
                ? BorderSide(color: defaultBorderColor, width: borderWidth!)
                : BorderSide.none,
          ),
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(defaultTextColor),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: isOutlined ? defaultBorderColor : defaultTextColor,
              ),
            ),
            if (icon != null) ...[SizedBox(width: 10.w), icon!],
          ],
        ),
      ),
    );
  }
}
