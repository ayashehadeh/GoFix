import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/professional_application.dart';
import '../repositories/become_professional_repository.dart';

class SubmitProfessionalApplication {
  final BecomeProfessionalRepository repository;

  const SubmitProfessionalApplication(this.repository);

  Future<Either<Failure, void>> call(ProfessionalApplication application) =>
      repository.submitApplication(application);
}
