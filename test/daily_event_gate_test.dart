import 'package:flutter_test/flutter_test.dart';
import 'package:la2eeha/core/storage/daily_event_gate.dart';
import 'package:la2eeha/core/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final gate = DailyEventGate(LocalStorageService());
  final t0 = DateTime(2026, 10, 1, 12);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('first call for a key counts', () async {
    expect(await gate.shouldCount('view:5', now: t0), isTrue);
  });

  test('same key 1 hour later is blocked', () async {
    expect(await gate.shouldCount('view:5', now: t0), isTrue);
    expect(
      await gate.shouldCount('view:5', now: t0.add(const Duration(hours: 1))),
      isFalse,
    );
  });

  test('same key 23h59m later is still blocked', () async {
    expect(await gate.shouldCount('view:5', now: t0), isTrue);
    expect(
      await gate.shouldCount(
        'view:5',
        now: t0.add(const Duration(hours: 23, minutes: 59)),
      ),
      isFalse,
    );
  });

  test('same key exactly 24h later counts again', () async {
    expect(await gate.shouldCount('view:5', now: t0), isTrue);
    expect(
      await gate.shouldCount('view:5', now: t0.add(const Duration(hours: 24))),
      isTrue,
    );
  });

  test('a different key is independent', () async {
    expect(await gate.shouldCount('view:5', now: t0), isTrue);
    expect(await gate.shouldCount('view:6', now: t0), isTrue);
  });

  test('old entries are pruned, so the old key counts again', () async {
    expect(await gate.shouldCount('view:5', now: t0), isTrue);
    expect(
      await gate.shouldCount('view:6', now: t0.add(const Duration(hours: 25))),
      isTrue,
    );
    expect(
      await gate.shouldCount(
        'view:5',
        now: t0.add(const Duration(hours: 25, minutes: 1)),
      ),
      isTrue,
    );
  });

  test('corrupted stored JSON counts and does not throw', () async {
    SharedPreferences.setMockInitialValues({'daily_event_gate': 'not json'});

    Object? error;
    bool? result;
    try {
      result = await gate.shouldCount('view:5', now: t0);
    } catch (e) {
      error = e;
    }

    expect(error, isNull);
    expect(result, isTrue);
  });

  test('a stored time in the future is treated as expired', () async {
    final future = t0.add(const Duration(hours: 10)).millisecondsSinceEpoch;
    SharedPreferences.setMockInitialValues({
      'daily_event_gate': '{"view:5":$future}',
    });

    expect(await gate.shouldCount('view:5', now: t0), isTrue);
  });
}
