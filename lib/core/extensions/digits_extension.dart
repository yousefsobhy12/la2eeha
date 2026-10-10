const String _westernDigits = '0123456789';
const String _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';
const String _persianDigits = '۰۱۲۳۴۵۶۷۸۹';

final Map<String, String> _digitMap = {
  for (var i = 0; i < _westernDigits.length; i++) ...{
    _arabicIndicDigits[i]: _westernDigits[i],
    _persianDigits[i]: _westernDigits[i],
  },
  '٫': '.',
  '،': '',
  ',': '',
};

extension WesternDigits on String {
  String toWesternDigits() {
    final buffer = StringBuffer();
    for (final ch in split('')) {
      buffer.write(_digitMap[ch] ?? ch);
    }
    return buffer.toString();
  }
}
