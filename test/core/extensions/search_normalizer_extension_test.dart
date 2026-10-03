import 'package:flutter_test/flutter_test.dart';
import 'package:la2eeha/core/extensions/search_normalizer_extension.dart';

void main() {
  // Expected values come from the real Supabase normalize_arabic() output
  // (after migration normalize_arabic_digits).
  const vectors = <String, String>{
    'صيدلية': 'صيدليه',
    'صيدليه': 'صيدليه',
    'أسامة': 'اسامه',
    'اسامه': 'اسامه',
    'إبراهيم': 'ابراهيم',
    'آية': 'ايه',
    'ٱلله': 'الله',
    'القناطر': 'القناطر',
    'قناطره': 'قناطره',
    'على': 'علي',
    'مستشفى': 'مستشفي',
    'مُحَمَّد': 'محمد',
    'مــحمد': 'محمد',
    '  صيدلية   النور  ': 'صيدليه   النور',
    'صيدلية    النور': 'صيدليه    النور',
    'KFC Store': 'kfc store',
    'Vodafone 2': 'vodafone 2',
    'مطعم ١٢٣ 456': 'مطعم 123 456',
    '٠١٢٣٤٥٦٧٨٩': '0123456789',
    '۰۱۲۳۴۵۶۷۸۹': '0123456789',
    'عمارة ۱۲۳': 'عماره 123',
    'صيدلية ٠٩': 'صيدليه 09',
    'أسامة ٢': 'اسامه 2',
    'صيدلية\tالنور': 'صيدليه\tالنور',
    'صيدلية\nالنور': 'صيدليه\nالنور',
    '\u00A0صيدلية\u00A0': '\u00A0صيدليه\u00A0',
    'ئ ؤ ء': 'ئ ؤ ء',
    '\uFEFB لا': '\uFEFB لا',
    'ي ى ك \u06A9': 'ي ي ك \u06A9',
    '\u0670': '',
    'Ahmed ÉCOLE': 'ahmed école',
    '': '',
  };

  group('normalizeArabic matches DB normalize_arabic()', () {
    vectors.forEach((input, expected) {
      test('"$input"', () {
        expect(input.normalizeArabic(), expected);
      });
    });
  });

  group('toSearchQuery', () {
    test('same spelling variants give the same query', () {
      expect(
        'صيدلية'.toSearchQuery(),
        'صيدلية'.replaceAll('ة', 'ه').toSearchQuery(),
      );
      expect('أسامة'.toSearchQuery(), 'اسامه'.toSearchQuery());
    });
    test('Arabic-Indic digits equal Western digits', () {
      expect('مطعم ١٢'.toSearchQuery(), 'مطعم 12'.toSearchQuery());
    });
    test('strips wildcard / filter-breaking characters', () {
      expect('%%'.toSearchQuery(), '');
      expect('a_b'.toSearchQuery(), 'a b');
      expect('(x),y'.toSearchQuery(), 'x  y');
      expect('"*"'.toSearchQuery(), '');
    });
  });

  group('toSearchWords', () {
    test('splits on any whitespace run and normalizes', () {
      expect('صيدلية  النور'.toSearchWords(), ['صيدليه', 'النور']);
      expect('  أسامة\u00A0٢ '.toSearchWords(), ['اسامه', '2']);
    });
    test('drops unsafe characters', () {
      expect('%% a_b'.toSearchWords(), ['a', 'b']);
      expect('(x),y'.toSearchWords(), ['x', 'y']);
    });
    test('nothing searchable gives empty list', () {
      expect('   '.toSearchWords(), isEmpty);
      expect('%%'.toSearchWords(), isEmpty);
      expect(''.toSearchWords(), isEmpty);
    });
  });
}
