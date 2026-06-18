import 'package:carehub_app/features/home/home_screen.dart';
import 'package:carehub_app/core/enums/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _loading = false;
  bool _isSignUp = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  UserRole _selectedRole = UserRole.contributor;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final supabase = Supabase.instance.client;

      final res = await supabase.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (res.session == null) {
        throw Exception("Invalid credentials or email not confirmed");
      }

      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError("Sign in failed. Please try again.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      _showError("Passwords do not match");
      return;
    }

    setState(() => _loading = true);

    try {
      final supabase = Supabase.instance.client;

      final res = await supabase.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        data: {'role': _selectedRole.name},
      );

      if (res.user == null) {
        throw Exception("Signup failed");
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created. Check email to confirm 📩"),
        ),
      );

      setState(() {
        _isSignUp = false;
        _emailCtrl.clear();
        _passwordCtrl.clear();
        _confirmPasswordCtrl.clear();
        _selectedRole = UserRole.contributor;
      });
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError("Sign up failed. Please try again.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: "io.supabase.carehub://login-callback",
      );
    } catch (_) {
      _showError("Google login failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2D0B4E), Color(0xFF6A1B9A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  "CAREHUB",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Dignity. Care. Confidence. 💜",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (v) => v != null && v.contains("@")
                              ? null
                              : "Enter valid email",
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Enter password";
                            }
                            if (_isSignUp && v.length < 8) {
                              return "Min 8 characters required";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        if (_isSignUp)
                          TextFormField(
                            controller: _confirmPasswordCtrl,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (v) {
                              if (!_isSignUp) return null;
                              if (v != _passwordCtrl.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),

                        if (_isSignUp) const SizedBox(height: 16),

                        if (_isSignUp)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "I am a:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...UserRole.values.map((role) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedRole = role),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _selectedRole == role
                                              ? const Color(0xFF6A1B9A)
                                              : Colors.grey[300]!,
                                          width: _selectedRole == role ? 2 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        color: _selectedRole == role
                                            ? const Color(
                                                0xFF6A1B9A,
                                              ).withOpacity(0.1)
                                            : Colors.transparent,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Radio<UserRole>(
                                                value: role,
                                                groupValue: _selectedRole,
                                                onChanged: (r) => setState(
                                                  () => _selectedRole = r!,
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      role.displayName,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      role.description,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),

                        const SizedBox(height: 20),

                        _loading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6A1B9A),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: _isSignUp ? _signUp : _signIn,
                                  child: Text(
                                    _isSignUp ? "Create Account" : "Sign In",
                                  ),
                                ),
                              ),

                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          child: Text(
                            _isSignUp
                                ? "Already have an account? Sign in"
                                : "No account? Create one",
                          ),
                        ),

                        const Divider(),

                        const Text("Quick login"),

                        const SizedBox(height: 10),

                        ElevatedButton.icon(
                          onPressed: _signInWithGoogle,
                          icon: const Icon(Icons.g_mobiledata),
                          label: const Text("Google"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
