import 'package:flutter/material.dart';

import '../../../../core/extensions/time_format_extension.dart';
import 'place.dart';

enum PlaceOpenStatus { openNow, closedNow, closedToday }

extension PlaceOpenStatusX on Place {
  /// Returns null when there's not enough data to compute a status
  /// (open_time/close_time not set yet — e.g. all current test data).
  /// When null, the UI must not render any status pill at all.
  PlaceOpenStatus? get openStatus {
    final now = DateTime.now();
    // أيام الإجازة ميكانيزم مستقل — لو النهارده يوم إجازة يبقى مغلق حتى لو
    // المكان ٢٤ ساعة.
    if (closedDays.contains(now.weekday)) return PlaceOpenStatus.closedToday;

    // المكان اللي شغال ٢٤ ساعة مفتوح على طول (مافيش open_time/close_time أصلًا).
    if (is24Hours) return PlaceOpenStatus.openNow;

    if (openTime == null || closeTime == null) return null;

    final open = _parseTimeOfDay(openTime!);
    final close = _parseTimeOfDay(closeTime!);
    final nowMinutes = now.hour * 60 + now.minute;
    final openMinutes = open.hour * 60 + open.minute;
    final closeMinutes = close.hour * 60 + close.minute;

    final isOpen = closeMinutes > openMinutes
        ? nowMinutes >= openMinutes && nowMinutes < closeMinutes
        // handles ranges that cross midnight, e.g. open 12:00, close 00:00
        : nowMinutes >= openMinutes || nowMinutes < closeMinutes;

    return isOpen ? PlaceOpenStatus.openNow : PlaceOpenStatus.closedNow;
  }
}

/// Shared working-hours text — single source of truth for PlaceCard
/// and PlaceDetailView's info list.
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
  final parts = raw.split(':'); // "HH:mm:ss"
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}
