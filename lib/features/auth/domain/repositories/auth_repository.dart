import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, void>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String token,
  });

  Future<Either<Failure, void>> resendOtp({required String email});

  Future<Either<Failure, void>> sendPasswordResetOtp({required String email});

  Future<Either<Failure, void>> verifyRecoveryOtp({
    required String email,
    required String token,
  });

  Future<Either<Failure, void>> updatePassword({required String newPassword});

  Future<Either<Failure, bool>> signInWithGoogle();
}
