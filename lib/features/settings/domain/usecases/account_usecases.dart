import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/settings/domain/entities/feedback_entity.dart';
import 'package:gp/features/settings/domain/repositories/account_repository.dart';

class LogoutUseCase {
  final AccountRepository repository;
  LogoutUseCase(this.repository);
  Future<Either<Failure, Unit>> call() => repository.logout();
}

class DeleteAccountUseCase {
  final AccountRepository repository;
  DeleteAccountUseCase(this.repository);
  Future<Either<Failure, Unit>> call() => repository.deleteAccount();
}

class SendFeedbackUseCase {
  final AccountRepository repository;
  SendFeedbackUseCase(this.repository);
  Future<Either<Failure, Unit>> call(FeedbackEntity feedback) =>
      repository.sendFeedback(feedback);
}
