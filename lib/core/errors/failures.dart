// lib/core/errors/failures.dart
//
// كل حاجة بترجع من الـ Repository لازم تبقى إما نجاح أو Failure — بدل ما نرمي
// Exception عادي ونمسكه بـ try/catch جوه كل Cubit لوحده. الفايدة الحقيقية:
// كل Cubit بيعرف بالظبط نوع المشكلة (نت / سيرفر / حاجة تانية) ويقدر يعرض
// رسالة مختلفة لكل نوع، بدل رسالة عامة واحدة لكل الحالات.
//
// لو محتاج نوع جديد بعدين (مثلاً CacheFailure لما نلمس shared_preferences في
// الـ Favorites) — ضيفه هنا بنفس الشكل، مش قبل ما تحتاجه فعليًا.

abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// مفيش اتصال بالإنترنت خالص (SocketException من dart:io)
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'مفيش اتصال بالإنترنت، تأكد من الشبكة وحاول تاني',
  ]);
}

/// مشكلة راجعة من Supabase نفسه (query غلط، RLS رفضت الطلب، السيرفر واقع...)
class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'حصلت مشكلة في تحميل البيانات، حاول تاني',
  ]);
}

/// أي حاجة تانية مش متوقعة، مانعرفش نصنفها
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'حصل خطأ غير متوقع، حاول تاني',
  ]);
}
