import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/professional.dart';
import '../../repositories/professionals_repository.dart';

class GetFavorites {
  final ProfessionalsRepository repository;

  const GetFavorites(this.repository);

  Future<Either<Failure, List<Professional>>> call() {
    return repository.getFavorites();
  }
}
