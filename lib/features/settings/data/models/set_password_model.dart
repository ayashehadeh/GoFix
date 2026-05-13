import 'package:gp/features/settings/domain/entities/set_password_entity.dart';

class SetPasswordModel extends SetPasswordEntity {
  const SetPasswordModel({
    required super.currentPassword,
    required super.newPassword,
    required super.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }

  factory SetPasswordModel.fromEntity(SetPasswordEntity entity) {
    return SetPasswordModel(
      currentPassword: entity.currentPassword,
      newPassword: entity.newPassword,
      confirmPassword: entity.confirmPassword,
    );
  }
}
