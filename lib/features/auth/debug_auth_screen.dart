import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DebugAuthScreen extends StatefulWidget {
  const DebugAuthScreen({super.key});

  @override
  State<DebugAuthScreen> createState() => _DebugAuthScreenState();
}

class _DebugAuthScreenState extends State<DebugAuthScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  String log = 'Testing Supabase Auth...\n';

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  // ---------------- CONNECTION TEST ----------------
  Future<void> _testConnection() async {
    try {
      final supabase = Supabase.instance.client;

      _log('✓ Supabase initialized');

      // FIX: no supabaseUrl / supabaseKey in v2
      _log('Auth ready: ${supabase.auth.currentSession != null ? "Active session" : "No session"}');

      _log('User: ${supabase.auth.currentUser?.id ?? "No user"}');
    } catch (e) {
      _log('✗ Connection error: $e');
    }
  }

  // ---------------- SIGN UP TEST ----------------
  Future<void> _testSignUp() async {
    _log('\n--- Testing Sign Up ---');

    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _log('✗ Email/password empty');
      return;
    }

    try {
      _log('Sending signup request...');

      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        _log('✓ Signup success: ${res.user!.id}');
      } else {
        _log('⚠ Signup returned null user (check email confirmation settings)');
      }
    } on AuthException catch (e) {
      _log('✗ AuthException: ${e.message}');
    } catch (e) {
      _log('✗ Error: $e');
    }
  }

  // ---------------- SIGN IN TEST ----------------
  Future<void> _testSignIn() async {
    _log('\n--- Testing Sign In ---');

    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _log('✗ Email/password empty');
      return;
    }

    try {
      _log('Sending signin request...');

      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.session != null) {
        _log('✓ Signin success: ${res.user?.id}');
        _log('Session active ✔');
      } else {
        _log('⚠ No session returned');
      }
    } on AuthException catch (e) {
      _log('✗ AuthException: ${e.message}');
    } catch (e) {
      _log('✗ Error: $e');
    }
  }

  // ---------------- LOGGING ----------------
  void _log(String msg) {
    setState(() => log += '$msg\n');
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Auth')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                ElevatedButton(
                  onPressed: _testSignUp,
                  child: const Text('Test SignUp'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _testSignIn,
                  child: const Text('Test SignIn'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                log,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }
}