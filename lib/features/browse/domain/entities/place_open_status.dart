import 'package:flutter/material.dart';

import '../../../../core/extensions/time_format_extension.dart';
import 'place.dart';

enum PlaceOpenStatus { openNow, closedNow, closedToday }

extension PlaceOpenStatusX on Place {
  PlaceOpenStatus? get openStatus {
    final now = DateTime.now();
    if (closedDays.contains(now.weekday)) return PlaceOpenStatus.closedToday;

    if (is24Hours) return PlaceOpenStatus.openNow;

    if (openTime == null || closeTime == null) return null;

    final open = _parseTimeOfDay(openTime!);
    final close = _parseTimeOfDay(closeTime!);
    final nowMinutes = now.hour * 60 + now.minute;
    final openMinutes = open.hour * 60 + open.minute;
    final closeMinutes = close.hour * 60 + close.minute;

    final isOpen = closeMinutes > openMinutes
        ? nowMinutes >= openMinutes && nowMinutes < closeMinutes
        : nowMinutes >= openMinutes || nowMinutes < closeMinutes;

    return isOpen ? PlaceOpenStatus.openNow : PlaceOpenStatus.closedNow;
  }
}

extension PlaceWorkingHoursX on Place {
  String? get workingHoursText {
    if (is24Hours) return 'يعمل على مدار الساعة';
    if (openTime != null && closeTime != null) {
      return '${openTime!.toArabicTime()} – ${closeTime!.toArabicTime()}';
    }
    return null;
  }
}

TimeOfDay _parseTimeOfDay(String raw) {
  final parts = raw.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}
