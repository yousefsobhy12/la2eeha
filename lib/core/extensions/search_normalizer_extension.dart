// lib/core/extensions/search_normalizer_extension.dart

/// Must stay identical to Postgres `public.normalize_arabic()`
/// (migration `normalize_arabic_digits`):
///   lower(trim(regexp_replace(translate(input, FROM, TO),
///                             '[\u064B-\u0652\u0670\u0640]', '', 'g')))
/// FROM/TO below are the exact same strings used in the SQL `translate()`.
/// Postgres `trim()` strips ONLY the regular space (U+0020), so we do the
/// same (NOT Dart's trim(), which also strips tab / newline / NBSP).
const String _translateFrom = 'أإآٱةى٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹';
const String _translateTo = 'ااااهي01234567890123456789';

final Map<String, String> _translateMap = {
  for (var i = 0; i < _translateFrom.length; i++)
    _translateFrom[i]: _translateTo[i],
};

final RegExp _diacriticsAndTatweel = RegExp(r'[\u064B-\u0652\u0670\u0640]');
final RegExp _edgeSpaces = RegExp(r'^ +| +$');
final RegExp _whitespaceRun = RegExp(r'\s+');

/// Characters that act as wildcards in ilike / PostgREST, or that can break
/// the .or() filter string.
final RegExp _unsafeFilterChars = RegExp(r'[\\%_",()*]');

extension SearchNormalizer on String {
  /// Exact Dart twin of the DB function `normalize_arabic()`.
  String normalizeArabic() {
    final buffer = StringBuffer();
    for (final ch in split('')) {
      buffer.write(_translateMap[ch] ?? ch);
    }
    return buffer
        .toString()
        .replaceAll(_diacriticsAndTatweel, '')
        .replaceAll(_edgeSpaces, '')
        .toLowerCase();
  }

  /// Normalized + safe to put inside `.ilike` / `.or()`.
  /// Use this for the user's search query (NOT for DB-parity tests).
  String toSearchQuery() {
    return normalizeArabic()
        .replaceAll(_unsafeFilterChars, ' ')
        .replaceAll(_edgeSpaces, '');
  }

  /// The safe query split into separate words (any whitespace run splits).
  /// Used for multi-word AND matching. Empty list if nothing searchable.
  List<String> toSearchWords() {
    return toSearchQuery()
        .split(_whitespaceRun)
        .where((word) => word.isNotEmpty)
        .toList();
  }
}