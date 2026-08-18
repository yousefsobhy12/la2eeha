import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _style(String family, double size, FontWeight weight, Color? color) {
    return TextStyle(fontFamily: family, fontSize: size, fontWeight: weight, color: color);
  }

  // ── Reem Kufi (عناوين) ──
  static TextStyle headerTitle(Color? color) => _style(AppFonts.reemKufi, 20.sp, FontWeight.w600, color);
  static TextStyle cardTitle(Color? color) => _style(AppFonts.reemKufi, 17.sp, FontWeight.w600, color);
  static TextStyle brandLogo(Color? color) => _style(AppFonts.reemKufi, 22.sp, FontWeight.bold, color);

  // ── Tajawal (باقي النصوص) ──
  static TextStyle headerSubtitle(Color? color) => _style(AppFonts.tajawal, 12.sp, FontWeight.bold, color);
  static TextStyle buttonLabel(Color? color) => _style(AppFonts.tajawal, 16.sp, FontWeight.bold, color);
  static TextStyle bodyBold14(Color? color) => _style(AppFonts.tajawal, 14.sp, FontWeight.bold, color);
  static TextStyle bodyRegular13(Color? color) => _style(AppFonts.tajawal, 13.sp, FontWeight.normal, color);
  static TextStyle captionRegular12(Color? color) => _style(AppFonts.tajawal, 12.sp, FontWeight.normal, color);
  static TextStyle captionRegular12_5(Color? color) => _style(AppFonts.tajawal, 12.5.sp, FontWeight.normal, color);
  static TextStyle versionLabel(Color? color) => _style(AppFonts.tajawal, 11.sp, FontWeight.w600, color);
}
