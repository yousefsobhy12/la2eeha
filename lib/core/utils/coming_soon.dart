// lib/core/utils/coming_soon.dart
//
// ✅ نفس الـ pattern بالظبط اللي MoreView بتستخدمه لزرار "دخول التجار" —
// بنستخدمها بدل أي context.push لراوت لسه مش موجود في app_router.dart،
// عشان الابلكيشن ميكرشش بدل ما نخمن أسماء راوتس مش موجودة.

import 'package:flutter/material.dart';

void showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('قريبًا')));
}
