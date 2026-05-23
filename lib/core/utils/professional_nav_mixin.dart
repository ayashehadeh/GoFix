import 'package:flutter/material.dart';
import 'package:gp/core/storage/user_type_storage.dart';
import 'package:gp/core/utils/statuschecker.dart';
import 'package:gp/injection_container.dart' as di;

mixin ProfessionalNavMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  bool isProfessional = false;

  void initProfessionalNav() {
    WidgetsBinding.instance.addObserver(this);
    loadProfessionalStatus();
  }

  void disposeProfessionalNav() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) _refreshFromServer();
  }

  Future<void> loadProfessionalStatus() async {
    final result = await UserTypeStorage.isProfessional();
    if (mounted) setState(() => isProfessional = result);
  }

  Future<void> _refreshFromServer() async {
    try {
      final status = await ProfessionalStatusChecker(di.sl()).checkStatus();
      final isPro = status['isProfessional'] == true;
      if (isPro) {
        await UserTypeStorage.setAsProfessional(status['name'] ?? 'Professional');
      } else {
        await UserTypeStorage.clear();
      }
      if (mounted) setState(() => isProfessional = isPro);
    } catch (_) {}
  }
}
