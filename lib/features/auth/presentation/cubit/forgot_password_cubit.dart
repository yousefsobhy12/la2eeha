import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepository repository;

  ForgotPasswordCubit(this.repository)
      : super(const ForgotPasswordInitial());

  Future<void> sendResetCode(String email) async {
    emit(const ForgotPasswordLoading());
    final result = await repository.sendPasswordResetOtp(email: email);
    result.fold(
      (failure) => emit(ForgotPasswordError(failure)),
      (_) => emit(const ForgotPasswordSuccess()),
    );
  }
}

