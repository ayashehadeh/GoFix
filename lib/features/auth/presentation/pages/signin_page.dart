import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/core/utils/login_helper.dart';
import 'package:gp/core/utils/snackbar_helper.dart';
import 'package:gp/l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/app_error_dialog.dart';
import '../widgets/blur_validated_field.dart';
import 'reset_password.dart';
import 'sign_up.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          LoginSubmitted(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
          ),
        );
  }

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthLoggedIn) {
          showSuccessSnackbar(context, t.welcomeUser(state.user.firstName));
          await LoginHelper.navigateAfterLogin(context);
        }
        if (state is AuthError) {
          AppDialog.showError(
            context,
            title: 'Couldn\'t sign you in',
            message: state.message,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

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
                Text(t.quickSignIn, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BlurValidatedField(
                              label: t.enterEmail,
                              controller: _emailCtrl,
                              icon: Icons.email,
                              hint: t.emailExampleHint,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),
                            BlurValidatedField(
                              label: t.password,
                              controller: _passwordCtrl,
                              icon: Icons.lock,
                              hint: '••••••••',
                              obscure: _obscurePassword,
                              onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                              validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                            ),
                            const SizedBox(height: 12),

                            // Forgot password (Remember me removed)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<AuthBloc>(),
                                      child: const ResetPassword(),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  t.forgotPassword,
                                  style: TextStyle(color: AppColors.accent),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Login button
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
                                onPressed: isLoading ? null : _submit,
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
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
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (_) => BlocProvider.value(
                                                value: context.read<AuthBloc>(),
                                                child: const Signup(),
                                              ),
                                            ),
                                          );
                                        },
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
