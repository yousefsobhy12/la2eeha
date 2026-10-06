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
  final String email;
  const RegisterSuccess(this.email);
}

class RegisterError extends RegisterState {
  final Failure failure;
  const RegisterError(this.failure);
}
