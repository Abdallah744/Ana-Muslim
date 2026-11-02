import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRemoteDataSource {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  static const String _guestKey = 'is_guest_mode';

  /// Sign up with Email and Password
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      return response;
    } catch (e) {
      throw Exception('فشل إنشاء الحساب: $e');
    }
  }

  /// Sign in with Email and Password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await setGuestMode(false);
      return response;
    } catch (e) {
      throw Exception('فشل تسجيل الدخول: $e');
    }
  }

  /// Sign in with Google Account OAuth
  Future<bool> signInWithGoogle() async {
    try {
      final res = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.ana_muslim://login-callback',
      );
      await setGuestMode(false);
      return res;
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('validation_failed') || errStr.contains('provider_not_enabled') || errStr.contains('Unsupported provider')) {
        throw Exception('PROVIDER_NOT_ENABLED');
      }
      throw Exception('فشل التسجيل بحساب Google: $e');
    }
  }

  /// Save Guest Mode State
  static Future<void> setGuestMode(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestKey, isGuest);
  }

  /// Check if Current User is Guest
  static Future<bool> isGuestUser() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isGuest = prefs.getBool(_guestKey) ?? false;
    final session = Supabase.instance.client.auth.currentSession;
    return isGuest || session == null;
  }

  /// Sign out
  Future<void> signOut() async {
    await setGuestMode(false);
    await _supabaseClient.auth.signOut();
  }
}
