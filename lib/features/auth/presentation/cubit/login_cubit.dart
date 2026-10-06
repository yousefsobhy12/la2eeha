import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository repository;

  LoginCubit(this.repository) : super(const LoginInitial());

  Future<void> login(String email, String password) async {
    emit(const LoginLoading());
    final result = await repository.signIn(email: email, password: password);
    result.fold(
      (failure) => emit(LoginError(failure)),
      (_) => emit(const LoginSuccess()),
    );
  }

  Future<void> signInWithGoogle() async {
    emit(const LoginLoading());
    final result = await repository.signInWithGoogle();
    result.fold((failure) => emit(LoginError(failure)), (completed) {
      if (completed) {
        emit(const LoginSuccess());
      } else {
        emit(const LoginInitial());
      }
    });
  }
}
