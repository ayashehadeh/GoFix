import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/settings/data/datasources/set_password_remote_datasource.dart';
import 'package:gp/features/settings/data/models/set_password_model.dart';
import 'package:gp/features/settings/domain/entities/set_password_entity.dart';
import 'package:gp/features/settings/domain/repositories/set_password_repository.dart';

class SetPasswordRepositoryImpl implements SetPasswordRepository {
  final SetPasswordRemoteDataSource remoteDataSource;

  SetPasswordRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Unit>> setNewPassword(
    SetPasswordEntity entity,
  ) async {
    try {
      final model = SetPasswordModel.fromEntity(entity);
      await remoteDataSource.setNewPassword(model);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
