// lib/features/auth/presentation/cubit/register_state.dart

import '../../../../core/errors/failures.dart';

abstract class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  /// الإيميل بيتمرر للـ VerifyEmailView عشان يبعتله الكود
  final String email;
  const RegisterSuccess(this.email);
}

class RegisterError extends RegisterState {
  final Failure failure;
  const RegisterError(this.failure);
}
