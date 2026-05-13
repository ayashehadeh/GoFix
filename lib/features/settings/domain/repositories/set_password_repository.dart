import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/settings/domain/entities/set_password_entity.dart';

abstract class SetPasswordRepository {
  Future<Either<Failure, Unit>> verifyCurrentPassword(String password);
  Future<Either<Failure, Unit>> setNewPassword(SetPasswordEntity entity);
}
