class ContactLinks {
  ContactLinks._();

  static const String whatsappNumber = '201015170512';
  static const String facebookPageUrl =
      'https://www.facebook.com/yousef.aboesmael';

  static const String email = 'yousefsobhy124@gmail.com';

  static String get whatsappUrl => 'https://wa.me/$whatsappNumber';

  static Uri whatsappUriWithText(String text) =>
      Uri.https('wa.me', '/$whatsappNumber', {'text': text});

  static String get emailUrl => 'mailto:$email';

  // TODO: swap to the dedicated reports number later.
  static const String reportWhatsappNumber = '201015170512';

  static Uri reportUri({required String placeName, required int placeId}) {
    return Uri.https('wa.me', '/$reportWhatsappNumber', {
      'text': 'بلّغ عن مشكلة في: $placeName (رقم $placeId)',
    });
  }
}
