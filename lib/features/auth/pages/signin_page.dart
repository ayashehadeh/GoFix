import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD:lib/auth/pages/signin_page.dart
import 'package:gp/core/storage/token_storage.dart';
=======
import 'package:gp/features/auth/pages/reset_password.dart';
import 'package:gp/features/auth/services/auth_service.dart';
>>>>>>> 7cb56b76def373e493976b300645a6599eeb54ae:lib/features/auth/pages/signin_page.dart
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/core/storage/token_storage.dart';
import 'package:gp/l10n/app_localizations.dart';
<<<<<<< HEAD:lib/auth/pages/signin_page.dart
import 'reset_password.dart';
=======
import 'package:gp/features/home/presentation/pages/home_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/injection_container.dart' as di;
import 'package:gp/features/home/presentation/bloc/home_bloc.dart';
>>>>>>> 7cb56b76def373e493976b300645a6599eeb54ae:lib/features/auth/pages/signin_page.dart

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
<<<<<<< HEAD:lib/auth/pages/signin_page.dart
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Login logic ────────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showError('Please enter your phone number and password.');
=======
  final TextEditingController emailController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading  = false;

  final AuthService _authService = AuthService();

  // ─── Login Logic ──────────────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter your email and password.');
>>>>>>> 7cb56b76def373e493976b300645a6599eeb54ae:lib/features/auth/pages/signin_page.dart
      return;
    }

    setState(() => _isLoading = true);

    try {
<<<<<<< HEAD:lib/auth/pages/signin_page.dart
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://your-api.com/api',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final response = await dio.post(
        '/auth/login',
        data: {'phone': phone, 'password': password},
      );

      final data = response.data;

      // Save token and user info
      await TokenStorage.saveToken(
        token: data['token'] as String,
        userId: data['userId'] as String,
        role: data['role'] as String,
=======
      final result = await _authService.login(
        email: email,
        password: password,
      );

      final token = result['data']['token'] as String;
      final user  = result['data']['user'];

      // Save token and user info to local storage
      await TokenStorage.saveToken(
        token: token,
        userId: user['id'] as String,
        role: user['role'] as String,
>>>>>>> 7cb56b76def373e493976b300645a6599eeb54ae:lib/features/auth/pages/signin_page.dart
      );

      if (!mounted) return;

<<<<<<< HEAD:lib/auth/pages/signin_page.dart
      // Navigate to home and clear the back stack
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] as String? ??
          'Login failed. Please check your credentials.';
      _showError(message);
    } catch (e) {
      _showError('An unexpected error occurred. Please try again.');
=======
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${user['firstName']}!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<HomeBloc>(),
            child: const HomePage(),
          ),
        ),
      );
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
>>>>>>> 7cb56b76def373e493976b300645a6599eeb54ae:lib/features/auth/pages/signin_page.dart
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD:lib/auth/pages/signin_page.dart
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
=======
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
>>>>>>> 7cb56b76def373e493976b300645a6599eeb54ae:lib/features/auth/pages/signin_page.dart

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(backgroundColor: AppColors.primary, elevation: 0),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Image.asset('assets/logo2.png', fit: BoxFit.contain),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              t.welcomeBack,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),
<<<<<<< HEAD:lib/auth/pages/signin_page.dart

            Text(t.quickSignIn, style: const TextStyle(color: Colors.white70)),

=======
            Text(t.quickSignIn, style: const TextStyle(color: Colors.white70)),
>>>>>>> 7cb56b76def373e493976b300645a6599eeb54ae:lib/features/auth/pages/signin_page.dart
            const SizedBox(height: 30),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
<<<<<<< HEAD:lib/auth/pages/signin_page.dart
                      // Phone field
                      Text(
                        t.enterPhone,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
=======

                      // ── Email ────────────────────────────────────────────
                      Text(t.enterEmail, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
>>>>>>> 7cb56b76def373e493976b300645a6599eeb54ae:lib/features/auth/pages/signin_page.dart
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          hintText: 'example@email.com',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

<<<<<<< HEAD:lib/auth/pages/signin_page.dart
                      // Password field
                      Text(
                        t.password,
                        style: const TextStyle(color: Colors.grey),
                      ),
=======
                      // ── Password ─────────────────────────────────────────
                      Text(t.password, style: const TextStyle(color: Colors.grey)),
>>>>>>> 7cb56b76def373e493976b300645a6599eeb54ae:lib/features/auth/pages/signin_page.dart
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

<<<<<<< HEAD:lib/auth/pages/signin_page.dart
                      // Remember me + Forgot password
=======
                      // ── Remember me / Forgot password ─────────────────────
>>>>>>> 7cb56b76def373e493976b300645a6599eeb54ae:lib/features/auth/pages/signin_page.dart
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
<<<<<<< HEAD:lib/auth/pages/signin_page.dart
                            onChanged: (value) =>
                                setState(() => _rememberMe = value!),
=======
                            onChanged: (v) => setState(() => _rememberMe = v!),
>>>>>>> 7cb56b76def373e493976b300645a6599eeb54ae:lib/features/auth/pages/signin_page.dart
                          ),
                          Text(t.rememberMe),
                          const Spacer(),
                          TextButton(
<<<<<<< HEAD:lib/auth/pages/signin_page.dart
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ResetPassword(),
                                ),
                              );
                            },
=======
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ResetPassword()),
                            ),
>>>>>>> 7cb56b76def373e493976b300645a6599eeb54ae:lib/features/auth/pages/signin_page.dart
                            child: Text(
                              t.forgotPassword,
                              style: TextStyle(color: AppColors.accent),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

<<<<<<< HEAD:lib/auth/pages/signin_page.dart
                      // Sign In button
=======
                      // ── Login Button ──────────────────────────────────────
>>>>>>> 7cb56b76def373e493976b300645a6599eeb54ae:lib/features/auth/pages/signin_page.dart
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
<<<<<<< HEAD:lib/auth/pages/signin_page.dart
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
=======
                              ? const CircularProgressIndicator(color: Colors.white)
>>>>>>> 7cb56b76def373e493976b300645a6599eeb54ae:lib/features/auth/pages/signin_page.dart
                              : Text(
                                  t.signIn,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Register link
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: t.newMember,
                            style: const TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: t.registerNow,
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
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
          ],
        ),
      ),
    );
  }
}