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

/// فشل متعلق بعمليات تسجيل الدخول / التسجيل / التحقق
class AuthFailure extends Failure {
  const AuthFailure(super.message);

  factory AuthFailure.fromAuthException(String errorMessage) {
    final lower = errorMessage.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials')) {
      return const AuthFailure('الإيميل أو كلمة السر غلط');
    }
    if (lower.contains('user already registered') ||
        lower.contains('already been registered')) {
      return const AuthFailure(
        'الإيميل ده مسجل قبل كده، جرّب تسجّل دخول',
      );
    }
    if (lower.contains('expired')) {
      return const AuthFailure('الكود منتهي، اطلب كود جديد');
    }
    if (lower.contains('invalid otp') ||
        lower.contains('otp_disabled') ||
        lower.contains('invalid token')) {
      return const AuthFailure('الكود غلط أو منتهي');
    }
    if (lower.contains('password')) {
      return const AuthFailure(
        'كلمة السر ضعيفة — استخدم 6 حروف على الأقل',
      );
    }
    if (lower.contains('rate limit') || lower.contains('too many')) {
      return const AuthFailure('طلبات كتير، استنى شوية وحاول تاني');
    }
    return AuthFailure(errorMessage);
  }
}
