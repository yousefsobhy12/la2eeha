import 'package:flutter/material.dart';

import 'place.dart';

enum PlaceOpenStatus { openNow, closedNow, closedToday }

extension PlaceOpenStatusX on Place {
  /// Returns null when there's not enough data to compute a status
  /// (open_time/close_time not set yet — e.g. all current test data).
  /// When null, the UI must not render any status pill at all.
  PlaceOpenStatus? get openStatus {
    if (openTime == null || closeTime == null) return null;

    final now = DateTime.now();
    if (closedDays.contains(now.weekday)) return PlaceOpenStatus.closedToday;

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

TimeOfDay _parseTimeOfDay(String raw) {
  final parts = raw.split(':'); // "HH:mm:ss"
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}
