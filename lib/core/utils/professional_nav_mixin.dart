import 'package:flutter/material.dart';
import 'package:gp/core/storage/user_type_storage.dart';

mixin ProfessionalNavMixin<T extends StatefulWidget> on State<T> {
  bool isProfessional = false;

  /// Call this in initState — reads from SharedPreferences, no API call.
  Future<void> loadProfessionalStatus() async {
    final result = await UserTypeStorage.isProfessional();
    if (mounted) {
      setState(() => isProfessional = result);
    }
  }
}