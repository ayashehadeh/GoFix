import 'package:gp/features/settings/data/models/set_password_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SetPasswordRemoteDataSource {
  Future<void> setNewPassword(SetPasswordModel model);
}

class SetPasswordRemoteDataSourceImpl implements SetPasswordRemoteDataSource {
  static const _keyPassword = 'user_password';

  @override
  Future<void> setNewPassword(SetPasswordModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPassword, model.newPassword);
  }
}
