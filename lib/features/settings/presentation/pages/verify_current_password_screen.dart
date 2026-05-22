import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/features/settings/presentation/bloc/set_password_bloc.dart';
import 'package:gp/features/settings/presentation/pages/set_new_password_screen.dart';
import 'package:gp/features/settings/presentation/widgets/password_field.dart';
import 'package:gp/l10n/app_localizations.dart';

class VerifyCurrentPasswordScreen extends StatefulWidget {
  const VerifyCurrentPasswordScreen({super.key});

  @override
  State<VerifyCurrentPasswordScreen> createState() =>
      _VerifyCurrentPasswordScreenState();
}

class _VerifyCurrentPasswordScreenState
    extends State<VerifyCurrentPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      context
          .read<SetPasswordBloc>()
          .add(VerifyCurrentPasswordEvent(_controller.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<SetPasswordBloc, SetPasswordState>(
        listener: (context, state) {
          if (state is VerifyPasswordSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<SetPasswordBloc>(),
                  child: SetNewPasswordScreen(
                    currentPassword: _controller.text.trim(),
                  ),
                ),
              ),
            );
          }
          if (state is SetPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Builder(builder: (context) {
                    final t = AppLocalizations.of(context)!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.verifyIdentity, style: AppTextStyles.heading1),
                        const SizedBox(height: 6),
                        Text(t.enterCurrentPassword, style: AppTextStyles.bodySmall),
                      ],
                    );
                  }),
                  const SizedBox(height: 32),
                  PasswordField(
                    controller: _controller,
                    label: AppLocalizations.of(context)!.currentPasswordLabel,
                    obscure: _obscure,
                    onToggle: () => setState(() => _obscure = !_obscure),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return AppLocalizations.of(context)!.currentPasswordRequired;
                      }
                      return null;
                    },
                  ),
                  const Spacer(),
                  BlocBuilder<SetPasswordBloc, SetPasswordState>(
                    builder: (context, state) {
                      final isLoading = state is SetPasswordLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            disabledBackgroundColor:
                                AppColors.primaryOrange.withValues(alpha: 0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context)!.continue1,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
