const String _translateFrom = 'أإآٱةى٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹';
const String _translateTo = 'ااااهي01234567890123456789';

final Map<String, String> _translateMap = {
  for (var i = 0; i < _translateFrom.length; i++)
    _translateFrom[i]: _translateTo[i],
};

final RegExp _diacriticsAndTatweel = RegExp(r'[\u064B-\u0652\u0670\u0640]');
final RegExp _edgeSpaces = RegExp(r'^ +| +$');
final RegExp _whitespaceRun = RegExp(r'\s+');

final RegExp _unsafeFilterChars = RegExp(r'[\\%_",()*]');

extension SearchNormalizer on String {
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

  String toSearchQuery() {
    return normalizeArabic()
        .replaceAll(_unsafeFilterChars, ' ')
        .replaceAll(_edgeSpaces, '');
  }

  List<String> toSearchWords() {
    return toSearchQuery()
        .split(_whitespaceRun)
        .where((word) => word.isNotEmpty)
        .toList();
  }
}
