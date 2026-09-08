// lib/features/auth/presentation/cubit/verify_email_cubit.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'verify_email_state.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  final AuthRepository repository;
  Timer? _countdownTimer;

  VerifyEmailCubit(this.repository) : super(const VerifyEmailState()) {
    _startCountdown();
  }

  Future<void> verify(String email, String code) async {
    emit(state.copyWith(status: VerifyEmailStatus.loading));
    final result = await repository.verifyOtp(email: email, token: code);
    result.fold(
      (failure) => emit(
        state.copyWith(status: VerifyEmailStatus.error, failure: failure),
      ),
      (_) => emit(state.copyWith(status: VerifyEmailStatus.success)),
    );
  }

  Future<void> resend(String email) async {
    final result = await repository.resendOtp(email: email);
    result.fold(
      (failure) => emit(
        state.copyWith(status: VerifyEmailStatus.error, failure: failure),
      ),
      (_) => _startCountdown(),
    );
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    emit(state.copyWith(secondsRemaining: 60));
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.secondsRemaining - 1;
      if (remaining <= 0) {
        timer.cancel();
        emit(state.copyWith(secondsRemaining: 0));
      } else {
        emit(state.copyWith(secondsRemaining: remaining));
      }
    });
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
