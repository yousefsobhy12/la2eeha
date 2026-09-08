// lib/features/auth/presentation/cubit/register_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository repository;

  RegisterCubit(this.repository) : super(const RegisterInitial());

  Future<void> register(String name, String email, String password) async {
    emit(const RegisterLoading());
    final result = await repository.signUp(
      email: email,
      password: password,
      name: name,
    );
    result.fold(
      (failure) => emit(RegisterError(failure)),
      (_) => emit(RegisterSuccess(email)),
    );
  }
}
