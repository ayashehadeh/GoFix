import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/application_status_entity.dart';
import '../repositories/application_status_repository.dart';

class GetApplicationStatus {
  final ApplicationStatusRepository repository;
  const GetApplicationStatus(this.repository);

  Future<Either<Failure, ApplicationStatusEntity>> call() =>
      repository.getApplicationStatus();
}
