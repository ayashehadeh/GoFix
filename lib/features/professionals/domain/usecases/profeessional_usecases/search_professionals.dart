import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/professional.dart';
import '../../repositories/professionals_repository.dart';

class SearchProfessionals {
  final ProfessionalsRepository repository;

  const SearchProfessionals(this.repository);

  Future<Either<Failure, List<Professional>>> call(String query) {
    return repository.searchProfessionals(query);
  }
}
