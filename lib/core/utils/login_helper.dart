import 'package:flutter/material.dart';
import 'package:gp/core/utils/statuschecker.dart';
import 'package:gp/injection_container.dart' as di;

class LoginHelper {
  /// After successful login, navigate to correct screen based on user role
  static Future<void> navigateAfterLogin(BuildContext context) async {
    // Check if user is professional from backend API
    final checker = ProfessionalStatusChecker(di.sl());
    final status = await checker.checkStatus();

    final isProfessional = status['isProfessional'] == true;
    final name = status['name'] ?? 'User';

    if (!context.mounted) return;

    if (isProfessional) {
      // Professional user → Go to Dashboard
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      // Regular user → Go to Home
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}
