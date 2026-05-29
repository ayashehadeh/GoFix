import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/core/utils/snackbar_helper.dart';
import 'package:gp/l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'changed.dart';

class ResetPassword2 extends StatefulWidget {
  const ResetPassword2({super.key});

  @override
  State<ResetPassword2> createState() => _ResetPassword2State();
}

class _ResetPassword2State extends State<ResetPassword2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tokenCtrl = TextEditingController();
  final TextEditingController _newPasswordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(ResetPasswordSubmitted(
            token: _tokenCtrl.text.trim(),
            newPassword: _newPasswordCtrl.text,
            confirmPassword: _confirmPasswordCtrl.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordReset) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PasswordChangedScreen()),
          );
        }
        if (state is AuthError) {
          showErrorSnackbar(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: const Color(0xFF062B54),
          appBar:
              AppBar(backgroundColor: const Color(0xFF062B54), elevation: 0),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50),
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset('assets/reset_password.png',
                        fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 30),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.setNewPassword,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t.createStrongPassword,
                              style: TextStyle(
                                  color: AppColors.primary, fontSize: 13),
                            ),
                            const SizedBox(height: 30),
                            Text(t.resetCode,
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _tokenCtrl,
                              keyboardType: TextInputType.text,
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? t.resetCodeRequired
                                      : null,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.vpn_key_outlined),
                                hintText: t.enterResetCode,
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            Text(t.newPassword,
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _newPasswordCtrl,
                              obscureText: _obscureNew,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return t.passwordEmpty;
                                }
                                if (v.length < 8) {
                                  return t.passwordTooShort;
                                }
                                if (!v.contains(RegExp(r'[A-Z]'))) {
                                  return 'Must contain an uppercase letter.';
                                }
                                if (!v.contains(RegExp(r'[a-z]'))) {
                                  return 'Must contain a lowercase letter.';
                                }
                                if (!v.contains(RegExp(r'\d'))) {
                                  return 'Must contain a number.';
                                }
                                if (!v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'))) {
                                  return 'Must contain a special character.';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureNew
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(
                                      () => _obscureNew = !_obscureNew),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            Text(t.confirmPassword,
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _confirmPasswordCtrl,
                              obscureText: _obscureConfirm,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return t.confirmPassword;
                                }
                                if (v != _newPasswordCtrl.text) {
                                  return t.passwordNotMatch;
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 60),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: isLoading ? null : _submit,
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5))
                                    : Text(
                                        t.resetPassword,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
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
