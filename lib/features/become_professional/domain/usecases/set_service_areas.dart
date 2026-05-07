import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/become_professional_repository.dart';

class SetServiceAreas {
  final BecomeProfessionalRepository repository;
  const SetServiceAreas(this.repository);

  Future<Either<Failure, Unit>> call(List<int> serviceAreaIds) =>
      repository.setServiceAreas(serviceAreaIds);
}
