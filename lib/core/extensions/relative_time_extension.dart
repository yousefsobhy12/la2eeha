extension RelativeTimeFormat on DateTime {
  String toRelativeArabic({DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(this);
    if (diff.isNegative) return 'اليوم';

    final days = diff.inDays;
    if (days == 0) return 'اليوم';
    if (days == 1) return 'امبارح';
    if (days == 2) return 'من يومين';
    if (days <= 10) return 'من $days أيام';
    if (days <= 29) return 'من $days يوم';

    if (days < 365) {
      final months = days ~/ 30;
      if (months == 1) return 'من شهر';
      if (months == 2) return 'من شهرين';
      if (months <= 10) return 'من $months شهور';
      return 'من $months شهر';
    }

    final years = days ~/ 365;
    if (years == 1) return 'من سنة';
    if (years == 2) return 'من سنتين';
    if (years <= 10) return 'من $years سنين';
    return 'من $years سنة';
  }
}
