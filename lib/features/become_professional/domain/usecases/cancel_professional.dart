import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/become_professional_repository.dart';

class CancelProfessionalUseCase {
  final BecomeProfessionalRepository repository;
  const CancelProfessionalUseCase(this.repository);

  Future<Either<Failure, Unit>> call() => repository.cancelProfessional();
}
