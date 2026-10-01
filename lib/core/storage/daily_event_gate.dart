import 'dart:convert';

import 'local_storage_service.dart';

/// بوابة بسيطة تمنع تكرار نفس الحدث أكتر من مرة في نافذة زمنية (24 ساعة
/// افتراضياً) — عشان event الـ `view` ميتحسبش مع كل refresh ولا مع كل فتح
/// للشاشة، بس يفضل بيتحسب لو فعلاً فتحها بعد يوم.
///
/// التخزين كله في نص JSON واحد تحت [_key]: `Map<String, int>` من key ->
/// epoch milliseconds.
class DailyEventGate {
  final LocalStorageService storage;

  const DailyEventGate(this.storage);

  static const _key = 'daily_event_gate';

  /// true  => the caller should count the event now (the time is recorded).
  /// false => the same key was already counted less than [window] ago.
  ///
  /// الميثود دي مابترميش أبداً: أي خطأ في القراءة أو الكتابة بيتعامل معاه
  /// على إنه "اقعد احسب" (true) عشان الـ tracking ميتضيعش.
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
      // وقت متسجل في المستقبل بيتعامل معاه كأنه انتهى => احسب عادي.
      if (last != null && nowMs >= last && (nowMs - last) < windowMs) {
        return false;
      }

      // ننضّف أي entries قديمة عشان الـ JSON مايكبرش على طول.
      map.removeWhere((_, value) => nowMs - value >= windowMs);
      map[key] = nowMs;

      try {
        await storage.setString(_key, jsonEncode(map));
      } catch (_) {
        // فشل الكتابة متسابش — الحدث اتحسب دلوقتي والعداد هيبدأ من جديد.
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  /// بيقرأ الـ Map من الكاش؛ أي بيانات تالفة أو غير متوقعة => Map فاضية.
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
