extension TextDirectionDetection on String {
  bool get isMostlyArabic {
    if (isEmpty) return true;
    final arabicPattern = RegExp(r'[\u0600-\u06FF]');
    return arabicPattern.hasMatch(this[0]);
  }
}
