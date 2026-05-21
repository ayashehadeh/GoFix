import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/earning_entity.dart';

abstract class EarningsRepository {
  Future<Either<Failure, Map<String, Earning>>> getEarnings();
  Future<Either<Failure, Map<String, Earning>>> refreshEarnings();
}
