import 'package:flutter/material.dart';
import 'package:gp/core/theme/app_colors.dart';

/// A polished, reusable popup for surfacing errors (and optionally success)
/// across the app — replaces ad-hoc SnackBars with a consistent dialog.
///
/// Usage:
///   AppDialog.showError(context, message: 'Invalid email or password.');
///   AppDialog.showError(context, title: 'Couldn\'t sign you in',
///                        message: 'Please check your details and try again.');
class AppDialog {
  AppDialog._();

  static Future<void> showError(
    BuildContext context, {
    String? title,
    required String message,
    String buttonLabel = 'OK',
  }) {
    return _show(
      context,
      icon: Icons.error_outline_rounded,
      accent: const Color(0xFFE53935),
      title: title ?? 'Something went wrong',
      message: message,
      buttonLabel: buttonLabel,
    );
  }

  static Future<void> showSuccess(
    BuildContext context, {
    String? title,
    required String message,
    String buttonLabel = 'OK',
  }) {
    return _show(
      context,
      icon: Icons.check_circle_outline_rounded,
      accent: const Color(0xFF2E7D32),
      title: title ?? 'Success',
      message: message,
      buttonLabel: buttonLabel,
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required IconData icon,
    required Color accent,
    required String title,
    required String message,
    required String buttonLabel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 36),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF062B4D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
