import 'package:flutter/material.dart';

extension TimeStringFormat on String {
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

class SportsPeriodLabel {
  final String label;
  final String emoji;
  const SportsPeriodLabel(this.label, this.emoji);
}

extension SportsPeriodX on TimeOfDay {
  SportsPeriodLabel get periodLabel {
    final h = hour;
    if (h >= 5 && h < 16) return const SportsPeriodLabel('صباحي', '☀️');
    if (h >= 16 && h < 21) return const SportsPeriodLabel('ليلي', '🌙');
    return const SportsPeriodLabel('ليلي متأخر', '🌙');
  }
}
