import 'package:gp/features/settings/domain/entities/set_password_entity.dart';

class SetPasswordModel extends SetPasswordEntity {
  const SetPasswordModel({
    required super.newPassword,
    required super.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }

  factory SetPasswordModel.fromEntity(SetPasswordEntity entity) {
    return SetPasswordModel(
      newPassword: entity.newPassword,
      confirmPassword: entity.confirmPassword,
    );
  }
}
