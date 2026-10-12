String placeChangeItemLabel(String item) {
  switch (item) {
    case 'info':
      return 'المعلومات';
    case 'description':
      return 'الوصف';
    case 'photo':
      return 'الصورة';
    case 'hours':
      return 'المواعيد';
    case 'menu':
      return 'المنيو';
    case 'sports':
      return 'الأسعار';
    default:
      return item;
  }
}
