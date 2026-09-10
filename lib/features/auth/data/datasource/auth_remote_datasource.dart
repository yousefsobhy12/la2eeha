// lib/features/auth/data/datasource/auth_remote_datasource.dart
//
// دي الطبقة الوحيدة اللي بتكلم Supabase Auth مباشرة.
// الـ methods هنا بترمي exceptions عادي — الـ safeSupabaseCall في الـ
// Repository هو اللي بيمسكها ويحولها لـ AuthFailure.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client_provider.dart';

class AuthRemoteDataSource {
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    // Supabase's email-enumeration protection: signUp() succeeds silently
    // (no exception, fake metadata, no email sent) when the email already
    // exists and is confirmed. An empty `identities` list is the documented
    // way to detect this case and treat it as "already registered".
    if (response.user != null &&
        (response.user!.identities?.isEmpty ?? false)) {
      throw const AuthException('User already registered');
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> verifyOtp({required String email, required String token}) async {
    await supabase.auth.verifyOTP(
      type: OtpType.signup,
      token: token,
      email: email,
    );
  }

  Future<void> resendOtp({required String email}) async {
    await supabase.auth.resend(type: OtpType.signup, email: email);
  }

  Future<void> sendPasswordResetOtp({required String email}) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> verifyRecoveryOtp({
    required String email,
    required String token,
  }) async {
    await supabase.auth.verifyOTP(
      type: OtpType.recovery,
      token: token,
      email: email,
    );
  }

  Future<void> updatePassword({required String newPassword}) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
