import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/become_professional_repository.dart';

class SubmitApplication {
  final BecomeProfessionalRepository repository;
  const SubmitApplication(this.repository);

  Future<Either<Failure, Unit>> call() => repository.submitApplication();
}
