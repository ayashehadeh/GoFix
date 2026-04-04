import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/settings/domain/entities/set_password_entity.dart';
import 'package:gp/features/settings/domain/repositories/set_password_repository.dart';

class SetNewPasswordUseCase {
  final SetPasswordRepository repository;

  SetNewPasswordUseCase(this.repository);

  Future<Either<Failure, Unit>> call(SetPasswordEntity entity) {
    return repository.setNewPassword(entity);
  }
}
