import 'dart:convert';

import 'local_storage_service.dart';

class DailyEventGate {
  final LocalStorageService storage;

  const DailyEventGate(this.storage);

  static const _key = 'daily_event_gate';

  Future<bool> shouldCount(
    String key, {
    Duration window = const Duration(hours: 24),
    DateTime? now,
  }) async {
    final nowMs = (now ?? DateTime.now()).millisecondsSinceEpoch;
    final windowMs = window.inMilliseconds;

    try {
      final map = await _read();

      final last = map[key];
      if (last != null && nowMs >= last && (nowMs - last) < windowMs) {
        return false;
      }

      map.removeWhere((_, value) => nowMs - value >= windowMs);
      map[key] = nowMs;

      try {
        await storage.setString(_key, jsonEncode(map));
      } catch (_) {}
      return true;
    } catch (_) {
      return true;
    }
  }

  Future<Map<String, int>> _read() async {
    final raw = await storage.getString(_key);
    if (raw == null || raw.isEmpty) return <String, int>{};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, int>{};
      final map = <String, int>{};
      decoded.forEach((k, v) {
        if (k is String && v is int) map[k] = v;
      });
      return map;
    } catch (_) {
      return <String, int>{};
    }
  }
}
