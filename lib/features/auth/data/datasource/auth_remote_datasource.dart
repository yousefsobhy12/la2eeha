// lib/features/auth/data/datasource/auth_remote_datasource.dart
//
// دي الطبقة الوحيدة اللي بتكلم Supabase Auth مباشرة.
// الـ methods هنا بترمي exceptions عادي — الـ safeSupabaseCall في الـ
// Repository هو اللي بيمسكها ويحولها لـ AuthFailure.

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client_provider.dart';

/// Guard flag so `GoogleSignIn.instance.initialize()` is called only once
/// per app session, as required by the package docs.
bool _googleSignInInitialized = false;

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
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<bool> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    if (!_googleSignInInitialized) {
      await googleSignIn.initialize(
        serverClientId:
            '31279045453-2shtf9c41cdn9jrst29vkkrhtfdm9sre.apps.googleusercontent.com',
      );
      _googleSignInInitialized = true;
    }

    final GoogleSignInAccount googleUser;
    try {
      googleUser = await googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User cancelled the Google account picker — not an error.
        return false;
      }
      rethrow;
    }

    final idToken = googleUser.authentication.idToken;

    if (idToken == null) {
      throw const AuthException('Google Sign-In failed: no ID token returned');
    }

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    return true;
  }
}
