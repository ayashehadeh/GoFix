import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/app_error_dialog.dart';
import '../widgets/blur_validated_field.dart';
import 'signin_page.dart';
import 'verify_email_page.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
    // On submit, validate everything at once (covers fields never focused).
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(RegisterSubmitted(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: '+962${_phoneCtrl.text.trim()}',
          password: _passwordCtrl.text,
          confirmPassword: _confirmPasswordCtrl.text,
        ));
  }

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? v, AppLocalizations t) {
    final value = v ?? '';
    if (value.isEmpty) return t.passwordEmpty;
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Add at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Add at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'\d'))) return 'Add at least one number';
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'))) {
      return 'Add at least one special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistered) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AuthBloc>(),
                child: VerifyEmailPage(email: state.user.email),
              ),
            ),
          );
        }
        if (state is AuthError) {
          AppDialog.showError(
            context,
            title: 'Couldn\'t create your account',
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
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset('assets/logo2edit.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 10),
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
                              label: t.firstName,
                              controller: _firstNameCtrl,
                              icon: Icons.person,
                              hint: 'e.g. Ahmad',
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'First name is required' : null,
                            ),
                            const SizedBox(height: 10),
                            BlurValidatedField(
                              label: t.lastName,
                              controller: _lastNameCtrl,
                              icon: Icons.person,
                              hint: 'e.g. Khalil',
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Last name is required' : null,
                            ),
                            const SizedBox(height: 10),
                            _PhoneField(
                              label: t.enterPhone,
                              controller: _phoneCtrl,
                              requiredMsg: t.phoneNumberRequired,
                              tooShortMsg: t.mustBe9Digits,
                            ),
                            const SizedBox(height: 10),
                            BlurValidatedField(
                              label: t.enterEmail,
                              controller: _emailCtrl,
                              icon: Icons.email,
                              hint: 'example@email.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 10),
                            BlurValidatedField(
                              label: t.password,
                              controller: _passwordCtrl,
                              icon: Icons.lock,
                              hint: '••••••••',
                              obscure: _obscurePassword,
                              onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                              validator: (v) => _validatePassword(v, t),
                            ),
                            const SizedBox(height: 10),
                            BlurValidatedField(
                              label: t.confirmPassword,
                              controller: _confirmPasswordCtrl,
                              icon: Icons.lock,
                              hint: '••••••••',
                              obscure: _obscureConfirm,
                              onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return t.confirmPasswordRequired;
                                }
                                if (v != _passwordCtrl.text) {
                                  return t.passwordNotMatch;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
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
                                  style: const TextStyle(color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: t.signInSmall,
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
                                                child: const SigninPage(),
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

// ─── Phone field with +962 prefix, validates on blur ────────────────────────

class _PhoneField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String requiredMsg;
  final String tooShortMsg;

  const _PhoneField({
    required this.label,
    required this.controller,
    required this.requiredMsg,
    required this.tooShortMsg,
  });

  @override
  State<_PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<_PhoneField> {
  final FocusNode _focusNode = FocusNode();
  String? _errorText;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _touched) {
        setState(() => _errorText = _validate(widget.controller.text));
      }
    });
  }

  String? _validate(String value) {
    final v = value.trim();
    if (v.isEmpty) return widget.requiredMsg;
    if (v.length < 9) return widget.tooShortMsg;
    return null;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('+962', style: TextStyle(fontSize: 15, color: Color(0xFF062B4D))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                autovalidateMode: AutovalidateMode.disabled,
                validator: (v) => _validate(v ?? ''),
                onChanged: (_) {
                  _touched = true;
                  if (_errorText != null) setState(() => _errorText = null);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone_android),
                  hintText: '7xxxxxxxxx',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  errorText: _errorText,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: _b(Colors.transparent),
                  enabledBorder: _b(Colors.transparent),
                  focusedBorder: _b(AppColors.accent, 1.5),
                  errorBorder: _b(Colors.red, 1.2),
                  focusedErrorBorder: _b(Colors.red, 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  OutlineInputBorder _b(Color c, [double w = 0]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: c == Colors.transparent ? BorderSide.none : BorderSide(color: c, width: w),
      );
}
