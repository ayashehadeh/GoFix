import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/availability_entity.dart';
import '../repositories/availability_repository.dart';

class GetAvailability implements UseCase<AvailabilityEntity, NoParams> {
  final AvailabilityRepository repository;

  GetAvailability(this.repository);

  @override
  Future<Either<Failure, AvailabilityEntity>> call(NoParams params) async {
    return await repository.getAvailability();
  }
}
