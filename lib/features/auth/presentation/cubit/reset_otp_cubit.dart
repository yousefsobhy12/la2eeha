import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'reset_otp_state.dart';

class ResetOtpCubit extends Cubit<ResetOtpState> {
  final AuthRepository repository;
  Timer? _countdownTimer;

  ResetOtpCubit(this.repository) : super(const ResetOtpState()) {
    _startCountdown();
  }

  Future<void> verify(String email, String code) async {
    emit(state.copyWith(status: ResetOtpStatus.loading));
    final result = await repository.verifyRecoveryOtp(
      email: email,
      token: code,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: ResetOtpStatus.error, failure: failure),
      ),
      (_) => emit(state.copyWith(status: ResetOtpStatus.success)),
    );
  }

  Future<void> resend(String email) async {
    final result = await repository.sendPasswordResetOtp(email: email);
    result.fold(
      (failure) => emit(
        state.copyWith(status: ResetOtpStatus.error, failure: failure),
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

