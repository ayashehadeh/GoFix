import 'package:flutter/material.dart';

void showSuccessSnackbar(BuildContext context, String message) => _show(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      color: const Color(0xFF0D1F3C),
    );

void showErrorSnackbar(BuildContext context, String message) => _show(
      context,
      message: message,
      icon: Icons.error_outline,
      color: const Color(0xFFD32F2F),
    );

void showWarningSnackbar(BuildContext context, String message) => _show(
      context,
      message: message,
      icon: Icons.info_outline,
      color: const Color(0xFFE87722),
    );

void _show(
  BuildContext context, {
  required String message,
  required IconData icon,
  required Color color,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
