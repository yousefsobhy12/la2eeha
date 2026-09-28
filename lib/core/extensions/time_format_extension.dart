import 'package:flutter/material.dart';

extension TimeStringFormat on String {
  /// "14:30:00" -> "2:30 م"   |   "09:00:00" -> "9:00 ص"
  String toArabicTime() {
    final parts = split(':');
    var hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'م' : 'ص';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
  }
}

/// كلاس بسيط بيحمل اسم الفترة (صباحي/ليلي/ليلي متأخر) + الإيموجي المناسب.
class SportsPeriodLabel {
  final String label;
  final String emoji;
  const SportsPeriodLabel(this.label, this.emoji);
}

/// بيحسب label الفترة من startTime الفعلي بتاع الصف — مش من اختيار التاجر
/// في الـ preset dropdown، فلو عدّل الوقت يدويًا اللابل يفضل صح.
extension SportsPeriodX on TimeOfDay {
  SportsPeriodLabel get periodLabel {
    final h = hour;
    if (h >= 5 && h < 16) return const SportsPeriodLabel('صباحي', '☀️');
    if (h >= 16 && h < 21) return const SportsPeriodLabel('ليلي', '🌙');
    return const SportsPeriodLabel('ليلي متأخر', '🌙'); // 21:00–04:59
  }
}
