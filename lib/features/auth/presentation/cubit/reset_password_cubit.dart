import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRepository repository;

  ResetPasswordCubit(this.repository) : super(const ResetPasswordInitial());

  Future<void> updatePassword(String newPassword) async {
    emit(const ResetPasswordLoading());
    final result = await repository.updatePassword(newPassword: newPassword);
    result.fold(
      (failure) => emit(ResetPasswordError(failure)),
      (_) => emit(const ResetPasswordSuccess()),
    );
  }
}
