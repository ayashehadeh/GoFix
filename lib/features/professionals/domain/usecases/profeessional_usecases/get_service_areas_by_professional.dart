import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/service_area.dart';
import '../../repositories/professionals_repository.dart';

class GetServiceAreasByProfessional {
  final ProfessionalsRepository repository;

  const GetServiceAreasByProfessional(this.repository);

  Future<Either<Failure, List<ServiceArea>>> call(String professionalId) {
    return repository.getServiceAreasByProfessional(professionalId);
  }
}
