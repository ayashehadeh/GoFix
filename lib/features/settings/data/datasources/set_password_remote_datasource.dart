import 'package:dio/dio.dart';
import 'package:gp/features/settings/data/models/set_password_model.dart';

abstract class SetPasswordRemoteDataSource {
  Future<void> verifyCurrentPassword(String password);
  Future<void> setNewPassword(SetPasswordModel model);
}

class SetPasswordRemoteDataSourceImpl implements SetPasswordRemoteDataSource {
  final Dio dio;
  SetPasswordRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> verifyCurrentPassword(String password) async {
    // Verification happens server-side when setNewPassword is called.
  }

  @override
  Future<void> setNewPassword(SetPasswordModel model) async {
    await dio.put('/auth/change-password', data: {
      'currentPassword': model.currentPassword,
      'newPassword': model.newPassword,
      'confirmNewPassword': model.confirmPassword,
    });
  }
}
