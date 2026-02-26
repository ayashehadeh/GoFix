import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/professional.dart';
import '../../repositories/professionals_repository.dart';

class GetProfessionalById {
  final ProfessionalsRepository repository;

  const GetProfessionalById(this.repository);

  Future<Either<Failure, Professional>> call(String id) {
    return repository.getProfessionalById(id);
  }
}
