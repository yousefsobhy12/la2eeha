// lib/core/network/safe_supabase_call.dart
//
// الفانكشن المركزية اللي بتغلف أي Supabase call بـ:
//   1. فحص اتصال (connectivity check)
//   2. try/catch موحد بيحول كل Exception لـ Failure المناسب
//   3. logging لكل حاجة (نجاح / فشل / نوع الخطأ)
//
// بدل ما كل Repository method يكرر نفس الـ try/catch boilerplate،
// بتنادي الفانكشن دي مرة واحدة وخلاص.

import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/failures.dart';
import 'app_logger.dart';
import 'network_info.dart';

/// بتنفذ [call] بأمان — لو مفيش نت بترجع NetworkFailure من غير ما تحاول أصلاً.
/// لو فيه نت، بتنفذ وتمسك أي exception وتحوله للـ Failure المناسب.
Future<Either<Failure, T>> safeSupabaseCall<T>(
  Future<T> Function() call, {
  required String callName,
  Failure Function(AuthException e)? onAuthException,
}) async {
  // 1. فحص الاتصال الأول — لو مفيش نت، مش هنحاول أصلاً.
  final isConnected = await networkInfo.isConnected;
  if (!isConnected) {
    appLogger.w('[$callName] No internet connection — call skipped.');
    return const Left(NetworkFailure());
  }

  // 2. تنفيذ الـ call مع mapping لكل نوع exception.
  try {
    final result = await call();
    appLogger.i('[$callName] Success.');
    return Right(result);
  } on PostgrestException catch (e) {
    appLogger.e('[$callName] PostgrestException: ${e.message}');
    return Left(ServerFailure(e.message));
  } on AuthException catch (e) {
    appLogger.e('[$callName] AuthException: ${e.message}');
    return Left(
      onAuthException != null
          ? onAuthException(e)
          : ServerFailure(e.message),
    );
  } on SocketException catch (e) {
    appLogger.e('[$callName] SocketException: $e');
    return const Left(NetworkFailure());
  } on TimeoutException catch (e) {
    appLogger.e('[$callName] TimeoutException: $e');
    return const Left(NetworkFailure('انتهت مهلة الاتصال، حاول تاني'));
  } catch (e) {
    appLogger.e('[$callName] Unexpected error: $e');
    return const Left(UnexpectedFailure());
  }
}
