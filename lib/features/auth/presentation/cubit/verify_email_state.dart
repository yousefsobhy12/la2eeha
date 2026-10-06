import '../../../../core/errors/failures.dart';

enum VerifyEmailStatus { initial, loading, success, error }

class VerifyEmailState {
  final VerifyEmailStatus status;
  final Failure? failure;

  final int secondsRemaining;

  const VerifyEmailState({
    this.status = VerifyEmailStatus.initial,
    this.failure,
    this.secondsRemaining = 0,
  });

  VerifyEmailState copyWith({
    VerifyEmailStatus? status,
    Failure? failure,
    int? secondsRemaining,
  }) {
    return VerifyEmailState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    );
  }
}
