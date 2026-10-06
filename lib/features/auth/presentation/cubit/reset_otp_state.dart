import '../../../../core/errors/failures.dart';

enum ResetOtpStatus { initial, loading, success, error }

class ResetOtpState {
  final ResetOtpStatus status;
  final Failure? failure;

  final int secondsRemaining;

  const ResetOtpState({
    this.status = ResetOtpStatus.initial,
    this.failure,
    this.secondsRemaining = 0,
  });

  ResetOtpState copyWith({
    ResetOtpStatus? status,
    Failure? failure,
    int? secondsRemaining,
  }) {
    return ResetOtpState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    );
  }
}
