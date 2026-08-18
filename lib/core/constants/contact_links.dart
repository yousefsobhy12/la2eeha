class ContactLinks {
  ContactLinks._();

  static const String whatsappNumber = '201000000000'; // بدون + أو أصفار زيادة
  static const String facebookPageUrl = 'https://facebook.com/PLACEHOLDER';
  static const String instagramUrl = 'https://instagram.com/PLACEHOLDER';
  static const String email = 'developer@example.com';

  static String get whatsappUrl => 'https://wa.me/$whatsappNumber';
  static String get emailUrl => 'mailto:$email';
}
