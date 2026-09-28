/// Arabic weekday labels keyed by [DateTime.weekday].
const arabicWeekdayNames = <int, String>{
  DateTime.monday: 'الاثنين',
  DateTime.tuesday: 'الثلاثاء',
  DateTime.wednesday: 'الأربعاء',
  DateTime.thursday: 'الخميس',
  DateTime.friday: 'الجمعة',
  DateTime.saturday: 'السبت',
  DateTime.sunday: 'الأحد',
};

/// Display order used by the weekly-closure picker.
const arabicWeekdayDisplayOrder = <int>[
  DateTime.saturday,
  DateTime.sunday,
  DateTime.monday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday,
  DateTime.friday,
];
