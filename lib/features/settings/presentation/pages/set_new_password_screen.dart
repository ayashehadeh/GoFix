import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/features/settings/presentation/bloc/set_password_bloc.dart';
import 'package:gp/features/settings/presentation/widgets/password_field.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String currentPassword;
  const SetNewPasswordScreen({super.key, required this.currentPassword});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  int _strengthScore = 0;

  static bool _hasUppercase(String v) => v.contains(RegExp(r'[A-Z]'));
  static bool _hasLowercase(String v) => v.contains(RegExp(r'[a-z]'));
  static bool _hasDigit(String v) => v.contains(RegExp(r'[0-9]'));
  static bool _hasSpecial(String v) =>
      v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/]'));

  int _calcStrength(String v) {
    if (v.isEmpty) return 0;
    int score = 0;
    if (v.length >= 8) score++;
    if (_hasUppercase(v)) score++;
    if (_hasLowercase(v)) score++;
    if (_hasDigit(v)) score++;
    if (_hasSpecial(v)) score++;
    return score;
  }

  String? _validateNewPassword(String? val) {
    if (val == null || val.isEmpty) return 'Please enter a new password';
    if (val.length < 8) return 'Must be at least 8 characters';
    if (!_hasUppercase(val)) return 'Add at least one uppercase letter';
    if (!_hasLowercase(val)) return 'Add at least one lowercase letter';
    if (!_hasDigit(val)) return 'Add at least one number';
    if (!_hasSpecial(val)) return 'Add at least one special character';
    return null;
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      context.read<SetPasswordBloc>().add(
            SetNewPasswordSubmitEvent(
              currentPassword: widget.currentPassword,
              newPassword: _newPasswordController.text.trim(),
              confirmPassword: _confirmPasswordController.text.trim(),
            ),
          );
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
          if (state is SetPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password changed successfully!'),
                backgroundColor: AppColors.primaryOrange,
              ),
            );
            Navigator.of(context)
              ..pop()
              ..pop();
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
                  Text('Set New Password', style: AppTextStyles.heading1),
                  const SizedBox(height: 6),
                  Text(
                    'Choose a strong password you haven\'t used before.',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 32),
                  PasswordField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    validator: _validateNewPassword,
                    onChanged: (val) =>
                        setState(() => _strengthScore = _calcStrength(val)),
                  ),
                  const SizedBox(height: 10),
                  _StrengthIndicator(score: _strengthScore),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (val != _newPasswordController.text) {
                        return 'Passwords do not match';
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
                          onPressed: isLoading ? null : _onSavePressed,
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
                                  'Save Password',
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

class _StrengthIndicator extends StatelessWidget {
  final int score;
  const _StrengthIndicator({required this.score});

  Color get _color {
    if (score <= 1) return Colors.red;
    if (score == 2) return Colors.orange;
    if (score == 3) return Colors.yellow.shade700;
    if (score == 4) return Colors.lightGreen;
    return Colors.green;
  }

  String get _label {
    if (score == 0) return '';
    if (score <= 1) return 'Weak';
    if (score == 2) return 'Fair';
    if (score == 3) return 'Good';
    if (score == 4) return 'Strong';
    return 'Very Strong';
  }

  @override
  Widget build(BuildContext context) {
    if (score == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 5,
            minHeight: 5,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _label,
          style: TextStyle(
            fontSize: 12,
            color: _color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
