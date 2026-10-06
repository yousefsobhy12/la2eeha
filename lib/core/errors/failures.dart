abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'مفيش اتصال بالإنترنت، تأكد من الشبكة وحاول تاني',
  ]);
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'حصلت مشكلة في تحميل البيانات، حاول تاني',
  ]);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'حصل خطأ غير متوقع، حاول تاني']);
}

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
      return const AuthFailure('الإيميل ده مسجل قبل كده، جرّب تسجّل دخول');
    }
    if (lower.contains('expired')) {
      return const AuthFailure('الكود منتهي، اطلب كود جديد');
    }
    if (lower.contains('invalid otp') ||
        lower.contains('otp_disabled') ||
        lower.contains('invalid token')) {
      return const AuthFailure('الكود غلط أو منتهي');
    }
    if (lower.contains('should be different')) {
      return const AuthFailure('كلمة السر الجديدة لازم تختلف عن القديمة');
    }
    if (lower.contains('password')) {
      return const AuthFailure('كلمة السر ضعيفة — استخدم 6 حروف على الأقل');
    }
    if (lower.contains('rate limit') || lower.contains('too many')) {
      return const AuthFailure('طلبات كتير، استنى شوية وحاول تاني');
    }
    return AuthFailure(errorMessage);
  }
}
