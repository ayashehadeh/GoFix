import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/error/app_error_state.dart';
import 'package:gp/core/utils/app_navigator.dart';
import 'package:gp/core/widgets/app_error_dialog.dart';

class AppBlocObserver extends BlocObserver {
  static bool _dialogShowing = false;

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (change.nextState is AppErrorState) {
      _scheduleDialog();
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _scheduleDialog();
  }

  static void _scheduleDialog() {
    if (_dialogShowing) return;
    _dialogShowing = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final ctx = appNavigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        AppErrorDialog.show(ctx).whenComplete(() => _dialogShowing = false);
      } else {
        _dialogShowing = false;
      }
    });
  }
}
