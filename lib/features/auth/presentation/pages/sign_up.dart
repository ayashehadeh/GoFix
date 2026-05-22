import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'created.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl =
      TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirmPassword = _confirmPasswordCtrl.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _showError('Please fill in all required fields.');
      return;
    }
    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }
    if (password.length < 8) {
      _showError('Password must be at least 8 characters.');
      return;
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      _showError('Password must contain at least one uppercase letter.');
      return;
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      _showError('Password must contain at least one lowercase letter.');
      return;
    }
    if (!password.contains(RegExp(r'\d'))) {
      _showError('Password must contain at least one number.');
      return;
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'))) {
      _showError('Password must contain at least one special character.');
      return;
    }

    context.read<AuthBloc>().add(RegisterSubmitted(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: _phoneCtrl.text.trim(),
          password: password,
          confirmPassword: confirmPassword,
        ));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistered) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const Created()),
          );
        }
        if (state is AuthError) _showError(state.message);
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.primary,
          appBar:
              AppBar(backgroundColor: AppColors.primary, elevation: 0),
          body: SafeArea(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset('assets/logo2.png',
                        fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 30),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Field(t.firstName, _firstNameCtrl,
                              Icons.person),
                          const SizedBox(height: 10),
                          _Field(t.lastName, _lastNameCtrl,
                              Icons.person),
                          const SizedBox(height: 10),
                          _Field(t.enterPhone, _phoneCtrl,
                              Icons.phone_android,
                              keyboardType: TextInputType.phone),
                          const SizedBox(height: 10),
                          _Field(t.enterEmail, _emailCtrl, Icons.email,
                              keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 10),
                          _Field(t.password, _passwordCtrl, Icons.lock,
                              obscure: true),
                          const SizedBox(height: 10),
                          _Field(t.confirmPassword,
                              _confirmPasswordCtrl, Icons.lock,
                              obscure: true),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(
                                    t.signUp,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: t.alreadyHaveAccount,
                                style: const TextStyle(
                                    color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: t.signInSmall,
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
      },
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;

  const _Field(this.label, this.controller, this.icon,
      {this.obscure = false, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
