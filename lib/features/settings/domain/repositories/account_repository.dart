import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/settings/domain/entities/feedback_entity.dart';

abstract class AccountRepository {
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, Unit>> deleteAccount();
  Future<Either<Failure, Unit>> sendFeedback(FeedbackEntity feedback);
}
