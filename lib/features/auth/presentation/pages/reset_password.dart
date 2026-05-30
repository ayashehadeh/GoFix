import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/core/utils/snackbar_helper.dart';
import 'package:gp/l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'checkurmail.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      showWarningSnackbar(context, AppLocalizations.of(context)!.pleaseEnterEmail);
      return;
    }
    context
        .read<AuthBloc>()
        .add(ForgotPasswordSubmitted(email: email));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthForgotPasswordSent) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AuthBloc>(),
                child: const Checkurmail(),
              ),
            ),
          );
        }
        if (state is AuthError) {
          showErrorSnackbar(context, state.message);
        }
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
                const SizedBox(height: 40),
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
                          Text(
                            t.resetPassword,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.resetPasswordDesc,
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13),
                          ),
                          const SizedBox(height: 30),
                          Text(t.enterEmail,
                              style:
                                  const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email),
                              hintText: 'example@email.com',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
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
                                      t.sendInstructions,
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
              ],
            ),
          ),
        );
      },
    );
  }
}
