import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../repositories/professionals_repository.dart';

class ToggleFavorite {
  final ProfessionalsRepository repository;

  const ToggleFavorite(this.repository);

  Future<Either<Failure, void>> call(String professionalId) {
    return repository.toggleFavorite(professionalId);
  }
}
