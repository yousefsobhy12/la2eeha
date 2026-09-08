// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/safe_supabase_call.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> signUp({
    required String email,
    required String password,
    required String name,
  }) {
    return safeSupabaseCall<void>(
      () => remoteDataSource.signUp(
        email: email,
        password: password,
        name: name,
      ),
      callName: 'AuthRepository.signUp',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }

  @override
  Future<Either<Failure, void>> signIn({
    required String email,
    required String password,
  }) {
    return safeSupabaseCall<void>(
      () => remoteDataSource.signIn(email: email, password: password),
      callName: 'AuthRepository.signIn',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }

  @override
  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String token,
  }) {
    return safeSupabaseCall<void>(
      () => remoteDataSource.verifyOtp(email: email, token: token),
      callName: 'AuthRepository.verifyOtp',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }

  @override
  Future<Either<Failure, void>> resendOtp({required String email}) {
    return safeSupabaseCall<void>(
      () => remoteDataSource.resendOtp(email: email),
      callName: 'AuthRepository.resendOtp',
      onAuthException: (e) => AuthFailure.fromAuthException(e.message),
    );
  }
}
