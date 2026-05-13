import 'package:flutter/material.dart';
import 'package:gp/core/utils/statuschecker.dart';
import 'package:gp/core/storage/user_type_storage.dart'; // add this
import 'package:gp/injection_container.dart' as di;

class LoginHelper {
  static Future<void> navigateAfterLogin(BuildContext context) async {
    final checker = ProfessionalStatusChecker(di.sl());
    final status = await checker.checkStatus();

    final isProfessional = status['isProfessional'] == true;
    final name = status['name'] ?? 'User';

    if (!context.mounted) return;

    if (isProfessional) {
      await UserTypeStorage.setAsProfessional(name); // ADD THIS
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      await UserTypeStorage.clear(); // ADD THIS — clears if they were previously professional
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}