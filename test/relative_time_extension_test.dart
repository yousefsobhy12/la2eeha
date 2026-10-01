import 'package:flutter_test/flutter_test.dart';
import 'package:la2eeha/core/extensions/relative_time_extension.dart';

void main() {
  final now = DateTime(2026, 10, 1, 12);

  DateTime daysAgo(int n) => now.subtract(Duration(days: n));

  void expectFor(int days, String expected) {
    expect(daysAgo(days).toRelativeArabic(now: now), expected);
  }

  test('fewer than a day', () {
    expect(
      now.subtract(const Duration(hours: 5)).toRelativeArabic(now: now),
      'اليوم',
    );
  });

  test('future date counts as today', () {
    expect(
      now.add(const Duration(days: 2)).toRelativeArabic(now: now),
      'اليوم',
    );
  });

  test('days range', () {
    expectFor(0, 'اليوم');
    expectFor(1, 'امبارح');
    expectFor(2, 'من يومين');
    expectFor(3, 'من 3 أيام');
    expectFor(10, 'من 10 أيام');
    expectFor(11, 'من 11 يوم');
    expectFor(29, 'من 29 يوم');
  });

  test('months range', () {
    expectFor(30, 'من شهر');
    expectFor(59, 'من شهر');
    expectFor(60, 'من شهرين');
    expectFor(90, 'من 3 شهور');
    expectFor(300, 'من 10 شهور');
    expectFor(330, 'من 11 شهر');
    expectFor(364, 'من 12 شهر');
  });

  test('years range', () {
    expectFor(365, 'من سنة');
    expectFor(730, 'من سنتين');
    expectFor(1095, 'من 3 سنين');
  });
}
