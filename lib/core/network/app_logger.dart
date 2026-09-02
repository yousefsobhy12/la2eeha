// lib/core/network/app_logger.dart
//
// Logger instance واحد للأبلكيشن كله — بنستخدمه في safeSupabaseCall
// عشان نسجل نجاح/فشل كل request بشكل readable في الكونسول.

import 'package:logger/logger.dart';

/// Logger مشترك — compact وسهل القراءة في الكونسول.
final Logger appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // مش محتاجين stack trace في الـ logs العادية
    errorMethodCount: 3, // بس لو error نعرض 3 سطور من الـ stack
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none,
  ),
);
