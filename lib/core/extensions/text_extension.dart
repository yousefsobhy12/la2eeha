// lib/core/extensions/text_extension.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'responsive_extension.dart';

extension ResponsiveText on String {
  // ════════════════════════════════════════════════════════════
  // AUTO-SIZING TEXT (يصغر لو طويل)
  // ════════════════════════════════════════════════════════════

  /// نص عادي مع auto-sizing
  Widget toResponsiveText(
    BuildContext context, {
    TextStyle? style,
    int? maxLines,
    TextAlign? textAlign,
    TextOverflow? overflow,
    double? minFontSize,
  }) {
    return _ResponsiveTextWidget(
      text: this,
      context: context,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
      minFontSize: minFontSize,
    );
  }

  /// عنوان كبير
  Widget toHeadline(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    int? maxLines,
    TextAlign? textAlign,
  }) {
    return toResponsiveText(
      context,
      style: TextStyle(
        fontSize: (24.sp * context.fontScale).clamp(20.sp, 28.sp),
        fontWeight: fontWeight ?? FontWeight.bold,
        color: color,
      ),
      maxLines: maxLines ?? 2,
      minFontSize: 18.sp,
      textAlign: textAlign,
    );
  }

  /// عنوان متوسط
  Widget toTitle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    int? maxLines,
    String? fontFamily,
    TextAlign? textAlign,
  }) {
    return toResponsiveText(
      context,
      style: TextStyle(
        fontSize: (18.sp * context.fontScale).clamp(16.sp, 20.sp),
        fontWeight: fontWeight ?? FontWeight.w600,
        color: color,
        fontFamily: fontFamily,
      ),
      maxLines: maxLines ?? 2,
      minFontSize: 14.sp,
      textAlign: textAlign,
    );
  }

  /// نص عادي
  Widget toBody(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    int? maxLines,
    TextAlign? textAlign,
    TextOverflow? overflow,
  }) {
    return toResponsiveText(
      context,
      style: TextStyle(
        fontSize: (14.sp * context.fontScale).clamp(12.sp, 16.sp),
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      minFontSize: 11.sp,
      overflow: overflow,
    );
  }

  /// نص صغير (caption)
  Widget toCaption(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    int? maxLines,
    double? letterSpacing,
    String? fontFamily,
    TextAlign? textAlign,
  }) {
    return toResponsiveText(
      context,
      style: TextStyle(
        fontSize: (12.sp * context.fontScale).clamp(10.sp, 14.sp),
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        fontFamily: fontFamily,
      ),
      maxLines: maxLines,
      minFontSize: 9.sp,
      textAlign: textAlign,
    );
  }

  // ════════════════════════════════════════════════════════════
  // ELLIPSIS CONTROL
  // ════════════════════════════════════════════════════════════

  /// يقطع النص بـ ... لو طويل
  Widget toEllipsisText(
    BuildContext context, {
    TextStyle? style,
    int maxLines = 1,
  }) {
    return Text(
      this,
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// يعرض النص كامل مع scrolling لو طويل
  Widget toScrollableText(BuildContext context, {TextStyle? style}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Text(this, style: style),
    );
  }
}

// ════════════════════════════════════════════════════════════
// INTERNAL WIDGET
// ════════════════════════════════════════════════════════════

class _ResponsiveTextWidget extends StatelessWidget {
  final String text;
  final BuildContext context;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final double? minFontSize;

  const _ResponsiveTextWidget({
    required this.text,
    required this.context,
    this.style,
    this.maxLines,
    this.textAlign,
    this.overflow,
    this.minFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final baseStyle = style ?? const TextStyle();
        final baseFontSize = baseStyle.fontSize ?? 14.sp;

        // قياس حجم النص
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: baseStyle),
          maxLines: maxLines ?? 1,
          textDirection: TextDirection.rtl,
        )..layout(maxWidth: constraints.maxWidth);

        double fontSize = baseFontSize;

        // لو النص أطول من المساحة، صغر الخط
        if (textPainter.didExceedMaxLines ||
            textPainter.width > constraints.maxWidth) {
          final scaleFactor = constraints.maxWidth / (textPainter.width + 10);
          fontSize = (baseFontSize * scaleFactor).clamp(
            minFontSize ?? baseFontSize * 0.7,
            baseFontSize,
          );
        }

        return Text(
          text,
          style: baseStyle.copyWith(fontSize: fontSize),
          maxLines: maxLines,
          overflow: overflow ?? TextOverflow.ellipsis,
          textAlign: textAlign,
        );
      },
    );
  }
}
