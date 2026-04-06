import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/settings/data/datasources/account_remote_datasource.dart';
import 'package:gp/features/settings/data/models/feedback_model.dart';
import 'package:gp/features/settings/domain/entities/feedback_entity.dart';
import 'package:gp/features/settings/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendFeedback(FeedbackEntity feedback) async {
    try {
      final model = FeedbackModel.fromEntity(feedback);
      await remoteDataSource.sendFeedback(model);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
