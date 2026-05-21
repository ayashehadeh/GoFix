import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/earning_entity.dart';
import '../repositories/earnings_repository.dart';

class GetEarnings {
  final EarningsRepository repository;

  GetEarnings(this.repository);

  Future<Either<Failure, Map<String, Earning>>> call() async {
    return await repository.getEarnings();
  }
}

class RefreshEarnings {
  final EarningsRepository repository;

  RefreshEarnings(this.repository);

  Future<Either<Failure, Map<String, Earning>>> call() async {
    return await repository.refreshEarnings();
  }
}
