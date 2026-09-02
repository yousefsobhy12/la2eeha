extension TimeStringFormat on String {
  /// "14:30:00" -> "2:30 م"   |   "09:00:00" -> "9:00 ص"
  String toArabicTime() {
    final parts = split(':');
    var hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'م' : 'ص';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
  }
}
