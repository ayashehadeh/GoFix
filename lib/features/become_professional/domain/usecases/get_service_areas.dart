import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/service_area.dart';
import '../repositories/become_professional_repository.dart';

class GetServiceAreas {
  final BecomeProfessionalRepository repository;
  const GetServiceAreas(this.repository);

  Future<Either<Failure, List<ServiceArea>>> call() =>
      repository.getServiceAreas();
}
