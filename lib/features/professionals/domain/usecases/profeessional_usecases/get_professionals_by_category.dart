import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/professional.dart';
import '../../entities/service_category.dart';
import '../../repositories/professionals_repository.dart';

class GetProfessionalsByCategory {
  final ProfessionalsRepository repository;

  const GetProfessionalsByCategory(this.repository);

  Future<Either<Failure, List<Professional>>> call(ServiceCategory category) {
    return repository.getProfessionalsByCategory(category);
  }
}
