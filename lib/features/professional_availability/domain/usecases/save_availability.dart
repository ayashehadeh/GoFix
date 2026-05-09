import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/availability_entity.dart';
import '../repositories/availability_repository.dart';

class SaveAvailability implements UseCase<void, SaveAvailabilityParams> {
  final AvailabilityRepository repository;

  SaveAvailability(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveAvailabilityParams params) async {
    return await repository.saveAvailability(params.availability);
  }
}

class SaveAvailabilityParams extends Equatable {
  final AvailabilityEntity availability;

  const SaveAvailabilityParams({required this.availability});

  @override
  List<Object?> get props => [availability];
}
