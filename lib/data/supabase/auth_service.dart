import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static SupabaseClient get _client => Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;

  static Stream<User?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((e) => e.session?.user);

  static Future<void> signIn(String email, String password) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = res.user ?? _client.auth.currentUser;
    if (user == null) {
      throw Exception('Sign in failed');
    }
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
